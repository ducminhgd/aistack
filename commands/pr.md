---
description: Clean up code, stage changes, and prepare a pull request
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(npm test:*), Bash(npm run lint:*)
---

# Pull Request/Merge request Preparation Checklist

Before creating a PR/MR, execute these steps:

1. Run linting: `prettier --write .`
2. Run tests
3. Review git diff: `git diff HEAD`
4. Stage changes: `git add .`
5. Create commit message following conventional commits:
   - `fix:` for bug fixes
   - `feat:` for new features
   - `docs:` for documentation
   - `refactor:` for code restructuring
   - `test:` for test additions
   - `chore:` for maintenance

6. Generate PR summary including:
   - What changed
   - Why it changed
   - Testing performed
   - Potential impacts