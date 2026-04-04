# Testing Standards

These testing standards apply to all code in this workspace.

## Testing Pyramid

- **Unit tests (70%)** — fast, isolated, mock external dependencies
- **Integration tests (20%)** — test module interactions, use real database
- **E2E tests (10%)** — critical user paths only, real browser

## Test Structure

- Use Arrange-Act-Assert (AAA) pattern
- One assertion focus per test (test one thing)
- Tests must be independent — no shared state between tests
- Use descriptive names: `should_return_401_when_token_is_missing`
- Follow Given/When/Then structure for complex tests

## What to Test

- Happy path (expected behavior)
- Error paths (all failure modes)
- Edge cases (empty, null, undefined, boundary values)
- State changes and side effects
- Integration points between modules

## What NOT to Test

- Third-party library code
- Getters/setters without logic
- Simple pass-through functions
- Framework boilerplate
- Implementation details (test behavior, not internals)

## Test Data

- Use factories, not hardcoded values
- Use unique values to avoid collisions (UUIDs, timestamps)
- Clean up test data after each test
- Use test fixtures for common scenarios

## Mocking

- Mock external services (APIs, databases, filesystem)
- Don't mock the unit under test
- Don't mock value objects or simple data
- Scope mocks to individual tests — restore after
- Use spies for verification, stubs for return values

## Coverage Targets

- Unit tests: 80%+ line coverage
- Branch coverage: 70%+
- Focus on critical paths, not arbitrary percentages
- Don't test for the sake of coverage — test for confidence

## CI Integration

- Tests must run on every push/PR
- Fail the build on test failures
- Run tests in parallel when possible
- Set timeout for test suite (max 10 minutes)
- Track flaky tests and fix root causes
