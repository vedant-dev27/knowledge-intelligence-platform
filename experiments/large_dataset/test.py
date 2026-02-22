from huggingface_hub import snapshot_download, login

# ---- LOGIN (only first time) ----
login()   # will ask HF token

# ---- DOWNLOAD DATASET ----
snapshot_download(
    repo_id="EmergentMethods/en_qdrant_wikipedia",
    repo_type="dataset",
    local_dir="qdrant-wiki",
    resume_download=True,
    local_dir_use_symlinks=False
)

print("DOWNLOAD COMPLETE")
