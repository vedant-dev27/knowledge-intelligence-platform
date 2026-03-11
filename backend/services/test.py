"""
Query search using LOCAL embeddings (nomic)
Compares query with stored vectors in Supabase
Plots similarity per file
"""

'''
from config import GEMINI_API_KEY
from google import genai

client = genai.Client(api_key=GEMINI_API_KEY)

# List available models (optional debugging)
"""
for m in client.models.list():
    print(m.name)
"""

SYSTEM_PROMPT = """
You are an AI assistant that answers questions using the provided context.
Use ONLY the information from the context to answer the question.
If the answer cannot be found in the context, respond with:
"I could not find the answer in the knowledge base."
"""

def gen_ans(context, question):

    pts = SYSTEM_PROMPT + f"""

Context:
{context}

Question:
{question}

Answer:
"""

    """
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=pts
    )
    return response.text
    """

    return pts

'''

import ast
import numpy as np
import matplotlib.pyplot as plt
from sentence_transformers import SentenceTransformer
from supabase import create_client

# -------- SUPABASE SETUP ----------
url = "https://mlicimquticugtlpguqy.supabase.co"
key = "sb_publishable_oSVIpRr4yBKGIEYPVjlNmA_VI_TG8RF"

supabase = create_client(url, key)

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

query_vec = model.encode(query, normalize_embeddings=True)

# -------- FETCH EMBEDDINGS FROM SUPABASE ----------
rows = (
    supabase
    .table("embeddings")
    .select("embedding, source_file")
    .range(0, 999)
    .execute()
    .data
)

print(f"Loaded {len(rows)} chunks from Supabase\n")

# -------- COSINE SIM FUNCTION ----------
def cosine_similarity(a, b):
    a = np.array(a)
    b = np.array(b)
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

# -------- COMPUTE SIMILARITY ----------
file_scores = {}

for row in rows:

    emb = np.array(ast.literal_eval(row["embedding"]))
    source = row["source_file"]

    score = cosine_similarity(query_vec, emb)

    if source not in file_scores:
        file_scores[source] = []

    file_scores[source].append(score)

# -------- AVERAGE SCORE PER FILE ----------
avg_scores = {
    file: sum(scores)/len(scores)
    for file, scores in file_scores.items()
}

sorted_scores = dict(
    sorted(avg_scores.items(), key=lambda x: x[1], reverse=True)
)

# -------- PRINT RESULTS ----------
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