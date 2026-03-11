import supabase
from config import SUPABASE_KEY, SUPABASE_URL, MATCH_COUNT

client = supabase.create_client(SUPABASE_URL, SUPABASE_KEY)

def semantic_search(query_vector, match_count=MATCH_COUNT):
    res = client.rpc("match_documents", {
        "query_embedding": query_vector,
        "match_count": match_count
    }).execute()
    return str(res.data)


'''create or replace function match_documents(
  query_embedding vector(768),
  match_count int
)
returns table(
  id bigint,
  content text,
  source_file text,
  similarity float
)
language sql stable
as $$
  select
    id,
    content,
    source_file,
    1 - (embedding <=> query_embedding) as similarity
  from embeddings
  order by embedding <=> query_embedding
  limit match_count;
$$;'''