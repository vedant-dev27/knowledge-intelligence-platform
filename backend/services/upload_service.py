# backend/services/upload_service.py

import os
import uuid
import shutil

from services.embed_service import embed_message
from services.supabase_client import client

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


def read_file_content(path, ext):
    print("READING FILE:", path, "| TYPE:", ext)

    if ext in ["txt", "md"]:
        with open(path, "r", encoding="utf-8") as f:
            data = f.read()
            print("TEXT FILE READ SUCCESS, LENGTH:", len(data))
            return data

    elif ext == "pdf":
        import PyPDF2
        text = ""
        with open(path, "rb") as f:
            reader = PyPDF2.PdfReader(f)
            print("PDF PAGES:", len(reader.pages))
            for i, page in enumerate(reader.pages):
                page_text = page.extract_text() or ""
                print(f"PAGE {i} LENGTH:", len(page_text))
                text += page_text

        print("TOTAL PDF TEXT LENGTH:", len(text))
        return text

    else:
        raise Exception("Unsupported file type")


def chunk_text(text, chunk_size=500, overlap=50):
    print("CHUNKING START")

    chunks = []
    start = 0
    n = len(text)

    while start < n:
        end = start + chunk_size
        chunk = text[start:end]
        chunks.append(chunk)
        start += chunk_size - overlap

    print("TOTAL CHUNKS CREATED:", len(chunks))
    return chunks


def save_file(file, uploaded_by):
    print("\n=== UPLOAD START ===")

    file_id = str(uuid.uuid4())
    ext = file.filename.split(".")[-1].lower()
    path = os.path.join(UPLOAD_DIR, f"{file_id}.{ext}")

    print("FILE NAME:", file.filename)
    print("SAVED PATH:", path)
    print("UPLOADED_BY:", uploaded_by)

    # Save file locally
    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    print("FILE SAVED SUCCESSFULLY")

    # Extract text
    content = read_file_content(path, ext)

    if not content:
        print("ERROR: CONTENT EMPTY")
        return file_id, ext

    print("CONTENT LENGTH:", len(content))

    # Split into chunks
    chunks = chunk_text(content)
    total_chunks = len(chunks)

    if total_chunks == 0:
        print("ERROR: NO CHUNKS CREATED")
        return file_id, ext

    # Prepare rows
    rows = []

    for i, chunk in enumerate(chunks):
        print(f"\nPROCESSING CHUNK {i}")

        embedding = embed_message(chunk)

        # Fix numpy → list issue
        if hasattr(embedding, "tolist"):
            embedding = embedding.tolist()

        print("EMBED TYPE:", type(embedding))
        print("EMBED LENGTH:", len(embedding))

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

    print("\nTOTAL ROWS PREPARED:", len(rows))

    # Insert into Supabase
    if rows:
        print("INSERTING INTO DATABASE...")
        res = client.table("embeddings_v2").insert(rows).execute()
        print("INSERT RESPONSE:", res)
    else:
        print("ERROR: NO ROWS TO INSERT")

    print("=== UPLOAD END ===\n")

    return file_id, ext