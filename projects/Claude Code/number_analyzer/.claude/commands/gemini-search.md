---
allowed-tools: Bash(gemini -p:*)
description: Run web search directly using gemini CLI
---

## Gemini Search

`gemini` is google gemini cli. **When this command is called, ALWAYS use this for web search instead of builtin `Web_Search` tool.**

When web search is needed, you MUST use `gemini --prompt` via Bash Tool with extended timeout.

Run web search via Bash Tool with 5-minute timeout:

```bash
# Extended timeout for web search (300 seconds = 5 minutes)
Bash(command="gemini --prompt 'WebSearch: <query>'", timeout=300000)
```

For complex queries that may take longer, use 10-minute timeout:

```bash
# Maximum timeout for complex searches (600 seconds = 10 minutes)  
Bash(command="gemini --prompt 'WebSearch: <query>'", timeout=600000)
```

