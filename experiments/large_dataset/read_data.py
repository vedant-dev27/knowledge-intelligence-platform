"""
Query search using LOCAL embeddings (nomic)
Compares query with stored vectors in Postgres
Plots similarity per file
"""

import psycopg2
import ast
import numpy as np
import matplotlib.pyplot as plt
from sentence_transformers import SentenceTransformer

# -------- LOAD MODEL ----------
print("Loading embedding model...")
model = SentenceTransformer(
    "nomic-ai/nomic-embed-text-v1",
    trust_remote_code=True,
    local_files_only=True
)
print("Model loaded\n")

# -------- QUERY ----------
query = input("Enter your search query:\n")
print("\nEmbedding query...\n")

query_vec = model.encode(
    query,
    normalize_embeddings=True
)

# -------- POSTGRES ----------
conn = psycopg2.connect(
    host="localhost",
    database="semantic_search",
    user="postgres",
    password="7870",
    port="5432"
)
cur = conn.cursor()

cur.execute("SELECT embedding, source FROM embed_from_file")
rows = cur.fetchall()

print(f"Loaded {len(rows)} chunks from DB\n")

# -------- COSINE SIM FUNCTION ----------
def cosine_similarity(a, b):
    a = np.array(a)
    b = np.array(b)
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

# -------- COMPUTE SIMILARITY ----------
file_scores = {}

for emb_str, source in rows:
    emb = np.array(ast.literal_eval(emb_str))

    score = cosine_similarity(query_vec, emb)

    if source not in file_scores:
        file_scores[source] = []

    file_scores[source].append(score)

# -------- AVERAGE SCORE PER FILE ----------
avg_scores = {
    file: sum(scores)/len(scores)
    for file, scores in file_scores.items()
}

# sort highest first
sorted_scores = dict(sorted(avg_scores.items(), key=lambda x: x[1], reverse=True))

print("Top matches:\n")
for k, v in list(sorted_scores.items())[:5]:
    print(f"{k} → {v:.4f}")

# -------- PLOT ----------
plt.figure(figsize=(10,5))
plt.bar(sorted_scores.keys(), sorted_scores.values())
plt.xticks(rotation=45, ha="right")
plt.ylabel("Similarity Score")
plt.title("Query vs Files Similarity")
plt.tight_layout()
plt.show()

cur.close()
conn.close()
