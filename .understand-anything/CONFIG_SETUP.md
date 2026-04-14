# SearXNG Tavily Adapter

**Tavily-compatible wrapper for SearXNG** - use SearXNG with the same API as Tavily!

## 🚀 Quick Setup

1. **Copy the example configuration:**
   ```bash
   cp config.example.yaml config.yaml
   ```

2. **Edit config.yaml:**
   ```bash
   nano config.yaml
   # or
   code config.yaml
   ```

3. **Must change:**
   - `server.secret_key` - secret key for SearXNG (minimum 32 characters)
   
4. **Optionally configure:**
   - `adapter.searxng_url` - URL to connect to SearXNG
   - `adapter.scraper.user_agent` - User-Agent for scraping
   - `adapter.scraper.max_content_length` - maximum raw_content size

## 💡 Using as a Tavily Replacement

### Option 1: Python Client (local)

```python
# Instead of: from tavily import TavilyClient
from simple_tavily_adapter.tavily_client import TavilyClient

# Use it exactly the same way as original Tavily!
client = TavilyClient()  # No API key needed
response = client.search(
    query="bitcoin price",
    max_results=5,
    include_raw_content=True
)
print(response)
```

### Option 2: Via HTTP API

```python
import requests

response = requests.post("http://localhost:8000/search", json={
    "query": "bitcoin price",
    "max_results": 5,
    "include_raw_content": True
})
print(response.json())
```

### Option 3: Replace base_url in original Tavily

```python
# Install the original client
# pip install tavily-python

from tavily import TavilyClient

# Just change the base_url!
client = TavilyClient(
    api_key="doesn't_matter",  # Key is ignored
    base_url="http://localhost:8000"  # Your adapter
)

response = client.search(
    query="bitcoin price",
    max_results=5,
    include_raw_content=True
)
```

## 🔄 Migration from Tavily

Replace in your code:

```python
# Was:
# client = TavilyClient("tvly-xxxxxxx")

# Now:
client = TavilyClient()  # No API key
# OR
client = TavilyClient(base_url="http://localhost:8000")
```

The rest of the code **remains unchanged**!

## Generating a Secret Key

```bash
# Method 1: Python
python3 -c "import secrets; print(secrets.token_hex(32))"

# Method 2: OpenSSL
openssl rand -hex 32

# Method 3: /dev/urandom
head -c 32 /dev/urandom | xxd -p -c 32
```

## Configuration Structure

```yaml
# SearXNG settings (root level)
use_default_settings: true
server:
  secret_key: "YOUR_SECRET_KEY"
search:
  formats: [html, json, csv, rss]

# Tavily Adapter settings
adapter:
  searxng_url: "http://searxng:8080"
  server:
    port: 8000
  scraper:
    max_content_length: 2500
```

## Running

```bash
docker-compose up -d
```

## ✅ Verify Operation

```bash
# SearXNG
curl "http://localhost:8999/search?q=test&format=json"

# Tavily Adapter  
curl -X POST "http://localhost:8000/search" \
     -H "Content-Type: application/json" \
     -d '{"query": "test", "max_results": 3}'
```

## 📊 Response Format

Fully compatible with Tavily API:

```json
{
  "query": "bitcoin price",
  "follow_up_questions": null,
  "answer": null,
  "images": [],
  "results": [
    {
      "url": "https://example.com",
      "title": "Bitcoin Price",
      "content": "Bitcoin costs $50,000...",
      "score": 0.9,
      "raw_content": "Full page content..."
    }
  ],
  "response_time": 1.23,
  "request_id": "uuid-string"
}
```

## 🎯 Benefits

- ✅ **Free** - no API keys or limits
- ✅ **Privacy** - search through your SearXNG
- ✅ **Compatibility** - exactly the same API as Tavily
- ✅ **Speed** - local deployment
- ✅ **Control** - customize search engines
