from firebase_admin import credentials, initialize_app, firestore
from firebase_functions import firestore_fn
import google.generativeai as genai
import os

# Firebase Admin SDKの初期化
cred = credentials.Certificate('anyradio-693a9-9571794b8f6e.json')
app = initialize_app(cred)
db = firestore.client()

# Gemini APIの設定
genai.configure(api_key=os.environ.get('GEMINI_API_KEY'))
model = genai.GenerativeModel('gemini-1.5-flash')

# TTS APIのエンドポイント
TTS_API_ENDPOINT = os.environ.get('TTS_API_ENDPOINT')

def call_gemini_api(file_url):
    # Gemini APIを呼び出してテキストを生成
    prompt = f"Generate text based on the content at {file_url}"
    response = model.generate_content(prompt)
    return response.text

def generate_audio_from_text(text):
    response = requests.post(TTS_API_ENDPOINT, json={'text': text})
    response.raise_for_status()
    return response.json().get('audioUrl', '')

@firestore_fn.on_document_created(document="uploads/{uploadId}")
def process_upload(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    doc = event.data
    if not doc:
        print("No data found in document.")
        return

    data = doc.to_dict()
    file_url = data.get('fileUrl')
    upload_id = event.params.get('uploadId')

    try:
        # Gemini APIを呼び出してテキストを生成
        generated_text = call_gemini_api(file_url)
        
        # TTS APIを呼び出して音声を生成
        audio_url = generate_audio_from_text(generated_text)

        # Radioドキュメントを作成
        radio_data = {
            'title': 'Generated Radio Title',
            'description': generated_text,
            'audioUrl': audio_url,
            'imageUrl': file_url,
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

        db.collection('radios').add(radio_data)

        # アップロードステータスを完了に更新
        db.collection('uploads').document(upload_id).update({'status': 'completed'})

        print("Radio creation completed and updated in Firestore.")

    except Exception as e:
        print(f"Error processing upload: {e}")
        db.collection('uploads').document(upload_id).update({'status': 'failed'})