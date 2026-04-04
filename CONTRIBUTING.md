# Contributing to ocskills

Thank you for contributing to the opencode skills collection!

## Quick Start

1. Fork the repository
2. Create a branch: `git checkout -b skill/my-new-skill`
3. Create your skill in `.opencode/skills/<name>/SKILL.md`
4. Validate: `bash install-skills.sh --dry-run --skill <name> /tmp/test`
5. Commit with conventional commits: `git commit -m "feat: add my-new-skill skill"`
6. Push and open a PR

## Creating a New Skill

1. Create directory: `.opencode/skills/<name>/`
2. Create `SKILL.md` with frontmatter:

```yaml
---
name: my-skill-name
description: Clear description of what this skill does (at least 10 words)
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
  category: framework
---
```

3. Add required sections:
   - `## What I Do` — brief description
   - Core content sections with code examples
   - `## When to Use Me` — usage scenarios
   - `## Quality Checklist` — 8+ actionable items

## Skill Requirements

- **Name**: lowercase alphanumeric with hyphens, 1-64 chars
- **Description**: 10+ words, specific enough for agent to choose correctly
- **Code examples**: Practical, relevant examples in the appropriate language
- **Quality checklist**: At least 8 actionable items
- **Sections**: Must have "What I Do", "When to Use Me", "Quality Checklist"

## Validation

Run the validation script before submitting:

```bash
bash install-skills.sh --list
bash install-skills.sh --dry-run --all /tmp/test-project
```

Or use the CI workflow which runs automatically on PRs.

## Commit Messages

Follow Conventional Commits:

```
feat: add rust-master skill
fix: correct code examples in python-master
docs: update README with new skills
ci: add validation workflow
```

## Project Structure

```
.opencode/
├── skills/          # All skills (SKILL.md files)
├── commands/        # Custom slash commands
├── rules/           # Global rules
├── agents/          # Custom agents
├── scripts/         # Utility scripts
├── templates/       # Project-specific opencode.json templates
├── prompts/         # Agent prompt files
└── plans/           # Implementation plans
.github/
├── workflows/       # CI/CD workflows
└── ISSUE_TEMPLATE/  # Issue templates
install-skills.sh    # Skills installer
REGISTRY.md          # Skills catalog
```

## Need Help?

- Check existing skills for examples
- Read the [REGISTRY.md](REGISTRY.md) for the full catalog
- Open an issue for questions
