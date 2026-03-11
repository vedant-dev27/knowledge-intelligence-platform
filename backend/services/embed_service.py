from sentence_transformers import SentenceTransformer
model=SentenceTransformer(
    "nomic-ai/nomic-embed-text-v1",
    trust_remote_code=True,
    local_files_only=True)

def embed_message(text:str):
    embedding=model.encode(text, normalize_embeddings=True)
    return embedding.tolist()