import supabase
from config import SUPABASE_KEY, SUPABASE_URL, MATCH_COUNT

client = supabase.create_client(SUPABASE_URL, SUPABASE_KEY)

def semantic_search(query_vector, user_id, match_count=MATCH_COUNT):
    res = client.rpc("match_documents_v2", {
        "query_embedding": query_vector,
        "match_count": match_count,
        "user_id": user_id
    }).execute()

    return res.data
