"""
Test to check compatibility with original Tavily API
"""
from tavily_client import TavilyClient

# Compatibility test with original API
client = TavilyClient(api_key="fake-key")  # API key is not used
response = client.search(
    query="price bmw x6",
    include_raw_content=True
)

print("Response:")
print(response)
print("\nResults count:", len(response["results"]))
if response["results"]:
    print("First result URL:", response["results"][0]["url"])
    print("First result title:", response["results"][0]["title"])
