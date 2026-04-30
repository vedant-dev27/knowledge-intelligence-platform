# services/upload_service.py

import os
import uuid
import shutil

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

def save_file(file):
    file_id = str(uuid.uuid4())
    ext = file.filename.split(".")[-1].lower()
    path = os.path.join(UPLOAD_DIR, f"{file_id}.{ext}")

    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return file_id, ext

