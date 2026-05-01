import os
import uuid
import shutil
import PyPDF2
import pytesseract
from PIL import Image
from pdf2image import convert_from_path
from services.embed_service import embed_message
from services.supabase_client import client

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


def extract_text_from_pdf(path):
    text = ""
    with open(path, "rb") as f:
        reader = PyPDF2.PdfReader(f)

        for page in reader.pages:
            page_text = page.extract_text() or ""
            text += page_text

    if not text.strip():
        try:
            
            images = convert_from_path(path)

            for img in images:
                text += pytesseract.image_to_string(img)
        except Exception:
            pass

    return text.strip()


def extract_text_from_image(path):
    return pytesseract.image_to_string(Image.open(path)).strip()


def read_file_content(path, ext):
    if ext in ["txt", "md"]:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()

    elif ext == "pdf":
        return extract_text_from_pdf(path)

    elif ext in ["png", "jpg", "jpeg"]:
        return extract_text_from_image(path)

    else:
        raise Exception("Unsupported file type")


def chunk_text(text, chunk_size=500, overlap=50):
    chunks = []
    start = 0
    n = len(text)

    while start < n:
        end = start + chunk_size
        chunks.append(text[start:end])
        start += chunk_size - overlap

    return chunks


def save_file(file, uploaded_by):
    file_id = str(uuid.uuid4())
    ext = file.filename.split(".")[-1].lower()
    path = os.path.join(UPLOAD_DIR, f"{file_id}.{ext}")

    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    content = read_file_content(path, ext)

    if not content:
        return file_id, ext

    chunks = chunk_text(content)
    total_chunks = len(chunks)

    rows = []

    for i, chunk in enumerate(chunks):
        embedding = embed_message(chunk)

        if hasattr(embedding, "tolist"):
            embedding = embedding.tolist()

        rows.append({
            "content": chunk,
            "embedding": embedding,
            "source_file": file_id,
            "file_type": ext,
            "chunk_index": i,
            "total_chunks": total_chunks,
            "page_number": None,
            "uploaded_by": uploaded_by
        })

    if rows:
        client.table("embeddings_v2").insert(rows).execute()

    return file_id, ext