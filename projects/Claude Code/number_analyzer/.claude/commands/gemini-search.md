---
allowed-tools: Bash(gemini -p:*)
description: Run web search directly using gemini CLI
---

## Gemini Search

`gemini` is google gemini cli. You can use it for web search.

Run web search directly with: `gemini -p "Search for (user's query) and include source URLs for each result"`

**Example Usage:**
```bash
gemini -p "Find 3 articles about Ruby programming language best practices and include source URLs"
```

**Expected Output Format:**
Each search result should include:
- Article title
- Brief summary
- **Source URL** (required)

This ensures search results are properly attributed and users can access the original sources.

