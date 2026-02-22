---
license: cc-by-sa-4.0
task_categories:
- text-retrieval
- feature-extraction
language:
- en
viewer: false
tags:
- wikipedia
- qdrant
- sparse-embeddings
- splade
- bm25
- vector-database
- semantic-search
size_categories:
- 1M<n<10M
---

# Wikipedia English Embeddings Dataset (Qdrant Snapshot)

![Qdrant Wiki](./logo.png)

This dataset contains a complete [Qdrant vector database](https://qdrant.tech/) snapshot of Wikipedia English articles, each chunked and embedded with both SPLADE and BM25 sparse embeddings, yielding a total of 130M embeddings. Chunks are linked to their neighbors and the main text to make full context retrieval simple and fast. If you'd rather access a hosted version of this (with the latest Wiki updates indexed automatically), head over to the [AskNews API](https://docs.asknews.app/en/wikipedia) for immediate access.
## Dataset Details

### Dataset Description

This dataset provides a ready-to-use Qdrant vector database containing the complete English Wikipedia processed from the Cirrus dump. Each article section has been embedded using both SPLADE (Sparse Lexical and Expansion) and BM25 sparse embedding techniques, enabling hybrid search capabilities that combine lexical and semantic matching.

- **Curated by:** [Emergent Methods](https://emergentmethods.ai)
- **Language(s):** English
- **License:** CC-BY-SA-4.0 (same as Wikipedia)
- **Vector Database:** [Qdrant](https://qdrant.tech/)
- **Embedding Models:**
  - SPLADE: `naver/splade-v3` (Note: example code uses `prithivida/Splade_PP_en_v1` for FastEmbed compatibility)
  - BM25: `Qdrant/bm25` (English)

### Dataset Sources

- **Source Data:** Wikipedia English [Cirrus](https://www.mediawiki.org/wiki/Extension:CirrusSearch) [Dump](https://meta.wikimedia.org/wiki/Data_dumps)
- **Dump file:** [Wikipedia Cirrus English Dump - 20250818](https://dumps.wikimedia.org/other/cirrussearch/20250818/enwiki-20250818-cirrussearch-content.json.gz)
- **Data dumps wikipedia information:** [Data dumps/What the dumps are not](https://meta.wikimedia.org/wiki/Data_dumps/What_the_dumps_are_not)

## Uses

### Direct Use

This dataset is designed for:

- **Semantic Search Applications**: Build Wikipedia search engines with advanced semantic capabilities
- **Research in Information Retrieval**: Experiment with hybrid sparse retrieval methods (SPLADE + BM25)
- **Question Answering Systems**: Use as a knowledge base for RAG (Retrieval-Augmented Generation) pipelines
- **Educational Tools**: Create learning applications that can search and retrieve Wikipedia content contextually
- **Benchmarking**: Compare different retrieval approaches on a large-scale, real-world dataset

### Out-of-Scope Use

- **Real-time Wikipedia Updates**: This snapshot represents Wikipedia at a specific point in time and doesn't include real-time updates
- **Non-English Content**: This dataset only contains English Wikipedia articles

## Dataset Structure

The Qdrant database contains vectors organized in collections with the following structure:

- **Collection Name**: `WIKIPEDIA_ENGLISH`
- **Vector Configurations**:
  - `text-sparse`: SPLADE sparse embeddings for semantic matching
  - `bm25`: BM25 sparse embeddings for lexical matching
- **Payload Key Fields**:
  - `title`: Article title
  - `content`: Text content of the section/chunk
  - `url`: Wikipedia URL
  - `page_id`: Unique Wikipedia page identifier
  - `part`: Chunk number for multi-part articles
  - `partial`: Boolean indicating if this is a partial chunk
  - `is_main_section`: Boolean indicating if this is the opening section
  - `is_full_article_content`: Boolean indicating if this contains the full article
  - `categories`: Array of Wikipedia categories
  - `cirrus_metadata`: Metadata from Wikipedia Cirrus dump (available on first part)
  - `point_id`: Unique identifier for this vector point
  - `point_id_list`: Array of all point IDs for this article (in order)
  - `point_id_full_page`: Point ID containing the complete article content
  - `point_id_main_section`: Point ID containing the main section content
  - `timestamp`: Processing timestamp

### Payload Example

Here's an example of the payload structure for a Wikipedia article chunk:

```json
{
  "content": "George Lincoln\n\nGeorge Arthur Lincoln (July 20, 1907 - May 24, 1975) was an American military leader who served as a top general staff strategist in the United States Army during World War II. He was the principal planner of George C. Marshall's military campaigns in Europe and Asia including the planned invasion of Japan...",
  "title": "George Lincoln",
  "partial": true,
  "part": 1,
  "is_main_section": false,
  "page_id": 77221610,
  "is_full_article_content": true,
  "url": "https://en.wikipedia.org/wiki/George_Lincoln",
  "is_auxiliary_text": false,
  "has_main_section": true,
  "categories": [
    "1907 births",
    "1975 deaths",
    "United States Military Academy alumni",
    "American Rhodes Scholars"
  ],
  "main_section_full_content": "George Lincoln\n\nGeorge Arthur Lincoln (July 20, 1907 - May 24, 1975) was an American military leader who served as a top general staff strategist in the United States Army during World War II...",
  "cirrus_metadata": {
    "create_timestamp": "2024-06-25T01:12:36Z",
    "wikibase_item": "Q64021536",
    "version": 1302664502,
    "popularity_score": 4.1384013852057126e-8,
    "text_bytes": 6083,
    "...other fields": "other fields"
  },
  "timestamp": "2025-07-26T21:10:52Z",
  "point_id": "20141ac6-7604-4b38-926e-2d46aa2426b5",
  "point_id_list": [
    "a2677d36-eddd-424d-abea-2095808f2930",
    "20141ac6-7604-4b38-926e-2d46aa2426b5",
    "3a7436ec-f649-4b69-97ff-10ee6e6f931c",
    "1e068aed-3c47-48a6-9f2d-d7f1c4c21b2c",
    "6c701bf6-dd3f-43d3-bc71-2a3e2332075a"
  ],
  "point_id_full_page": "20141ac6-7604-4b38-926e-2d46aa2426b5",
  "point_id_main_section": "a2677d36-eddd-424d-abea-2095808f2930",
  "full_article_content": "George Arthur Lincoln...",
  "...other fields": "other fields"
}
```

**Key payload fields explained:**

- `title`: Article title
- `content`: Text content of the section/chunk (max 500 tokens)
- `url`: Wikipedia URL
- `page_id`: Unique Wikipedia page identifier
- `part`: Chunk number for multi-part articles
- `partial`: Boolean indicating if this is a partial chunk
- `is_main_section`: Boolean indicating if this is the opening section
- `is_full_article_content`: Boolean indicating if this contains the full article field
- `categories`: Array of Wikipedia categories
- `cirrus_metadata`: Metadata from Wikipedia Cirrus dump (available on first part)
- `timestamp`: Processing timestamp
- `point_id_list`: Contains point IDs of all chunks for this article in sequential order, useful for finding neighboring text segments
- `point_id_full_page`: References the point ID containing the complete article content
- `point_id_main_section`: References the point ID containing the main section (opening text) content
- `full_article_content`: Full article text. Available only if `is_full_article_content = true`.

## Getting Started

### Download and Setup

1. **Download the dataset parts**:

   ```bash
   # Download all snapshot parts from Hugging Face
   huggingface-cli download EmergentMethods/en_qdrant_wikipedia --local-dir ./qdrant-snapshot
   ```

2. **Reconstruct the snapshot**:

   ```bash
   # Combine the snapshot parts
   cat wikipedia-en-qdrant-2025-09-03.snapshot.part* > wikipedia-en-qdrant-2025-09-03.snapshot
   ```

3. **Restore to Qdrant**:

   Follow the [Qdrant Snapshot Restore Documentation](https://qdrant.tech/documentation/concepts/snapshots/#restore-snapshot) to restore the snapshot to your Qdrant instance.

### Usage Example

Here's a complete example showing how to search the Wikipedia embeddings using SPLADE, BM25, and hybrid approaches:

```python
import os
from typing import List, Optional

from dotenv import load_dotenv
from fastembed import SparseTextEmbedding
from fastembed.sparse.bm25 import Bm25
from qdrant_client import QdrantClient, models

COLLECTION_NAME = 'WIKIPEDIA_ENGLISH'  # existing Qdrant collection
SPLADE_MODEL = 'prithivida/Splade_PP_en_v1'  # original: 'naver/splade-v3'
BM25_MODEL = 'Qdrant/bm25'  # fastembed BM25 model card
BM25_LANGUAGE = 'english'

TOPK_SPLADE = 3
TOPK_BM25 = 3
TOPK_FUSED = 5
PREFETCH_PER_MODEL = 20  # how many raw candidates each model contributes before fusion

load_dotenv()


def build_qdrant_client() -> QdrantClient:
    url = os.getenv('QDRANT_URL', 'http://localhost:6333')
    api_key = os.getenv('QDRANT_API_KEY')  # may be None / empty for local

    if 'localhost' in url or '127.0.0.1' in url:
        return QdrantClient(url=url, api_key=api_key)

    return QdrantClient(url=url, https=True, timeout=60, api_key=api_key)


class HybridSparseSearcher:
    """Encapsulates SPLADE, BM25, and hybrid (RRF) query logic."""

    def __init__(self) -> None:
        self.client = build_qdrant_client()
        self.splade = SparseTextEmbedding(model_name=SPLADE_MODEL, device='cpu')
        self.bm25 = Bm25(BM25_MODEL, language=BM25_LANGUAGE)

    # ------------------------ Individual Model Searches ------------------
    def _splade_query_vector(self, text: str) -> models.SparseVector:
        sparse_obj = next(self.splade.embed(text))
        return models.SparseVector(**sparse_obj.as_object())

    def _bm25_query_vector(self, text: str) -> models.SparseVector:
        sparse_obj = next(self.bm25.query_embed(text))
        return models.SparseVector(**sparse_obj.as_object())

    def search_splade(self, query: str, limit: int = TOPK_SPLADE):
        vector = self._splade_query_vector(query)
        return self.client.query_points(
            collection_name=COLLECTION_NAME,
            query=vector,
            using='text-sparse',
            limit=limit,
        ).points

    def search_bm25(self, query: str, limit: int = TOPK_BM25):
        vector = self._bm25_query_vector(query)
        return self.client.query_points(
            collection_name=COLLECTION_NAME,
            query=vector,
            using='bm25',
            limit=limit,
        ).points

    def search_hybrid_rrf(
        self, query: str, limit: int = TOPK_FUSED, per_model: int = PREFETCH_PER_MODEL
    ):
        prefetch = [
            models.Prefetch(
                query=self._splade_query_vector(query),
                using='text-sparse',
                limit=per_model,
            ),
            models.Prefetch(
                query=self._bm25_query_vector(query), using='bm25', limit=per_model
            ),
        ]
        return self.client.query_points(
            collection_name=COLLECTION_NAME,
            prefetch=prefetch,
            query=models.FusionQuery(fusion=models.Fusion.RRF),
            limit=limit,
        ).points

    @staticmethod
    def _format(point) -> str:
        payload = point.payload or {}
        title = payload.get('title', '<no title>')
        section = payload.get('title_section', 'Main')
        url = payload.get('url')
        content = (payload.get('content') or '').strip().replace('\n', ' ')
        if len(content) > 220:
            content = content[:220] + '...'
        lines = [f'Score: {point.score:.4f}', f'Title: {title} [{section}]']
        if url:
            lines.append(f'URL: {url}')
        lines.append(f'Snippet: {content}')
        return '\n'.join(lines)

    def pretty_print(self, header: str, points: List, limit: Optional[int] = None):
        print('\n' + header)
        print('-' * len(header))
        if not points:
            print('(no results)')
            return
        for idx, p in enumerate(points[: limit or len(points)], 1):
            print(f'\n{idx}. {self._format(p)}')


def run(query: str):
    """Execute the full demo: SPLADE, BM25, Hybrid fused."""
    searcher = HybridSparseSearcher()
    # Individual models
    splade_points = searcher.search_splade(query)
    bm25_points = searcher.search_bm25(query)
    # Hybrid
    hybrid_points = searcher.search_hybrid_rrf(query)

    # Output
    searcher.pretty_print(f'Top {TOPK_SPLADE} SPLADE Results', splade_points)
    searcher.pretty_print(f'Top {TOPK_BM25} BM25 Results', bm25_points)
    searcher.pretty_print(f'Top {TOPK_FUSED} Hybrid (RRF) Results', hybrid_points)


def main():
    query = 'Albert Einstein'
    run(query)


if __name__ == '__main__':
    main()
```

## Dataset Creation

### Curation Rationale

This dataset was created to provide a comprehensive, ready-to-use vector database for Wikipedia English content that supports both traditional lexical search (BM25) and modern semantic search (SPLADE) capabilities. The hybrid approach enables more accurate and diverse search results by combining the strengths of both methods.

### Source Data

#### Data Collection and Processing

- **Source**: Wikipedia English Cirrus dump (JSON format)
- **Processing Pipeline**:
  1. Downloaded Wikipedia Cirrus dump containing structured article data
  2. Extracted and split articles into chunks for granular search
  3. Generated SPLADE sparse embeddings using `naver/splade-v3`
  4. Generated BM25 sparse embeddings using `Qdrant/bm25` with English language settings
  5. Stored in Qdrant vector database with optimized disk indexing

## Bias, Risks, and Limitations

### Known Limitations

- **Temporal Snapshot**: This dataset represents Wikipedia at a specific point in time and may not reflect current information
- **Language Limitation**: Only English Wikipedia content is included

### Recommendations

Users should be aware of these limitations and consider:

- Supplementing with real-time data sources for current information
- Being mindful of potential cultural and geographic biases in search results
- Validating critical information from primary sources
- Considering the vintage of the data when making time-sensitive queries

## Technical Details

### Requirements

- **Qdrant**: Version 1.15+ recommended
- **Python Dependencies**: `qdrant-client`, `fastembed`, `python-dotenv`
- **Hardware**: Minimum 12GB RAM recommended
- **Storage**: Approximately 380GB for the complete database

## Citation

If you use this dataset in your research or applications, please cite:

```bibtex
@dataset{wikipedia_english_qdrant_2025,
  title={Wikipedia English Embeddings Dataset (Qdrant Snapshot)},
  author={Emergent Methods},
  year={2025},
  url={https://huggingface.co/datasets/EmergentMethods/en_qdrant_wikipedia},
  note={Wikipedia content under CC-BY-SA-4.0 license}
}
```

## Dataset Card Contact

For questions, issues, or contributions, please contact [Emergent Methods](https://emergentmethods.ai).
