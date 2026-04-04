---
description: Review code for quality, bugs, security, and best practices
agent: build
---
Review the selected code or current file thoroughly.

Check for:
1. **Correctness** — bugs, logic errors, edge cases, off-by-one errors
2. **Security** — injection, data exposure, auth issues, hardcoded secrets
3. **Performance** — N+1 queries, unnecessary computation, memory leaks
4. **Readability** — naming, complexity, deep nesting, magic values
5. **Best Practices** — language/framework conventions, design patterns
6. **Testing** — missing test coverage, untested edge cases

For each issue found:
- State the file and line number
- Explain the problem clearly
- Provide a concrete fix with code

Prioritize by severity: blocker > major > minor > nitpick.
End with an overall quality assessment.
