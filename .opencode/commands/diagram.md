---
description: Generate Mermaid diagrams from the selected code architecture
agent: build
---
Analyze the selected code or project structure and generate Mermaid diagrams.

Create the most appropriate diagram type(s):
1. **Class/Component Diagram** — for OOP code, show classes, interfaces, relationships
2. **Sequence Diagram** — for request flows, API calls, message passing
3. **Flowchart** — for algorithm logic, decision trees, state machines
4. **Architecture Diagram** — for system overview, service interactions
5. **State Diagram** — for stateful components, lifecycle

Rules:
- Use proper Mermaid syntax
- Keep diagrams readable (max 15 nodes per diagram)
- Use meaningful labels
- Group related elements with subgraphs

Output the Mermaid code blocks ready for rendering.
Explain what each diagram shows.
