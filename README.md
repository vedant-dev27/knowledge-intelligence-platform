# Recall - Knowledge Intelligence Platform

> Ask your documents. Get answers. Instantly.

---

## What is Recall?

Recall lets you upload (or already have) documents and then **ask natural‑language questions** about them. Instead of keyword search it uses semantic embeddings to find the most relevant chunks of your content, then feeds that context to a small LLM hosted via OpenRouter to generate accurate, grounded answers.

Built for the use case where you have a large body of knowledge — research papers, internal docs, notes — and want to query it conversationally rather than manually digging through files.

---

## Architecture

```text
Flutter App (Android/iOS/Web)
        │
        │  POST /chat  { "message": "..." }
        ▼
FastAPI Backend (local or hosted)
        │
        ├── Embed query using nomic-embed-text-v1 (SentenceTransformer)
        ├── Vector similarity search → Supabase (pgvector) via RPC
        ├── Retrieve top‑k context chunks
        └── Send [context + query] → Mistral‑Nemo model through OpenRouter
                │
                ▼
        Response returned to Flutter client
```

**Stack:**

| Layer | Technology |
|---|---|
| Mobile Client | Flutter (Dart) |
| Backend API | FastAPI (Python) |
| Vector Database | Supabase (PostgreSQL + pgvector) |
| Embedding Model | nomic-embed-text-v1 (768‑dim) via sentence-transformers |
| LLM | mistralai/mistral-nemo (via OpenRouter) |
| Hosting | none prescribed – you can run locally or deploy anywhere |

---

## Repository Structure

```
knowledge-intelligence-platform/
├── mobile_app/              # Flutter application
│   └── app/
│       ├── lib/
│       │   ├── main.dart
│       │   ├── screens/
│       │   │   └── chat_screen.dart
│       │   ├── models/
│       │   │   └── chat_message.dart
│       │   └── services/
│       │       ├── chat_service.dart
│       │       └── chat_storage_service.dart
│       └── pubspec.yaml
├── backend/                 # FastAPI backend
│   ├── main.py
│   ├── requirements.txt
│   ├── config.py
│   └── services/            # embedding, search, and LLM helpers
├── experiments/             # Embedding & search scripts
│   ├── large_dataset/
│   └── small_dataset/
└── README.md
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0` (for mobile client)
- Python `>=3.10` (for backend)
- A Supabase project with `pgvector` enabled (for the vector store)
- An OpenRouter API key (for the LLM)

---

### 1. Clone the repo

```bash
git clone https://github.com/vedant-dev27/knowledge-intelligence-platform
cd knowledge-intelligence-platform
```

---

### 2. Backend Setup

```bash
cd backend
pip install -r requirements.txt
```

Create a `.env` file (copy the names from `.env.example` if available) containing:

```env
url=your_supabase_project_url
key=your_supabase_service_role_key
openrouter_api_key=your_openrouter_api_key
```

Run locally:

```bash
uvicorn main:app --reload
```

The API listens on `http://localhost:8000/chat` by default.

---

### 3. Flutter App Setup

```bash
cd mobile_app/app
flutter pub get
```

Edit `lib/services/chat_service.dart` and update `_backendUrl` to point at your running backend (localhost or a deployed endpoint).

Run the app:

```bash
flutter run
```

---

### 4. Embedding Your Documents

There is no automated pipeline in this repo, but you can use the scripts under `experiments/`.
A simple workflow is to encode your text with the same SentenceTransformer model and insert vectors into the `embeddings` table in Supabase. The `match_documents` RPC function shown in the code is used by the backend to perform nearest‑neighbour search.

**Chunking config:** 300‑word chunks with 50‑word overlap are recommended, matching what the experimental scripts assume.

---

## API Reference

### `POST /chat`

Send a natural language query. The backend embeds the query, retrieves the top‑k semantically similar chunks from Supabase, and returns an OpenRouter‑generated answer grounded in that context.

**Request:**
```json
{
  "message": "What are the main findings of the research?"
}
```

**Response:**
```json
{
  "response": "Based on the documents, the main findings are..."
}
```

**Errors:**

| Code | Meaning |
|---|---|
| `400` | Empty or missing message |
| `500` | Embedding or LLM failure |
| `503` | Database unreachable |

---

## Database Schema

```sql
CREATE TABLE embeddings (
  id          BIGSERIAL PRIMARY KEY,
  content     TEXT NOT NULL,
  embedding   VECTOR(768),
  source_file TEXT,
  chunk_index INTEGER,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX ON embeddings
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

The backend uses the following RPC function for similarity search:

```sql
CREATE OR REPLACE FUNCTION match_documents(
  query_embedding vector(768),
  match_count int
)
RETURNS TABLE(
  id bigint,
  content text,
  source_file text,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    id,
    content,
    source_file,
    1 - (embedding <=> query_embedding) AS similarity
  FROM embeddings
  ORDER BY embedding <=> query_embedding
  LIMIT match_count;
$$;
```

---

## Features

- [x] Document ingestion pipeline (PDF, TXT, CSV, Excel, images via OCR) – scripts available in `experiments/`
- [x] Semantic chunking with overlap
- [x] Vector embeddings stored in Supabase (pgvector)
- [x] FastAPI backend with `/chat` endpoint
- [x] Flutter mobile client with chat UI and local history (Hive)
- [x] OpenRouter/Mistral‑Nemo for context‑grounded answers
- [ ] User authentication (OAuth2 / JWT) — in progress
- [ ] Document upload endpoint — planned
- [ ] Multi‑user support — planned

---

## Deployment

No deployment tooling is included; run the backend anywhere that can reach Supabase and an OpenRouter key. The mobile client can be built in the usual Flutter way:

```bash
flutter build apk --release
```

---

## Security Notes

- All API keys are stored as environment variables — never committed to the repository
- Supabase connection uses the service role key server‑side only; the Flutter app never touches the database directly
- Input validation and rate limiting are on the roadmap (see Issues)

---

## License

MIT — see [LICENSE](LICENSE)

---
