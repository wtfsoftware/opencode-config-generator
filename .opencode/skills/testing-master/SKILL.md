---
name: testing-master
description: Write effective tests across the testing pyramid — unit, integration, and E2E. Covers TDD, mocking strategies, test architecture, coverage, and CI optimization.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: fullstack
  category: testing
---

# Testing Master

## What I Do

I help write reliable, maintainable tests that catch real bugs without slowing development. I apply the testing pyramid, TDD practices, and CI optimization to ensure tests are an asset, not a burden.

## Testing Pyramid

```
        /\
       /  \       E2E Tests
      /────\       (Few, critical paths)
     /      \
    /────────\     Integration Tests
   /          \     (API, database, external services)
  /────────────\
 /              \   Unit Tests
/────────────────\  (Many, fast, isolated)
```

### Unit Tests (70%)
- Test individual functions, classes, modules
- No external dependencies (DB, network, filesystem)
- Run in milliseconds
- Mock all external services

### Integration Tests (20%)
- Test interaction between modules
- Use real database (test containers or in-memory)
- Test API endpoints with real request/response cycle
- May mock external third-party services

### E2E Tests (10%)
- Test complete user flows
- Run in real browser
- Cover critical paths only
- Slow and expensive — keep minimal

## Test Naming Conventions

### Pattern: `should [expected behavior] when [condition]`
```typescript
// Good
it('should return 401 when authentication token is missing');
it('should create user and send welcome email when valid data provided');
it('should throw ValidationError when email format is invalid');

// Also good: describe/it structure
describe('UserService', () => {
  describe('createUser', () => {
    it('creates user with valid data');
    it('throws ValidationError for duplicate email');
    it('sends welcome email after successful creation');
  });
});
```

### Pattern: Given/When/Then
```typescript
it('should lock account after 5 failed attempts', () => {
  // Given
  const user = createTestUser({ status: 'active' });

  // When
  for (let i = 0; i < 5; i++) {
    await loginService.login(user.email, 'wrong-password');
  }

  // Then
  const updatedUser = await userService.findById(user.id);
  expect(updatedUser.status).toBe('locked');
});
```

## Arrange-Act-Assert (AAA)

```typescript
it('calculates total price with tax', () => {
  // Arrange
  const cart = new Cart();
  cart.addItem({ price: 100, quantity: 2 });
  cart.addItem({ price: 50, quantity: 1 });

  // Act
  const total = cart.getTotal({ taxRate: 0.1 });

  // Assert
  expect(total).toBe(275); // (200 + 50) * 1.1
});
```

## Mocking Strategies

### What to Mock
- External APIs and services
- Database (in unit tests)
- File system operations
- Time/date (`Date.now()`, timers)
- Random values
- Network requests

### What NOT to Mock
- The unit under test
- Domain logic
- Value objects
- Simple data transformations

### Mock Patterns

**Function Mock**
```typescript
const sendEmail = vi.fn().mockResolvedValue({ success: true });
```

**Module Mock**
```typescript
vi.mock('./emailService', () => ({
  sendEmail: vi.fn().mockResolvedValue({ success: true }),
  sendBulkEmail: vi.fn(),
}));
```

**Partial Mock (Spy)**
```typescript
const spy = vi.spyOn(console, 'error').mockImplementation(() => {});
// ... test code ...
expect(spy).toHaveBeenCalledWith('Error occurred');
spy.mockRestore();
```

**Date/Time Mock**
```typescript
vi.useFakeTimers();
vi.setSystemTime(new Date('2024-01-15T10:00:00Z'));
// ... test code ...
vi.useRealTimers();
```

### Test Doubles Reference
- **Dummy**: Passed but never used
- **Fake**: Working implementation, not for production (in-memory DB)
- **Stub**: Returns pre-configured answers
- **Spy**: Records how it was called
- **Mock**: Pre-programmed with expectations

## Unit Testing

### Pure Functions
```typescript
// Function to test
function calculateDiscount(price: number, userType: 'new' | 'returning'): number {
  if (userType === 'new') return price * 0.9;
  if (price > 100) return price * 0.95;
  return price;
}

// Tests
describe('calculateDiscount', () => {
  it('applies 10% discount for new users', () => {
    expect(calculateDiscount(100, 'new')).toBe(90);
  });

  it('applies 5% discount for returning users with price > 100', () => {
    expect(calculateDiscount(200, 'returning')).toBe(190);
  });

  it('returns full price for returning users with price <= 100', () => {
    expect(calculateDiscount(50, 'returning')).toBe(50);
  });
});
```

### Testing Async Code
```typescript
it('fetches user data from API', async () => {
  const mockFetch = vi.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve({ id: 1, name: 'John' }),
  });
  global.fetch = mockFetch;

  const user = await fetchUser(1);

  expect(user).toEqual({ id: 1, name: 'John' });
  expect(mockFetch).toHaveBeenCalledWith('/api/users/1');
});

it('throws error when API call fails', async () => {
  global.fetch = vi.fn().mockResolvedValue({ ok: false, status: 404 });

  await expect(fetchUser(999)).rejects.toThrow('User not found');
});
```

### Testing Error Handling
```typescript
it('handles network timeout', async () => {
  global.fetch = vi.fn().mockRejectedValue(new Error('Network timeout'));

  await expect(fetchUser(1)).rejects.toThrow('Network timeout');
});

it('validates input before making request', async () => {
  await expect(fetchUser(-1)).rejects.toThrow('Invalid user ID');
  expect(fetch).not.toHaveBeenCalled();
});
```

## Integration Testing

### Database Integration
```typescript
// Use test containers or in-memory database
describe('UserRepository', () => {
  let db: TestDatabase;

  beforeEach(async () => {
    db = await TestDatabase.create();
    await db.runMigrations();
  });

  afterEach(async () => {
    await db.destroy();
  });

  it('persists user to database', async () => {
    const repo = new UserRepository(db.connection);
    const user = await repo.create({ name: 'John', email: 'john@test.com' });

    const found = await repo.findById(user.id);
    expect(found).toBeDefined();
    expect(found.name).toBe('John');
  });

  it('rolls back on constraint violation', async () => {
    const repo = new UserRepository(db.connection);
    await repo.create({ name: 'John', email: 'john@test.com' });

    await expect(
      repo.create({ name: 'John 2', email: 'john@test.com' })
    ).rejects.toThrow();
  });
});
```

### API Integration
```typescript
describe('POST /users', () => {
  it('creates user and returns 201', async () => {
    const response = await request(app)
      .post('/users')
      .send({ name: 'John', email: 'john@test.com' })
      .expect(201);

    expect(response.body).toMatchObject({
      id: expect.any(String),
      name: 'John',
      email: 'john@test.com',
    });
  });

  it('returns 400 for invalid data', async () => {
    const response = await request(app)
      .post('/users')
      .send({ name: '', email: 'invalid' })
      .expect(400);

    expect(response.body.errors).toHaveLength(2);
  });

  it('returns 409 for duplicate email', async () => {
    await request(app).post('/users').send({ name: 'John', email: 'john@test.com' });

    await request(app)
      .post('/users')
      .send({ name: 'Jane', email: 'john@test.com' })
      .expect(409);
  });
});
```

## E2E Testing

### Playwright Best Practices
```typescript
test('complete user registration flow', async ({ page }) => {
  // Navigate to registration
  await page.goto('/register');

  // Fill form
  await page.fill('[name="name"]', 'John Doe');
  await page.fill('[name="email"]', 'john@example.com');
  await page.fill('[name="password"]', 'SecurePass123!');

  // Submit
  await page.click('button[type="submit"]');

  // Verify redirect and welcome message
  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('text=Welcome, John')).toBeVisible();
});
```

### E2E Guidelines
- Test user journeys, not implementation details
- Use real data, not mocks
- One assertion per test when possible
- Use data-testid attributes for selectors
- Avoid testing third-party components
- Keep tests independent — each test starts fresh
- Use page object model for complex flows

### Common E2E Patterns
```typescript
// Page Object
class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.fill('[name="email"]', email);
    await this.page.fill('[name="password"]', password);
    await this.page.click('button[type="submit"]');
  }
}

// Test
test('login with valid credentials', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@test.com', 'password');
  await expect(page).toHaveURL('/dashboard');
});
```

## Test Data Management

### Factories
```typescript
function createUserFactory(overrides = {}) {
  return {
    id: crypto.randomUUID(),
    name: 'Test User',
    email: `user-${crypto.randomUUID()}@test.com`,
    password: 'hashed_password',
    status: 'active',
    createdAt: new Date(),
    ...overrides,
  };
}

// Usage
const adminUser = createUserFactory({ role: 'admin', status: 'active' });
const bannedUser = createUserFactory({ status: 'banned' });
```

### Fixtures
```typescript
// test/fixtures.ts
export const fixtures = {
  users: {
    active: { name: 'Active User', status: 'active' },
    inactive: { name: 'Inactive User', status: 'inactive' },
    admin: { name: 'Admin User', role: 'admin' },
  },
  products: {
    inStock: { name: 'Widget', stock: 100, price: 29.99 },
    outOfStock: { name: 'Gadget', stock: 0, price: 49.99 },
  },
};
```

## Coverage

### What to Measure
- Line coverage: % of lines executed
- Branch coverage: % of branches (if/else) executed
- Function coverage: % of functions called
- Statement coverage: % of statements executed

### Target Coverage
- **Unit tests**: 80-90% line coverage
- **Integration tests**: Focus on critical paths, not coverage %
- **E2E tests**: Don't measure coverage

### What NOT to Test
- Getters/setters without logic
- Third-party library code
- Generated code
- Simple pass-through functions
- Framework boilerplate

### Coverage Gaps to Investigate
- Catch blocks (error paths)
- Edge cases (empty arrays, null, undefined)
- Conditional branches
- Boundary values

## TDD Workflow

### Red-Green-Refactor
1. **Red**: Write a failing test
2. **Green**: Write minimum code to pass
3. **Refactor**: Clean up code, keep tests passing

### Example
```typescript
// 1. RED — Write failing test
it('should return "Fizz" for multiples of 3', () => {
  expect(fizzBuzz(3)).toBe('Fizz');
});

// 2. GREEN — Make it pass
function fizzBuzz(n: number): string {
  if (n % 3 === 0) return 'Fizz';
  return String(n);
}

// 3. Add more tests, refactor
it('should return "Buzz" for multiples of 5', () => { ... });
it('should return "FizzBuzz" for multiples of 15', () => { ... });
```

### TDD Rules
- Write production code only to make a failing test pass
- Write no more of a unit test than sufficient to fail
- Write no more production code than necessary to pass one test

## Performance Testing

### Basic Load Test
```typescript
it('handles 100 concurrent requests', async () => {
  const requests = Array.from({ length: 100 }, () =>
    request(app).get('/api/users').expect(200)
  );

  const start = performance.now();
  const responses = await Promise.all(requests);
  const duration = performance.now() - start;

  expect(duration).toBeLessThan(2000); // Under 2 seconds
  expect(responses.every(r => r.status === 200)).toBe(true);
});
```

## CI Test Optimization

### Parallel Execution
```yaml
# GitHub Actions
strategy:
  matrix:
    shard: [1, 2, 3, 4]
runs:
  - run: npm test -- --shard=${{ matrix.shard }}/${{ strategy.job-total }}
```

### Caching
```yaml
- uses: actions/cache@v4
  with:
    path: |
      node_modules
      .cache
    key: ${{ runner.os }}-test-${{ hashFiles('package-lock.json') }}
```

### Fast Feedback
- Run unit tests first (fastest)
- Run integration tests in parallel
- Run E2E tests last (slowest)
- Fail fast on critical path tests
- Use test retry for flaky tests (max 2 retries)

### Flaky Test Handling
- Identify and quarantine flaky tests
- Fix root cause, don't just retry
- Add diagnostics to capture state on failure
- Track flaky test rate over time

## When to Use Me

Use this skill when:
- Writing new tests for features
- Setting up test infrastructure
- Debugging flaky tests
- Improving test coverage
- Implementing TDD
- Optimizing CI test pipeline
- Writing E2E test suites
- Creating test data factories

## Quality Checklist

- [ ] Tests follow AAA pattern
- [ ] Each test has one clear assertion focus
- [ ] No test depends on another test's state
- [ ] Mocks are scoped and restored
- [ ] Test data uses factories, not hardcoded values
- [ ] Error paths are tested, not just happy path
- [ ] Boundary values tested (empty, null, max, min)
- [ ] E2E tests cover critical user paths only
- [ ] Tests run in under 10 minutes total in CI
- [ ] No flaky tests in main branch
- [ ] Coverage meets target thresholds
- [ ] Test names describe behavior, not implementation
