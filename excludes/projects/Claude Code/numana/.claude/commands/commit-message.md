---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*)
description: Generate git commit message in proper markdown block format
---

## Git Commit Message Generator

**IMPORTANT: Always format commit messages in markdown code blocks.**

This command generates properly formatted commit messages following project conventions.

Instructions:
1. Check git status and diff to understand changes
   - Run `git diff --staged` first
   - If staged files exist: Continue to step 2
   - If no staged files: 
     a. Run `git status` to see modified files
     b. Understand current work context
     c. Add appropriate files to staging area with `git add`
     d. Display list of files added to staging
2. Review recent commit messages for style consistency
3. Generate commit message in markdown code block format
4. Present the message for user to copy and use manually

Format template:
```
[Imperative verb] [brief description]

[Detailed explanation if needed]
- Bullet points for specific changes
- Technical details or rationale

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Note: This command only generates messages. The user must run `git commit` manually.**

Remember: commit messages はマークダウンブロックの中に書くこと