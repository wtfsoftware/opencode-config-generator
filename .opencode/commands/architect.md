---
description: Analyze the project architecture and suggest improvements
agent: build
---
Analyze the project architecture and provide a comprehensive assessment.

Project structure:
```
!`find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/vendor/*' -not -path '*/.next/*' -not -name '*.lock' | head -100`
```

Analyze:

1. **Architecture Pattern:**
   - Identify the current architecture (MVC, layered, hexagonal, microservices, etc.)
   - Is the pattern consistently applied?
   - Are there architectural anti-patterns?

2. **Module Organization:**
   - Is the directory structure logical and scalable?
   - Are responsibilities clearly separated?
   - Are there circular dependencies?
   - Is coupling between modules appropriate?

3. **Layering:**
   - Are presentation, business, and data layers separated?
   - Do dependencies flow in the right direction?
   - Are there layer violations?

4. **Scalability:**
   - Will this structure handle 10x more code?
   - Can new features be added without restructuring?
   - Is it easy for new developers to navigate?

5. **Recommendations:**
   - Specific structural improvements
   - Module extraction opportunities
   - Dependency inversion suggestions
   - Migration path if restructuring is needed

Provide a visual architecture diagram using Mermaid.
Be specific — reference actual directories and files.
