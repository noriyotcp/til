---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*)
description: Generate git commit message in proper markdown block format
---

## Git Commit Message Generator

**IMPORTANT: Always format commit messages in markdown code blocks.**

This command helps generate properly formatted commit messages following project conventions.

Instructions:
1. Check git status and diff to understand changes
2. Review recent commit messages for style consistency
3. Generate commit message in markdown code block format
4. Present the message for user to copy and use in their own git commit

Format template:
```
[Imperative verb] [brief description]

[Detailed explanation if needed]
- Bullet points for specific changes
- Technical details or rationale

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Remember: commit messages はマークダウンブロックの中に書くこと