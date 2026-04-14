# SearXNG Tavily Adapter - Onboarding Guide

> **Generated from knowledge graph analysis** — Commit: `1463642`

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Layers](#architecture-layers)
3. [Key Concepts](#key-concepts)
4. [Guided Tour](#guided-tour)
5. [File Map](#file-map)
6. [Complexity Hotspots](#complexity-hotspots)

---

## Project Overview

### What is This Project?

A free, self-hosted Tavily API replacement powered by SearXNG. It provides a Tavily-compatible search API with **zero cost**, **no request limits**, and **full privacy**.

### Core Value Proposition

| Tavily (original) | SearXNG Adapter |
|-------------------|-----------------|
| 💰 Paid / API key required | ✅ Free / No keys needed |
| 📊 Request limits | ✅ Unlimited requests |
| 🏢 External SaaS | ✅ Self-hosted / Local deployment |
| ❓ Unknown data sources | ✅ Control search engines |

### Tech Stack

- **Language:** Python 3.11
- **Frameworks:** FastAPI, aiohttp, Pydantic
- **Infrastructure:** Docker, uvicorn
- **Backend:** SearXNG (meta-search engine)

---

## Architecture Layers

The project follows a clean layered architecture:

### 1. Api-Layer

**Purpose:** FastAPI endpoints, request/response models — the public API interface

**Key Files:**
- [`main.py`](/workspace/simple_tavily_adapter/main.py) — FastAPI server that provides Tavily-compatible API using SearXNG backend

**Responsibilities:**
- HTTP endpoints for search requests
- Request validation with Pydantic models
- Response formatting
- Web scraping orchestration for `raw_content`

### 2. Service-Layer

**Purpose:** Core business logic — Tavily client implementation

**Key Files:**
- [`tavily_client.py`](/workspace/simple_tavily_adapter/tavily_client.py) — Tavily-compatible client for SearXNG

**Responsibilities:**
- Implement TavilyClient interface
- Search query processing
- Result formatting
- Client-side caching (via aiohttp)

### 3. Config-Layer

**Purpose:** Configuration management and external dependencies

**Key Files:**
- [`config_loader.py`](/workspace/simple_tavily_adapter/config_loader.py) — Configuration loader for Tavily adapter using YAML

**Responsibilities:**
- Load and validate `config.yaml`
- Parse SearXNG settings
- Parse adapter/scraping settings
- Manage secrets and URLs

### 4. Infra-Layer

**Purpose:** Infrastructure and deployment configuration

**Key Files:**
- [`Dockerfile`](/workspace/Dockerfile) — Docker build configuration
- [`requirements.txt`](/workspace/requirements.txt) — Python dependencies

**Responsibilities:**
- Containerization
- Dependency management
- Environment setup

### 5. Data-Layer

**Purpose:** Data definitions and knowledge graph

**Key Files:**
- [`graph_data.json`](/workspace/graph_data.json) — Project structure metadata

**Responsibilities:**
- Project metadata
- Component relationships

---

## Key Concepts

### Tavily-Compatible API

The entire adapter implements the exact same interface as the official `tavily-python` package. This means:

```python
from tavily import TavilyClient

# Works identically to the real Tavily client
client = TavilyClient(
    api_key="any_value",  # Ignored by adapter
    base_url="http://localhost:8000"  # Your adapter
)

response = client.search(
    query="machine learning",
    max_results=5,
    include_raw_content=True  # Full page text extraction
)
```

### Raw Content Scraping

The unique feature of this adapter is the `include_raw_content` parameter:

1. **Without raw_content (fast):** Returns short snippets from SearXNG
2. **With raw_content (slower):** Fetches full HTML, strips navigation/scripts/styles, extracts clean text (up to 2500 characters)

This is useful for LLMs that need complete page context.

### SearXNG as Backend

SearXNG is a federated search engine that aggregates results from multiple sources (Google, DuckDuckGo, Bing, Brave, etc.) into a single API. The adapter leverages this to provide multi-engine search capabilities.

---

## Guided Tour

Follow this learning path to get up to speed:

### Step 1: Project Overview
**Goal:** Understand what the project is and its purpose

**Files to read:**
- [`README.md`](/workspace/README.md) — Complete documentation
- [`graph_data.json`](/workspace/graph_data.json) — Project structure visualization

**Key takeaways:**
- Drop-in Tavily replacement
- Runs on ports 8000 (API) and 8999 (SearXNG)
- Uses Docker Compose for easy deployment

---

### Step 2: Infrastructure Setup
**Goal:** Understand how to install and run dependencies

**Files to read:**
- [`requirements.txt`](/workspace/requirements.txt) — Python packages
- [`Dockerfile`](/workspace/Dockerfile) — Container configuration

**Key commands:**
```bash
# Local development
pip install -r requirements.txt

# Docker deployment
docker compose up -d
```

---

### Step 3: Configuration Management
**Goal:** Learn how configuration is loaded and structured

**File to read:**
- [`config_loader.py`](/workspace/simple_tavily_adapter/config_loader.py)

**Key configuration sections:**
```yaml
# SearXNG settings
server:
  secret_key: "CHANGE_ME"
search:
  formats: [html, json]

# Adapter settings
adapter:
  searxng_url: "http://searxng:8080"
  scraper:
    timeout: 10
    max_content_length: 2500
    user_agent: "Mozilla/5.0 (compatible; TavilyBot/1.0)"
```

---

### Step 4: Core Client Implementation
**Goal:** Understand the main client that provides Tavily-compatible search

**File to read:**
- [`tavily_client.py`](/workspace/simple_tavily_adapter/tavily_client.py)

**Core classes:**
- `TavilyClient` — Main client class implementing Tavily interface
- `TavilyResult` — Single search result model
- `TavilyResponse` — Complete API response model

---

### Step 5: API Endpoints
**Goal:** Understand the FastAPI server and HTTP endpoints

**File to read:**
- [`main.py`](/workspace/simple_tavily_adapter/main.py)

**Key endpoint:**
```python
@app.post("/search")
async def search(request: SearchRequest):
    # Process search query
    # Optionally scrape raw content
    # Return Tavily-compatible response
```

---

### Step 6: Testing and Validation
**Goal:** Learn how to test the client and verify API compatibility

**File to read:**
- [`test_client.py`](/workspace/test_client.py)

**What it tests:**
- Client instantiation
- Basic search functionality
- Response structure validation
- API compatibility with original Tavily

---

## File Map

### Core Application Files

| File | Complexity | Purpose |
|------|-----------|---------|
| [`simple_tavily_adapter/main.py`](/workspace/simple_tavily_adapter/main.py) | **Complex** | FastAPI server with `/search` endpoint, request validation, web scraping orchestration |
| [`simple_tavily_adapter/tavily_client.py`](/workspace/simple_tavily_adapter/tavily_client.py) | **Complex** | TavilyClient implementation that wraps SearXNG and handles response formatting |
| [`simple_tavily_adapter/config_loader.py`](/workspace/simple_tavily_adapter/config_loader.py) | **Complex** | YAML configuration parsing for SearXNG and adapter settings |

### Infrastructure Files

| File | Complexity | Purpose |
|------|-----------|---------|
| [`Dockerfile`](/workspace/Dockerfile) | Simple | Python 3.11 base image with app and dependencies |
| [`requirements.txt`](/workspace/requirements.txt) | Simple | FastAPI, aiohttp, pydantic, and dependencies |

### Testing & Data Files

| File | Complexity | Purpose |
|------|-----------|---------|
| [`test_client.py`](/workspace/test_client.py) | Simple | CLI test script for verifying API compatibility |
| [`graph_data.json`](/workspace/graph_data.json) | Simple | Knowledge graph metadata and project structure |

---

## Complexity Hotspots

These areas require extra attention when reading or modifying code:

### 🔴 High Complexity

1. **`main.py`** — The FastAPI server
   - Multiple async operations (SearXNG calls, parallel web scraping)
   - Request parsing and validation
   - Conditional raw content scraping logic
   - Error handling across multiple failure modes

2. **`tavily_client.py`** — The core client
   - Implements full TavilyClient interface
   - Manages aiohttp session lifecycle
   - Transforms SearXNG results to Tavily format
   - Handles both snippet-only and full-content modes

3. **`config_loader.py`** — Configuration management
   - Nested YAML structure with two sections (server + adapter)
   - Validation of required vs optional settings
   - Default value resolution
   - Environment variable overrides

### 🟡 Medium Complexity

- Pydantic models (`SearchRequest`, `TavilyResult`, `TavilyResponse`) — Understand data contracts between layers
- Docker Compose setup — Service networking and port mapping

### 🟢 Low Complexity

- `test_client.py` — Straightforward CLI script
- `Dockerfile` — Standard Python Dockerfile
- `requirements.txt` — Dependency list

---

## Quick Start Commands

```bash
# 1. Get the project
git clone git@github.com:vakovalskii/searxng-docker-tavily-adapter.git
cd searxng-docker-tavily-adapter

# 2. Configure
cp config.example.yaml config.yaml
# Edit config.yaml (especially secret_key)

# 3. Start with Docker Compose
docker compose up -d

# 4. Test the API
curl -X POST "http://localhost:8000/search" \
     -H "Content-Type: application/json" \
     -d '{"query": "bitcoin price", "max_results": 3}'

# 5. Run local tests
python test_client.py
```

---

## Next Steps

- Read [`CONFIG_SETUP.md`](./CONFIG_SETUP.md) for detailed configuration options
- Explore the knowledge graph in [`knowledge-graph.json`](./knowledge-graph.json)
- Experiment with `include_raw_content=True` to see web scraping in action
- Review Docker Compose services in [`docker-compose.yaml`](../docker-compose.yaml)

---

*Generated on: 2026-04-13*
