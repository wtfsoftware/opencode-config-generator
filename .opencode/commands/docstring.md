---
description: Generate docstrings and inline documentation for the selected file
agent: build
---
Generate comprehensive documentation for the selected file.

Add documentation for:
1. **Public functions/methods** — purpose, parameters, return value, exceptions, usage examples
2. **Classes/types** — class purpose, constructor parameters, public method summaries
3. **Modules/files** — module-level docstring describing the file's purpose
4. **Complex inline code** — explain the "why" not the "what", document workarounds and hacks

Use the appropriate format for the language:
- Python: Google-style docstrings
- TypeScript/JavaScript: JSDoc/TSDoc
- Go: Godoc format
- Rust: Rustdoc format

Do NOT document trivial getters/setters, obvious one-liners, or test helpers.
