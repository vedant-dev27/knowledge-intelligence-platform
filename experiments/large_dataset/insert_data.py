import os
import time
from sentence_transformers import SentenceTransformer

# -------- SETTINGS ----------
DATA_FOLDER = "dataset/talks"
CHUNK_SIZE = 500
EMBED_BATCH_SIZE = 100   # change anytime for testing

# -------- LOAD MODEL ----------
print("Loading embedding model...")
model = SentenceTransformer(
    "nomic-ai/nomic-embed-text-v1",
    trust_remote_code=True,
    local_files_only=True
)
print("Model loaded\n")

# -------- CHUNK FUNCTION ----------
def chunk_text(text, size=CHUNK_SIZE):
    words = text.split()    for i in range(0, len(words), size):
        yield " ".join(words[i:i+size])

# -------- FILES ----------
files = [f for f in os.listdir(DATA_FOLDER) if f.endswith(".txt")]
print(f"Found {len(files)} files\n")

global_chunk = 0

# -------- PROCESS ----------
for file in files:
    path = os.path.join(DATA_FOLDER, file)
    print(f"\n========== FILE: {file} ==========")

    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        text = f.read()

    total_chunks = len(text.split()) // CHUNK_SIZE + 1
    print(f"Total chunks: {total_chunks}\n")

    buffer = []
    buffer_ids = []

    for chunk in chunk_text(text):
        global_chunk += 1

        print(f"[CHUNK CREATED] #{global_chunk}")

        buffer.append(chunk)
        buffer_ids.append(global_chunk)

        print(f"[QUEUED] chunk {global_chunk} added to batch ({len(buffer)}/{EMBED_BATCH_SIZE})")

        # -------- SEND BATCH ----------
        if len(buffer) >= EMBED_BATCH_SIZE:
            start = buffer_ids[0]
            end = buffer_ids[-1]

            print(f"\n>>> SENDING TO MODEL: chunks {start} → {end}")
            t0 = time.time()

            embeddings = model.encode(
                buffer,
                batch_size=EMBED_BATCH_SIZE,
                normalize_embeddings=True,
                show_progress_bar=False
            )

            t1 = time.time()
            print(f"<<< MODEL RETURNED ({round(t1-t0,2)} sec)\n")

            # -------- PER CHUNK COMPLETE ----------
            for cid in buffer_ids:
                print(f"[EMBEDDED ✔] chunk {cid}")

            print(f"[BATCH COMPLETE] {start} → {end}\n")

            buffer.clear()
            buffer_ids.clear()

    # -------- LEFTOVER ----------
    if buffer:
        start = buffer_ids[0]
        end = buffer_ids[-1]

        print(f"\n>>> SENDING FINAL BATCH: chunks {start} → {end}")
        t0 = time.time()

        embeddings = model.encode(
            buffer,
            batch_size=EMBED_BATCH_SIZE,
            normalize_embeddings=True,
            show_progress_bar=False
        )

        t1 = time.time()
        print(f"<<< FINAL RETURNED ({round(t1-t0,2)} sec)\n")

        for cid in buffer_ids:
            print(f"[EMBEDDED ✔] chunk {cid}")

        print(f"[FINAL BATCH COMPLETE] {start} → {end}\n")

    print(f"========== FINISHED FILE: {file} ==========\n")

print("🔥 ALL FILES COMPLETED 🔥")
