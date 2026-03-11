from dotenv import load_dotenv
import os

load_dotenv()

# Supabase configuration
SUPABASE_URL = os.getenv("url")
SUPABASE_KEY = os.getenv("key")
MATCH_COUNT = 5

# Gemini configuration
DEEPSEEK_API_KEY = os.getenv("openrouter_api_key")