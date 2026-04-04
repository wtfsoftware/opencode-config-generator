---
description: Suggest refactoring improvements for the selected code
agent: build
---
Analyze the selected code and suggest refactoring improvements.

Look for:
1. **Code smells** — long methods, large classes, duplication, deep nesting, magic values, god classes
2. **Design improvements** — extract functions, replace conditionals with polymorphism, composition over inheritance, SOLID principles
3. **Modern patterns** — language-specific modern features, built-in utilities, simplified expressions

For each suggestion:
- Show the before and after code
- Explain why the change improves the code
- Note any trade-offs

Focus on high-impact changes first. Don't suggest purely cosmetic changes.
