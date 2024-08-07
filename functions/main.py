from firebase_admin import credentials, initialize_app, firestore, storage
from firebase_functions import firestore_fn
import google.generativeai as genai
import tempfile
import os
import urllib.request
import mimetypes
from google.cloud import texttospeech

# Firebase Admin SDKの初期化
cred = credentials.Certificate('anyradio-693a9-9571794b8f6e.json')
app = initialize_app(cred)
db = firestore.client()
bucket = storage.bucket('anyradio-693a9.appspot.com')

# Gemini APIの設定
genai.configure(api_key=os.environ.get('GEMINI_API_KEY'))
model = genai.GenerativeModel('gemini-1.5-flash')

def download_file(url, dst_path):
    try:
        with urllib.request.urlopen(url) as web_file:
            with open(dst_path, 'wb') as local_file:
                local_file.write(web_file.read())
        print(f"File downloaded successfully: {dst_path}")
    except Exception as e:
        print(f"Error downloading file: {e}")
        raise

def upload_files(file_urls):
    uploaded_files = []
    for i, file_url in enumerate(file_urls):
        # ファイルをダウンロードして一時的に保存する
        file_name = f"file{i+1}"
        print(f"File name: {file_name}")

        download_file(file_url, file_name)

        # ファイルのMIMEタイプを取得
        mime_type, _ = mimetypes.guess_type(file_name)
        if mime_type is None:
            mime_type = 'image/jpeg'  # デフォルトのMIMEタイプ

        # ファイルをGemini APIにアップロードする
        try:
            uploaded_file = genai.upload_file(path=file_name, display_name=file_name, mime_type=mime_type)
            uploaded_files.append(uploaded_file)
            print(f"Uploaded file '{uploaded_file.display_name}' as: {uploaded_file.uri}")

        except Exception as e:
            print(f"Error uploading file to Gemini API: {e}")
            raise

        # 一時ファイルを削除
        os.remove(file_name)

    return uploaded_files

def call_gemini_api(uploaded_files):
    # プロンプトにファイルURIを含める
    prompt = ["I would like to create a radio program based on these images and video files. Please imagine yourself as a radio narrator and write a lively, engaging script to read out loud. The script should feel like you are telling a story to the listeners, evoking emotions and creating vivid imagery in their minds. Avoid including any sound effects or stage directions, and do not use any headings or labels. Just provide the plain text that can be read aloud."] + uploaded_files
    try:
        response = model.generate_content(prompt)
        print(f"Generated content: {response.text}")
        return response.text
    except Exception as e:
        print(f"Error generating content with Gemini API: {e}")
        raise

def generate_audio_from_text(text):
    # TTSクライアントの初期化
    client = texttospeech.TextToSpeechClient()

    # 音声合成の入力設定
    synthesis_input = texttospeech.SynthesisInput(text=text)

    # 音声のパラメータ設定
    voice = texttospeech.VoiceSelectionParams(
        language_code="en-US", ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL
    )

    # オーディオの設定
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )

    # 音声合成のリクエスト
    response = client.synthesize_speech(
        input=synthesis_input, voice=voice, audio_config=audio_config
    )

    # 一時ファイルに音声を書き込む
    with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as out:
        out.write(response.audio_content)
        temp_file_path = out.name
        print(f'Audio content written to temporary file "{temp_file_path}"')

    # Google Cloud Storageにアップロード
    blob = bucket.blob(f'audio/{temp_file_path.split("/")[-1]}')

    blob.upload_from_filename(temp_file_path)
    print(f'File uploaded to {blob.public_url}')

    # 一時ファイルを削除
    os.remove(temp_file_path)

    return blob.public_url

@firestore_fn.on_document_created(document="uploads/{uploadId}")
def process_upload(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    doc = event.data
    if not doc:
        print("No data found in document.")
        return

    data = doc.to_dict()
    file_urls = data.get('fileUrls', [])
    upload_id = event.params.get('uploadId')

    try:
        # ファイルをアップロードしてURIを取得
        uploaded_files = upload_files(file_urls)
        
        # Gemini APIを呼び出してテキストを生成
        generated_text = call_gemini_api(uploaded_files)

        # TTS APIを呼び出して音声を生成
        audio_url = generate_audio_from_text(generated_text)

        # Radioドキュメントを作成
        radio_data = {
            'title': 'Generated Radio Title',
            'description': generated_text,
            'audioUrl': audio_url,
            'imageUrls': file_urls,
            'uploaderId': data.get('userId'),
            'uploadDate': firestore.SERVER_TIMESTAMP,
            'comments': [],
            'likes': 0,
            'genre': 'Generated',
            'playCount': 0,
            'language': 'en',
            'lastPlayed': None,
            'privacyLevel': 'public',
        }

        db.collection('radios').document(upload_id).set(radio_data)

        # アップロードステータスを完了に更新
        db.collection('uploads').document(upload_id).update({'status': 'completed'})

        print("Radio creation completed and updated in Firestore.")

    except Exception as e:
        print(f"Error processing upload: {e}")
        db.collection('uploads').document(upload_id).update({'status': 'failed'})