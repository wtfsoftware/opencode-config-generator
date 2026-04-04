# Clean Code Rules

These rules apply to all code written in this workspace.

## Naming

- Use meaningful, descriptive names that reveal intent
- Variables: nouns (`userName`, `orderTotal`)
- Functions/methods: verbs (`calculateTotal`, `fetchUser`)
- Booleans: questions or states (`isLoading`, `hasPermission`)
- Avoid abbreviations except well-known ones (`id`, `url`, `db`)
- Avoid misleading names (don't call a list `users` if it's actually `userIds`)
- Use consistent naming conventions per language

## Functions

- Do one thing, do it well, do it only
- Keep functions under 30 lines when possible
- Max 3-4 parameters — use objects for more
- Avoid side effects — be explicit about mutations
- Return early with guard clauses (avoid deep nesting)
- Use descriptive error messages
- Functions should be at one level of abstraction

## Code Structure

- Related code should be together, unrelated code separated
- Use composition over inheritance
- Depend on abstractions, not concretions
- Keep files under 300 lines — split when larger
- Group related functions/modules logically
- Public API first, private helpers below

## Comments

- Code should be self-documenting — prefer clear code over comments
- Comments should explain WHY, not WHAT
- Document public APIs thoroughly
- Document workarounds, hacks, and non-obvious decisions
- Remove commented-out code (version control keeps the history)
- Update comments when code changes

## Simplicity

- Simple is better than complex
- Don't prematurely optimize
- Don't over-engineer — YAGNI (You Ain't Gonna Need It)
- Prefer standard library over custom solutions
- Readability counts — write for humans first, machines second
- Delete dead code, unused imports, and unused variables

## Error Handling

- Handle errors explicitly, never silently ignore them
- Use specific error types, not generic `Exception`
- Include context in error messages (what, where, why)
- Fail fast — validate input early
- Don't use exceptions for control flow
- Log errors with enough context for debugging
