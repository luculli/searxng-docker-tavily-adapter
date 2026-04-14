# SearXNG Docker Tavily Adapter

**Free Tavily API replacement powered by SearXNG** 🔍

Use SearXNG with the exact same API as Tavily - no limits, no API keys, full privacy!

> 🎯 **Ready Docker Compose stack** with SearXNG + Tavily-compatible API adapter

## 🚀 Quick Start

```bash
# 1. Clone
git clone git@github.com:vakovalskii/searxng-docker-tavily-adapter.git
# or HTTPS: git clone https://github.com/vakovalskii/searxng-docker-tavily-adapter.git
cd searxng-docker-tavily-adapter

# 2. Configure
cp config.example.yaml config.yaml
# Change secret_key in config.yaml

# 3. Run
docker compose up -d

# 4. Test
curl -X POST "http://localhost:8000/search" \
     -H "Content-Type: application/json" \
     -d '{"query": "bitcoin price", "max_results": 3}'
```

## 💡 Usage

### Drop-in Tavily replacement

```python
# Install the original Tavily client
pip install tavily-python

from tavily import TavilyClient

# Just change the base_url!
client = TavilyClient(
    api_key="any_value",  # Ignored
    base_url="http://localhost:8000"  # Your adapter
)

# Use as usual
response = client.search(
    query="bitcoin price",
    max_results=5,
    include_raw_content=True
)
```

### Simple API

```python
import requests

response = requests.post("http://localhost:8000/search", json={
    "query": "what is machine learning",
    "max_results": 5,
    "include_raw_content": True
})

results = response.json()
```

## 📦 What's Included

- **SearXNG** (port 8999) - powerful meta search engine
- **Tavily Adapter** (port 8000) - HTTP API compatible with Tavily
- **Redis** - caching for SearXNG
- **Single config** - `config.yaml` for all services

## 🎯 Benefits

| Tavily (original) | SearXNG Adapter |
|-------------------|-----------------|
| 💰 Paid | ✅ Free |
| 🔑 API key required | ✅ No keys needed |
| 📊 Request limits | ✅ No limits |
| 🏢 External service | ✅ Local deployment |
| ❓ Unknown sources | ✅ Control the engines |

## 📋 API

### Request
```json
{
  "query": "search query",
  "max_results": 10,
  "include_raw_content": false
}
```

### Response
```json
{
  "query": "search query",
  "results": [
    {
      "url": "https://example.com",
      "title": "Title",
      "content": "Short description...",
      "score": 0.9,
      "raw_content": "Full page text..."
    }
  ],
  "response_time": 1.23,
  "request_id": "uuid"
}
```

## 🕷️ Raw Content - Web Scraping

### How `include_raw_content` works

```python
# Without raw_content (fast)
response = client.search(
    query="machine learning",
    max_results=3
)
# content = short snippet from search engine
# raw_content = null

# With raw_content (slower, but more data)  
response = client.search(
    query="machine learning", 
    max_results=3,
    include_raw_content=True
)
# content = short snippet from search engine
# raw_content = full page text (up to 2500 characters)
```

### What happens under the hood

1. **SearXNG search** - get URLs and snippets
2. **Parallel scraping** - load HTML of each page
3. **Content cleanup** - remove script, style, nav, footer
4. **Text extraction** - convert HTML to plain text
5. **Truncate to 2500 chars** - optimal size for LLM

### Scraping configuration

In `config.yaml`:

```yaml
adapter:
  scraper:
    timeout: 10                    # Timeout per page (seconds)
    max_content_length: 2500       # Maximum raw_content size
    user_agent: "Mozilla/5.0..."   # User-Agent for requests
```

### Performance

| Mode | Response Time | Data Volume |
|-------|-------------|--------------|
| Without raw_content | ~1-2 sec | Snippets only |
| With raw_content | ~3-5 sec | Full page text |

> 💡 **Tip**: Use `raw_content=True` when you need full context for LLM, and `False` for fast searches.

## ⚙️ Configuration

Detailed instructions: [CONFIG_SETUP.md](CONFIG_SETUP.md)

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Your code     │───▶│  Tavily Adapter  │───▶│     SearXNG     │
│                 │    │   (port 8000)    │    │   (port 8999)   │
│ requests.post() │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │  Web Scraping    │    │ Google, Bing,   │
                       │  (raw_content)   │    │ DuckDuckGo...   │
                       └──────────────────┘    └─────────────────┘
```

## 🔧 Development

```bash
# Local adapter development
cd simple_tavily_adapter
pip install -r requirements.txt
python main.py

# Testing
python test_client.py
```

## 📜 License

MIT License - use however you like! 🎉