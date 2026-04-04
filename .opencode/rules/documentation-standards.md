# Documentation Standards

All documentation must follow these standards.

## README

Every project MUST have a README with:

1. **Project name and one-line description**
2. **Prerequisites** — required tools, versions, access
3. **Quick Start** — working example in 5 minutes or less
4. **Available scripts/commands** — what they do
5. **Project structure** — key directories
6. **Configuration** — environment variables, config files
7. **Testing** — how to run tests
8. **Deployment** — how to deploy
9. **Contributing** — link to CONTRIBUTING.md or brief guide

## API Documentation

- Document every endpoint
- Include request/response examples
- Document authentication requirements
- Specify rate limits
- Note breaking changes and deprecations
- Use OpenAPI/Swagger when possible
- Keep documentation in sync with code

## Inline Code Documentation

- Docstrings for all public functions, classes, and methods
- Use language-appropriate format (JSDoc, TSDoc, Godoc, Rustdoc)
- Document parameters, return values, and exceptions
- Include usage examples for complex functions
- Explain WHY, not WHAT — code shows what

## Architecture Documentation

- Architecture Decision Records (ADRs) for significant decisions
- System architecture diagrams (Mermaid)
- Data flow diagrams
- Deployment architecture
- Dependency diagrams

## Changelog

- Follow Keep a Changelog format
- Group by type: Added, Changed, Deprecated, Removed, Fixed, Security
- Include dates in ISO 8601 format
- Never edit released versions
- Link versions to git tags

## Contributing Guide

- Getting started instructions
- Code style and conventions
- PR process and requirements
- Testing requirements
- Commit message format
- How to report bugs

## General Rules

- Write for the reader, not the writer
- Keep documentation current — outdated docs are worse than no docs
- Use plain language — avoid jargon
- Include examples — show, don't just tell
- Use consistent formatting
- Use headings and lists for scannability
- Link to related documentation
- Review documentation as part of code review
