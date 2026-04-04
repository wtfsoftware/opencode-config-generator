---
description: Generate comprehensive tests for the selected file
agent: build
---
Generate comprehensive tests for the selected file.

Follow the testing pyramid:
1. **Unit tests** — test individual functions/methods in isolation
   - Happy path, error paths, edge cases (empty, null, boundary)
   - Mock external dependencies
2. **Integration tests** — test module interactions where applicable

Test quality requirements:
- Clear, descriptive test names
- Arrange-Act-Assert structure
- No test interdependencies
- Proper cleanup in teardown

Output the complete test file ready to be saved.
Include the test file path following the project's conventions.
