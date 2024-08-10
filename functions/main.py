from firebase_admin import credentials, initialize_app, firestore, storage
from firebase_functions import firestore_fn
import google.generativeai as genai
import tempfile
import os
import urllib.request
import mimetypes
from google.cloud import texttospeech
import requests
import google.auth
import google.auth.transport.requests
import base64
from PIL import Image
import io

cred = credentials.Certificate('anyradio-693a9-9571794b8f6e.json')
app = initialize_app(cred)
db = firestore.client()
bucket = storage.bucket('anyradio-693a9.appspot.com')

genai.configure(api_key=os.environ.get('GEMINI_API_KEY'))
model = genai.GenerativeModel('gemini-1.5-flash')

PROJECT_ID = 'anyradio-693a9'
ENDPOINT_URL = f"https://us-central1-aiplatform.googleapis.com/v1/projects/{PROJECT_ID}/locations/us-central1/publishers/google/models/imagegeneration:predict"

PROMPTS = {
    'en': {
        'script': "I would like to create a radio program based on these images and video files. Please imagine yourself as a radio narrator and write a lively, engaging script to read out loud. The script should feel like you are telling a story to the listeners, evoking emotions and creating vivid imagery in their minds. Avoid including any sound effects or stage directions, and do not use any headings or labels. Just provide the plain text that can be read aloud. in English. Please do not hallucinate.",
        'title': "Based on the contents of the radio script below, please think of an appropriate title in English. Please provide only the title without any markdown-like symbols like #, ##, ###, or **. Please, do not hallucinate.\n\n{script}",
        'description': "Think of a suitable description based on the contents of the radio script below in English. Please give us a brief description without any markdown-like symbols like #, ##, ###, or **. Please, do not hallucinate. We will use that sentence as the radio description.\n\n{script}"
    },
    'ja': {
        'script': "これらの画像や動画ファイルをもとに、ラジオ番組を作成したいと思います。ラジオのナレーターとして、自分が話しているような気分になって、リスナーに感情を呼び起こし、心に鮮やかなイメージを作り出すような、生き生きとした魅力的なスクリプトを書いてください。効果音や演出指示は含まず、見出しやラベルも使用せず、朗読できるようなプレーンテキストだけを提供してください。日本語で記述してください。ハルシネーションを起こさないようにしてください。",
        'title': "以下のラジオスクリプトの内容に基づいて、日本語で適切なタイトルを考えてください。タイトルだけをMarkdown形式の記号なしで簡潔に教えてください。ハルシネーションを起こさないようにしてください。\n\n{script}",
        'description': "以下のラジオスクリプトの内容に基づいて、日本語で適切な説明文を考えてください。Markdown形式の記号なしで簡潔な説明文を教えてください。ハルシネーションを起こさないようにしてください。その文をラジオの説明文として使用します。\n\n{script}"
    }
}

def get_access_token():
    credentials, project = google.auth.default()
    auth_req = google.auth.transport.requests.Request()
    credentials.refresh(auth_req)
    return credentials.token

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
        file_name = f"file{i+1}"
        print(f"File name: {file_name}")

        download_file(file_url, file_name)

        mime_type, _ = mimetypes.guess_type(file_name)
        if mime_type is None:
            mime_type = 'image/jpeg'

        try:
            uploaded_file = genai.upload_file(path=file_name, display_name=file_name, mime_type=mime_type)
            uploaded_files.append(uploaded_file)
            print(f"Uploaded file '{uploaded_file.display_name}' as: {uploaded_file.uri}")

        except Exception as e:
            print(f"Error uploading file to Gemini API: {e}")
            raise

        os.remove(file_name)

    return uploaded_files

def call_gemini_api(prompt):
    try:
        response = model.generate_content(prompt)
        print(f"Generated content: {response.text}")
        return response.text
    except Exception as e:
        print(f"Error generating content with Gemini API: {e}")
        raise

def generate_prompt(prompt_type, script, language='en'):
    template = PROMPTS.get(language, PROMPTS['en']).get(prompt_type, '')
    return template.format(script=script)

def generate_thumbnail_prompt(script):
    prompt = ("I want to create a thumbnail image for this radio show based on the script. "
              "Please understand the content of the script, think of a suitable thumbnail image "
              "for this radio show, and come up with a prompt to send to the image generation API.")
    return call_gemini_api(f"{prompt}\n\n{script}")

def generate_thumbnail_image(script, upload_id):
    access_token = get_access_token()
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json; charset=utf-8'
    }
    
    thumbnail_prompt = generate_thumbnail_prompt(script)
    request_body = {
        "instances": [
            {
                "prompt": thumbnail_prompt
            }
        ],
        "parameters": {
            "sampleCount": 1
        }
    }
    
    response = requests.post(ENDPOINT_URL, json=request_body, headers=headers)
    
    if response.status_code == 200:
        response_json = response.json()
        img_base64 = response_json['predictions'][0]['bytesBase64Encoded']
        
        img_data = base64.b64decode(img_base64)
        img = Image.open(io.BytesIO(img_data))
        img = img.convert("RGB")
        img = img.resize((1024, 1024))

        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".jpg")
        img.save(temp_file, format="JPEG", quality=85)
        temp_file_path = temp_file.name

        blob = bucket.blob(f'audio/{upload_id}/thumbnail.jpg')
        blob.upload_from_filename(temp_file_path)
        blob.make_public()

        os.remove(temp_file_path)

        return blob.public_url
    else:
        print(f"Error: {response.status_code}, {response.text}")
        return None

def generate_audio_from_text(text, upload_id, language):
    client = texttospeech.TextToSpeechClient()

    synthesis_input = texttospeech.SynthesisInput(text=text)

    voice = texttospeech.VoiceSelectionParams(
        language_code="ja-JP" if language == "ja" else "en-US",
        ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL
    )

    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )

    response = client.synthesize_speech(
        input=synthesis_input, voice=voice, audio_config=audio_config
    )

    with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as out:
        out.write(response.audio_content)
        temp_file_path = out.name
        print(f'Audio content written to temporary file "{temp_file_path}"')

    blob = bucket.blob(f'audio/{upload_id}/{temp_file_path.split("/")[-1]}')
    blob.upload_from_filename(temp_file_path)
    blob.make_public()

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
    language = data.get('language', 'en')

    try:
        uploaded_files = upload_files(file_urls)

        prompt_script = [PROMPTS[language]['script']] + uploaded_files
        generated_script = call_gemini_api(prompt_script)

        thumbnail_url = generate_thumbnail_image(generated_script, upload_id)

        prompt_title = generate_prompt('title', generated_script, language)
        prompt_description = generate_prompt('description', generated_script, language)

        generated_title = call_gemini_api(prompt_title)
        generated_description = call_gemini_api(prompt_description)

        audio_url = generate_audio_from_text(generated_script, upload_id, language)

        radio_data = {
            'title': generated_title,
            'description': generated_description,
            'script': generated_script,
            'audioUrl': audio_url,
            'thumbnail': thumbnail_url,
            'uploaderId': data.get('userId'),
            'uploadDate': firestore.SERVER_TIMESTAMP,
            'comments': [],
            'likes': 0,
            'genre': 'Generated',
            'playCount': 0,
            'language': language,
            'lastPlayed': None,
            'privacyLevel': 'public'
        }

        db.collection('radios').document(upload_id).set(radio_data)

        db.collection('uploads').document(upload_id).update({'status': 'completed'})

        print("Radio creation completed and updated in Firestore.")

    except Exception as e:
        print(f"Error processing upload: {e}")
        db.collection('uploads').document(upload_id).update({'status': 'failed'})