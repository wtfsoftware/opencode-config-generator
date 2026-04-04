---
description: Generate a conventional commit message from staged changes
agent: build
---
Generate a conventional commit message from the current staged changes.

Staged changes:
```
!`git diff --cached --stat 2>/dev/null || echo "No staged changes"`
```

Full diff:
```
!`git diff --cached 2>/dev/null || echo "No staged diff"`
```

Follow Conventional Commits format:
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation only
- `style` — formatting, no code change
- `refactor` — code refactoring
- `perf` — performance improvement
- `test` — adding or fixing tests
- `build` — build system or external dependencies
- `ci` — CI/CD configuration
- `chore` — maintenance tasks

Rules:
- Description in imperative mood ("add" not "added")
- No period at the end of the description
- Body explains WHAT and WHY, not HOW
- Max 72 characters per line in body
- Include BREAKING CHANGE: footer if applicable
- Reference related issues with "Refs: #123"

Output ONLY the commit message — ready to copy-paste into `git commit -m "..."`.
