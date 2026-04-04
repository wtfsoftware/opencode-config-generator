---
description: Generate a changelog from recent git commits
agent: build
---
Generate a changelog from recent git commits.

Recent commits:
```
!`git log --oneline -50 2>/dev/null || echo "No git history found"`
```

Format following Keep a Changelog:
```markdown
## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
```

Rules:
- Group by type based on conventional commits prefix
- Write user-facing descriptions, not technical commit messages
- Combine related commits into single entries
- Include issue/PR references if present
- Skip merge commits, CI changes, and chore commits
- Only include meaningful changes

If VERSION file or git tags exist, suggest next semver version.
