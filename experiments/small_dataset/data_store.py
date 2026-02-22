"""
Reads all TXT files from /data folder
Chunks text
Generates embeddings
Stores into postgres true_embedding_test
"""

import os
import psycopg2
from google import genai
from google.genai import types

# -------- SETTINGS ----------
DATA_FOLDER = "data_source"  
CHUNK_SIZE = 500

# -------- GEMINI ----------
client = genai.Client(api_key="AIzaSyDY5vLW-OvuiY8loqB-5Mu3hvq4ccouQxk")

# -------- POSTGRES ----------
conn = psycopg2.connect(
    host="localhost",
    database="testdb",
    user="postgres",
    password="7870",
    port="5432"
)
cur = conn.cursor()

# -------- CHUNK FUNCTION ----------
def chunk_text(text, size=CHUNK_SIZE):
    words = text.split()
    chunks = []
    for i in range(0, len(words), size):
        chunks.append(" ".join(words[i:i+size]))
    return chunks

# -------- READ FILES ----------
files = [f for f in os.listdir(DATA_FOLDER) if f.endswith(".txt")]

print(f"\nFound {len(files)} txt files\n")

total_chunks = 0

for file in files:
    path = os.path.join(DATA_FOLDER, file)

    with open(path, "r", encoding="utf-8") as f:
        text = f.read()

    chunks = chunk_text(text, CHUNK_SIZE)

    print(f"{file} → {len(chunks)} chunks")

    # ---- generate embeddings batch ----

    response = client.models.embed_content(
        model="gemini-embedding-001",
        contents=chunks,
        config=types.EmbedContentConfig(task_type="RETRIEVAL_DOCUMENT")
    )

    embeddings = [e.values for e in response.embeddings]

    # ---- store ----
    for idx, (chunk, emb) in enumerate(zip(chunks, embeddings)):
        cur.execute(
        """
        INSERT INTO embed_from_file (content, embedding, source, chunk_index)
        VALUES (%s, %s, %s, %s)
        """,
        (chunk, str(emb), file, idx)
    )
    total_chunks += 1

    conn.commit()
    print(f"Stored from {file}\n")

cur.close()
conn.close()

print(f"\nDone.")
print(f"Total chunks stored: {total_chunks}")
