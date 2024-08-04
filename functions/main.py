from firebase_admin import credentials, initialize_app, firestore
from firebase_functions import firestore_fn
import google.generativeai as genai
import os
import urllib.request

# Firebase Admin SDKの初期化
cred = credentials.Certificate('anyradio-693a9-9571794b8f6e.json')
app = initialize_app(cred)
db = firestore.client()

# Gemini APIの設定
genai.configure(api_key=os.environ.get('GEMINI_API_KEY'))
model = genai.GenerativeModel('gemini-1.5-flash')

# TTS APIのエンドポイント
TTS_API_ENDPOINT = os.environ.get('TTS_API_ENDPOINT')

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
    for file_url in file_urls:
        # ファイルをダウンロードして一時的に保存する
        file_name = file_url.split('/')[-1]
        print(f"File name: {file_name}")

        download_file(file_url, file_name)

        # ファイルをGemini APIにアップロードする
        try:
            uploaded_file = genai.upload_file(path=file_name, display_name=file_name)
            uploaded_files.append(uploaded_file)
            print(f"File uploaded successfully: {file_name}")
        except Exception as e:
            print(f"Error uploading file to Gemini API: {e}")
            raise

        # 一時ファイルを削除
        os.remove(file_name)

    return uploaded_files

def call_gemini_api(uploaded_files, prompt_text):
    # アップロードされたファイルのURIを取得
    file_uris = [file.uri for file in uploaded_files]
    print(f"File URIs: {file_uris}")

    # プロンプトにファイルURIを含める
    prompt = [prompt_text] + file_uris
    try:
        response = model.generate_content(prompt)
        print(f"Generated content: {response.text}")
        return response.text
    except Exception as e:
        print(f"Error generating content with Gemini API: {e}")
        raise

@firestore_fn.on_document_created(document="uploads/{uploadId}")
def process_upload(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    doc = event.data
    if not doc:
        print("No data found in document.")
        return

    data = doc.to_dict()
    file_urls = data.get('fileUrls', [])
    upload_id = event.params.get('uploadId')
    prompt_text = data.get('promptText', 'Describe these images.')

    try:
        # ファイルをアップロードしてURIを取得
        uploaded_files = upload_files(file_urls)
        
        # Gemini APIを呼び出してテキストを生成
        generated_text = call_gemini_api(uploaded_files, prompt_text)

        # TTS APIを呼び出して音声を生成（現在はコメントアウト）
        # audio_url = generate_audio_from_text(generated_text)
        audio_url = ''

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