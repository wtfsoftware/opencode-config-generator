---
name: code-review-master
description: Conduct thorough, constructive code reviews that improve code quality and team knowledge. Covers review checklists, code smells, refactoring patterns, and effective feedback techniques.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: fullstack
  category: collaboration
---

# Code Review Master

## What I Do

I help conduct effective code reviews that catch bugs, improve code quality, and share knowledge across the team. I focus on what matters, provide constructive feedback, and maintain a positive review culture.

## PR Best Practices

### Before Submitting
- Self-review your own code first
- Run linter, type checker, and tests locally
- Keep PRs small — under 400 lines of changes
- Write a clear description with context and screenshots
- Link related issues/tickets
- Mark as draft if not ready

### PR Description Template
```markdown
## What does this PR do?
Brief description of the change

## Why is this change needed?
Context and motivation

## How to test
1. Step one
2. Step two
3. Expected result

## Screenshots (if UI change)
Before | After
--- | ---
... | ...

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes (or marked as breaking)
- [ ] Follows project conventions
```

### PR Size Guidelines
| Size        | Lines Changed | Review Time | Risk  |
|-------------|---------------|-------------|-------|
| Small       | 1-100         | 15-30 min   | Low   |
| Medium      | 100-400       | 30-60 min   | Medium|
| Large       | 400-800       | 1-2 hours   | High  |
| Too Large   | 800+          | 2+ hours    | Very High |

**Rule**: If a PR is over 400 lines, consider splitting it.

## Review Checklist

### Correctness
- [ ] Does the code do what it claims to do?
- [ ] Are edge cases handled? (empty, null, max, min)
- [ ] Are error cases handled gracefully?
- [ ] Are there race conditions or concurrency issues?
- [ ] Is the logic correct? Any off-by-one errors?
- [ ] Are there any obvious bugs?

### Security
- [ ] Is user input validated and sanitized?
- [ ] Are there SQL injection, XSS, or CSRF vulnerabilities?
- [ ] Are secrets and credentials handled safely?
- [ ] Is authentication/authorization properly implemented?
- [ ] Are there any hardcoded secrets or API keys?

### Performance
- [ ] Are there N+1 query problems?
- [ ] Is there unnecessary computation or rendering?
- [ ] Are database queries optimized?
- [ ] Is there proper caching where needed?
- [ ] Are large datasets handled efficiently?
- [ ] Any memory leaks or unbounded growth?

### Readability
- [ ] Is the code easy to understand?
- [ ] Are variable and function names descriptive?
- [ ] Is there unnecessary complexity?
- [ ] Are there magic numbers or strings that should be constants?
- [ ] Is the code consistent with project style?

### Testing
- [ ] Are there tests for the new functionality?
- [ ] Do tests cover error paths and edge cases?
- [ ] Are tests readable and well-structured?
- [ ] Are mocks used appropriately?
- [ ] Would these tests catch regressions?

### Architecture
- [ ] Does this follow the project's architecture patterns?
- [ ] Is the code in the right place?
- [ ] Are dependencies and abstractions appropriate?
- [ ] Will this be easy to maintain and extend?
- [ ] Does it introduce unnecessary coupling?

### Documentation
- [ ] Is the code self-documenting, or does it need comments?
- [ ] Are public APIs documented?
- [ ] Is the README or docs updated if needed?
- [ ] Are complex algorithms explained?

## Code Smells

### Naming Issues
```typescript
// Bad: Unclear names
const d = new Date();
const x = data.map(i => i.v * 1.1);

// Good: Descriptive names
const currentDate = new Date();
const pricesWithTax = items.map(item => item.price * TAX_RATE);
```

### Long Functions
```typescript
// Bad: Does too much
function processUser(user: any) {
  // 50+ lines of validation, transformation, saving, emailing...
}

// Good: Single responsibility
function validateUser(user: User): ValidationResult { ... }
function transformUser(user: User): UserDTO { ... }
function saveUser(user: UserDTO): Promise<User> { ... }
function sendWelcomeEmail(user: User): Promise<void> { ... }
```

### Deep Nesting
```typescript
// Bad: Arrow anti-pattern
if (user) {
  if (user.isActive) {
    if (user.hasPermission('edit')) {
      if (document) {
        // finally do something
      }
    }
  }
}

// Good: Early returns
if (!user) return;
if (!user.isActive) return;
if (!user.hasPermission('edit')) return;
if (!document) return;
// do something
```

### Magic Numbers/Strings
```typescript
// Bad
if (status === 3) { ... }
setTimeout(callback, 86400000);

// Good
const ORDER_STATUS_SHIPPED = 3;
const MS_PER_DAY = 86400000;
if (status === ORDER_STATUS_SHIPPED) { ... }
setTimeout(callback, MS_PER_DAY);
```

### Duplicated Code
```typescript
// Bad: Same logic in multiple places
const activeUsers = users.filter(u => u.status === 'active').map(u => u.email);
const activeAdmins = admins.filter(a => a.status === 'active').map(a => a.email);

// Good: Extract common logic
function getActiveEmails(items: Array<{ status: string; email: string }>) {
  return items.filter(i => i.status === 'active').map(i => i.email);
}
```

### God Class / Bloated Component
```typescript
// Bad: Component does everything
function UserPage() {
  // fetching, validation, form handling, modal state, 
  // table sorting, pagination, export, filtering...
}

// Good: Compose smaller components
function UserPage() {
  return (
    <Layout>
      <UserFilters onFilter={handleFilter} />
      <UserTable users={filteredUsers} sort={sort} />
      <Pagination total={total} page={page} onPageChange={setPage} />
      <ExportButton data={filteredUsers} />
    </Layout>
  );
}
```

### Commented-Out Code
```typescript
// Bad
// const oldResult = calculateSomething();
// if (oldResult > threshold) {
//   doSomething();
// }

// Good: Delete it. Version control keeps the history.
```

### Catching All Errors Silently
```typescript
// Bad
try {
  await doSomething();
} catch (e) {
  // silently ignored
}

// Good
try {
  await doSomething();
} catch (error) {
  logger.error('Failed to do something', { error });
  throw new ServiceError('Something failed', { cause: error });
}
```

## Refactoring Patterns

### Extract Function
```typescript
// Before
function processOrder(order: Order) {
  const total = order.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const tax = total * 0.1;
  const shipping = total > 50 ? 0 : 5.99;
  return total + tax + shipping;
}

// After
function calculateSubtotal(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

function calculateTotal(order: Order): number {
  const subtotal = calculateSubtotal(order.items);
  const tax = subtotal * TAX_RATE;
  const shipping = subtotal > FREE_SHIPPING_THRESHOLD ? 0 : SHIPPING_COST;
  return subtotal + tax + shipping;
}
```

### Replace Conditional with Polymorphism
```typescript
// Before
function getShippingCost(method: string): number {
  if (method === 'standard') return 5.99;
  if (method === 'express') return 12.99;
  if (method === 'overnight') return 24.99;
  throw new Error('Unknown method');
}

// After
interface ShippingMethod {
  getCost(): number;
}

class StandardShipping implements ShippingMethod {
  getCost() { return 5.99; }
}

class ExpressShipping implements ShippingMethod {
  getCost() { return 12.99; }
}
```

### Introduce Parameter Object
```typescript
// Before
function createUser(name: string, email: string, age: number, role: string) { ... }

// After
interface CreateUserParams {
  name: string;
  email: string;
  age: number;
  role: string;
}

function createUser(params: CreateUserParams) { ... }
```

### Guard Clauses
```typescript
// Before
function getDiscount(user: User, cart: Cart): number {
  let discount = 0;
  if (user.isActive) {
    if (user.isPremium) {
      if (cart.total > 100) {
        discount = 0.2;
      } else {
        discount = 0.1;
      }
    } else {
      discount = 0.05;
    }
  }
  return discount;
}

// After
function getDiscount(user: User, cart: Cart): number {
  if (!user.isActive) return 0;
  if (user.isPremium) return cart.total > 100 ? 0.2 : 0.1;
  return 0.05;
}
```

## Feedback Techniques

### Tone and Language
```
❌ "This is wrong, fix it."
✅ "This might cause issues when X happens. Consider Y."

❌ "Why did you do it this way?"
✅ "Help me understand the reasoning behind this approach."

❌ "This code is messy."
✅ "This function is doing a lot — could we break it into smaller pieces?"

❌ "You forgot to handle the error case."
✅ "What should happen if the API call fails here?"
```

### Comment Types
**Nitpick** (optional, non-blocking)
```
nit: Could rename `data` to `users` for clarity.
```

**Suggestion** (consider, but not required)
```
suggestion: We could use a Map here for O(1) lookups instead of O(n).
```

**Question** (seeking understanding)
```
question: What's the expected behavior when the list is empty?
```

**Blocker** (must be addressed)
```
blocker: This exposes user passwords in the response. Please remove before merging.
```

### Praise Good Code
```
"Nice use of the strategy pattern here — very clean."
"Great test coverage, especially the edge cases."
"Love how you extracted this into a reusable hook."
```

## Review Priorities

### Must Catch (Always)
- Bugs and logic errors
- Security vulnerabilities
- Data loss risks
- Breaking changes without migration

### Should Catch (Most of the time)
- Performance issues
- Missing error handling
- Inconsistent patterns
- Missing tests for new logic

### Nice to Catch (When time permits)
- Naming improvements
- Code organization
- Minor style inconsistencies
- Documentation gaps

### Don't Comment On
- Personal style preferences (if project style is followed)
- Things already handled by linter/formatter
- Nitpicks on large PRs (save for follow-up)
- Architecture decisions already agreed upon

## When to Use Me

Use this skill when:
- Reviewing pull requests
- Setting up PR templates
- Establishing team review guidelines
- Training new developers on code review
- Refactoring complex code
- Identifying code smells
- Improving code readability

## Quality Checklist

- [ ] PR is under 400 lines of changes
- [ ] PR description explains what and why
- [ ] All automated checks pass
- [ ] Code follows project conventions
- [ ] Error cases are handled
- [ ] Edge cases considered
- [ ] No security issues
- [ ] Tests cover new functionality
- [ ] Feedback is constructive and specific
- [ ] Praise given for good solutions
- [ ] Blockers clearly marked