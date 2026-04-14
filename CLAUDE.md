# SearXNG Tavily Adapter

This project is a free Tavily API replacement powered by SearXNG.

## Project Overview

- **Goal**: Provide Tavily-compatible search API with zero cost, no limits, and full privacy
- **Architecture**: FastAPI adapter (port 8000) → SearXNG backend (port 8999) → Multiple search engines
- **Key feature**: `include_raw_content=True` for full page scraping (up to 2500 chars)

## Key Commands

```bash
# Development
docker compose up -d           # Start all services
docker compose logs -f adapter # Watch adapter logs
cd simple_tavily_adapter && python main.py  # Local dev

# Testing
curl -X POST "http://localhost:8000/search" \
     -H "Content-Type: application/json" \
     -d '{"query": "bitcoin price", "max_results": 3}'

python simple_tavily_adapter/test_client.py
```

## Configuration

Single `config.yaml` file with two sections:

```yaml
# SearXNG (root level)
server:
  secret_key: "CHANGE_ME..."
search:
  formats:
    - html
    - json    # Required for API
engines:
  - name: google
    disabled: false

# Adapter (adapter: section)
adapter:
  searxng_url: "http://searxng:8080"
  scraper:
    timeout: 10
    max_content_length: 2500
    user_agent: "Mozilla/5.0 (compatible; TavilyBot/1.0)"
```

## API Usage

```python
from tavily import TavilyClient

# Works identically to official Tavily
client = TavilyClient(base_url="http://localhost:8000")
results = client.search(
    query="machine learning",
    max_results=5,
    include_raw_content=True  # Full page text
)
```

## Development Flow

1. Modify `simple_tavily_adapter/main.py` or `tavily_client.py`
2. Test locally: `python simple_tavily_adapter/main.py`
3. Verify with: `python simple_tavily_adapter/test_client.py`

## Critical Files

- `simple_tavily_adapter/main.py` - FastAPI server implementation
- `simple_tavily_adapter/tavily_client.py` - Python client library
- `simple_tavily_adapter/config_loader.py` - Configuration parsing
- `docker-compose.yaml` - Service orchestration

## Architecture Flow

### System Architecture

```mermaid
graph TB
    subgraph Client["Client Layer"]
        code[Your Code]
        client[TavilyClient]
    end

    subgraph Adapter["Adapter Layer :8000"]
        api["POST /search"]
        parser[Request Parser]
        searxng_client[SearXNG Client]
        scraper[Web Scraper]
    end

    subgraph SearXNG["SearXNG Layer :8999"]
        search[Search Engine]
        results[Results]
    end

    subgraph Sources["Search Engines"]
        google[Google]
        ddg[DuckDuckGo]
        brave[Brave]
    end

    subgraph Scrape["Content Scraping"]
        html[HTML Fetch]
        parse[BeautifulSoup Parser]
        text[Text Extraction]
    end

    code -->|POST /search| client
    client -->|POST JSON| api
    api -->|Parse| parser
    parser -->|JSON Data| searxng_client
    searxng_client -->|POST| search
    search --> results
    results -->|JSON Response| api

    search --> google
    search --> ddg
    search --> brave

    results -->|URLs + Snippets| api
    api -->|If raw_content requested| scraper
    scraper -->|Parallel| html
    html -->|HTML| parse
    parse -->|Cleaned HTML| text
    text -->|Plain Text| api

    api -->|Tavily Response| client
    client -->|Results| code
```

### Request Sequence

```mermaid
sequenceDiagram
    participant User
    participant Client
    participant Adapter
    participant SearXNG
    participant Web

    User->>Client: search("bitcoin price", max_results=5)
    Client->>Adapter: POST /search with JSON
    Adapter->>SearXNG: POST /search (form data)
    SearXNG-->>Adapter: JSON results with URLs + snippets

    alt raw_content requested
        Adapter->>Web: GET each URL (parallel)
        Web-->>Adapter: HTML content
        Adapter->>Adapter: Parse & extract text
        Adapter->>Adapter: Truncate to 2500 chars
    end

    Adapter-->>Client: Tavily-compatible response
    Client-->>User: Search results
```

### Data Flow

```mermaid
flowchart LR
    A[Search Query] --> B{SearXNG}
    B --> C[Engine Results]
    C --> D[URL + Title + Snippet]
    D --> E[Tavily Format]

    F[include_raw_content=True] --> G[Web Scraper]
    G --> H[Fetch HTML]
    H --> I[Remove scripts/styles/nav]
    I --> J[Extract Text]
    J --> K[Truncate 2500 chars]
    K --> E

    E --> L[Final Response]
```
