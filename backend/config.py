from dotenv import load_dotenv
import os

load_dotenv()

# Supabase configuration
SUPABASE_URL = os.getenv("url")
SUPABASE_KEY = os.getenv("key")
MATCH_COUNT = 5

# LLM configuration
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")

# Token configuration
SIGNATURE_KEY=os.getenv("signature_key")