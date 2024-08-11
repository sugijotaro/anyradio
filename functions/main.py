from firebase_admin import credentials, initialize_app, firestore, storage
from firebase_functions import firestore_fn
import google.generativeai as genai
import tempfile
import os
import random
import urllib.request
import mimetypes
from google.cloud import texttospeech
import requests
import google.auth
import google.auth.transport.requests
import base64
from PIL import Image
import io
import time
import gc

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
        'script': "I would like to create a radio program based on these images and video files. Please imagine yourself as a radio narrator and write a lively, engaging script to read out loud. The script should feel like you are telling a story to the listeners, evoking emotions and creating vivid imagery in their minds. Avoid including any sound effects or stage directions, and do not use any headings or labels. Just provide the plain text that can be read aloud. in English.",
        'title': "Based on the contents of the radio script below, please think of an appropriate title in English. Please provide only the title without any markdown-like symbols like #, ##, ###, or **.\n\n{script}",
        'description': "Think of a suitable description based on the contents of the radio script below in English. Please give us a brief description without any markdown-like symbols like #, ##, ###, or **. We will use that sentence as the radio description.\n\n{script}"
    },
    'ja': {
        'script': "これらの画像や動画ファイルをもとに、ラジオ番組を作成したいと思います。ラジオのナレーターとして、自分が話しているような気分になって、リスナーに感情を呼び起こし、心に鮮やかなイメージを作り出すような、生き生きとした魅力的なスクリプトを書いてください。効果音や演出指示は含まず、見出しやラベルも使用せず、朗読できるようなプレーンテキストだけを提供してください。日本語で記述してください。",
        'title': "以下のラジオスクリプトの内容に基づいて、日本語で適切なタイトルを考えてください。タイトルだけをMarkdown形式の記号なしで簡潔に教えてください。\n\n{script}",
        'description': "以下のラジオスクリプトの内容に基づいて、日本語で適切な説明文を考えてください。Markdown形式の記号なしで簡潔な説明文を教えてください。その文をラジオの説明文として使用します。\n\n{script}"
    }
}

GENRES = {
    1: 'comedy',
    2: 'news',
    3: 'education',
    4: 'parenting',
    5: 'mentalHealth',
    6: 'romance',
    7: 'mystery',
    8: 'business',
    9: 'entertainment',
    10: 'history',
    11: 'health',
    12: 'science',
    13: 'sports',
    14: 'fiction',
    15: 'religion'
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
    prompt = ("Create a concise prompt for generating a thumbnail image based on the radio script content. "
            "The thumbnail should represent the main theme of the script effectively.")
    return call_gemini_api(f"{prompt}\n\n{script}")

def generate_thumbnail_image_with_retry(thumbnail_prompt, upload_id, retries=2, delay=5):
    for attempt in range(retries):
        print(f"Attempt {attempt + 1} of {retries} to generate thumbnail...")
        thumbnail_url = generate_thumbnail_image(thumbnail_prompt, upload_id)
        
        if thumbnail_url:
            return thumbnail_url
        
        print(f"Retry {attempt + 1}/{retries} failed. Retrying in {delay} seconds...")
        time.sleep(delay * (attempt + 1))

    print("Failed to generate thumbnail after multiple attempts.")
    return None

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
    print(request_body)
    
    response = requests.post(ENDPOINT_URL, json=request_body, headers=headers)
    
    if response.status_code == 200:
        response_json = response.json()
        
        if 'predictions' in response_json and len(response_json['predictions']) > 0:
            img_base64 = response_json['predictions'][0].get('bytesBase64Encoded', None)
            
            if img_base64:
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
                img.close()
                gc.collect()

                return blob.public_url
            else:
                print("Error: Image data not found in predictions.")
        else:
            print(f"Error: No valid predictions found in response. Response: {response_json}")
            print(response)
    else:
        print(f"Error: {response.status_code}, {response.text}")
    
    return None

def generate_audio_from_text(text, upload_id, language):
    client = texttospeech.TextToSpeechClient()

    if language == "ja":
        voices = [
            "ja-JP-Standard-A",
            "ja-JP-Standard-B",
            "ja-JP-Standard-C",
            "ja-JP-Standard-D"
        ]
    else:
        voices = [
            "en-US-Standard-A",
            "en-US-Standard-B",
            "en-US-Standard-C",
            "en-US-Standard-D",
            "en-US-Standard-E",
            "en-US-Standard-F",
            "en-US-Standard-G",
            "en-US-Standard-H",
            "en-US-Standard-I",
            "en-US-Standard-J"
        ]

    selected_voice_name = random.choice(voices)

    synthesis_input = texttospeech.SynthesisInput(text=text)

    voice = texttospeech.VoiceSelectionParams(
        language_code="ja-JP" if language == "ja" else "en-US",
        name=selected_voice_name
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

def generate_genre_prompt(script):
    genre_prompt = (
        "Based on the contents of the following radio script, please choose the most appropriate genre by selecting the corresponding number: \n"
        "1. Comedy\n2. News\n3. Education\n4. Parenting\n5. Mental Health\n6. Romance\n7. Mystery\n8. Business\n"
        "9. Entertainment\n10. History\n11. Health\n12. Science\n13. Sports\n14. Fiction\n15. Religion\n\n"
        "Please provide only the number corresponding to the genre.\n\n{script}"
    )
    response = call_gemini_api(genre_prompt.format(script=script)).strip()
    
    try:
        genre_number = int(response)
        if genre_number in GENRES:
            return GENRES[genre_number]
        else:
            print(f"Invalid genre number: {genre_number}")
            return 'entertainment'
    except ValueError:
        print(f"Invalid response: {response}")
        return 'entertainment'

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

        del uploaded_files
        gc.collect()

        thumbnail_prompt = generate_thumbnail_prompt(generated_script)

        thumbnail_url = generate_thumbnail_image_with_retry(thumbnail_prompt, upload_id, retries=2, delay=5)

        prompt_title = generate_prompt('title', generated_script, language)
        prompt_description = generate_prompt('description', generated_script, language)

        generated_title = call_gemini_api(prompt_title)
        generated_description = call_gemini_api(prompt_description)

        selected_genre = generate_genre_prompt(generated_script)

        audio_url = generate_audio_from_text(generated_script, upload_id, language)

        radio_data = {
            'title': generated_title,
            'description': generated_description,
            'script': generated_script,
            'audioUrl': audio_url,
            'thumbnail': thumbnail_url if thumbnail_url else "",
            'uploaderId': data.get('userId'),
            'uploadDate': firestore.SERVER_TIMESTAMP,
            'comments': [],
            'likes': 0,
            'genre': selected_genre,
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

@firestore_fn.on_document_created(document="radios/{radioId}")
def on_radio_document_created(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    doc = event.data
    if not doc:
        print("No data found in document.")
        return

    data = doc.to_dict()
    radio_id = event.params.get('radioId')
    script = data.get('script', '')
    thumbnail_url = data.get('thumbnail', '')

    if not thumbnail_url:
        print(f"Thumbnail missing for radio ID: {radio_id}, attempting to generate...")

        try:
            thumbnail_prompt = generate_thumbnail_prompt(script)

            generated_thumbnail_url = generate_thumbnail_image_with_retry(thumbnail_prompt, radio_id, retries=2, delay=5)

            if generated_thumbnail_url:
                db.collection('radios').document(radio_id).update({
                    'thumbnail': generated_thumbnail_url
                })
                print(f"Thumbnail successfully generated and updated for radio ID: {radio_id}")
            else:
                print(f"Failed to generate thumbnail for radio ID: {radio_id} after multiple attempts.")

        except Exception as e:
            print(f"Error generating thumbnail for radio ID: {radio_id}: {e}")