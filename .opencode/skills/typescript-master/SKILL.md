---
name: typescript-master
description: Write type-safe, maintainable TypeScript code with advanced type system features. Covers generics, utility types, type guards, discriminated unions, strict mode, and common pitfalls.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
  category: language
---

# TypeScript Master

## What I Do

I help write robust, type-safe TypeScript code that catches errors at compile time and scales with your codebase. I leverage the full power of the type system while keeping code readable and maintainable.

## Strict Mode

### Always Enable
```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true
  }
}
```

### Why Strict Mode
- Catches `null`/`undefined` errors at compile time
- Prevents implicit `any` types
- Catches incorrect `this` usage
- Ensures properties are initialized
- Makes indexed access safer

## Type System Fundamentals

### Primitives
```typescript
let name: string;
let age: number;
let isActive: boolean;
let tags: string[];
let user: { name: string; age: number };
let callback: (id: number) => void;
```

### Type Aliases vs Interfaces
```typescript
// Interface — extendable, mergeable, for objects
interface User {
  id: string;
  name: string;
}

interface User {
  email: string; // Declaration merging
}

interface AdminUser extends User {
  role: string;
}

// Type Alias — more flexible, for unions, tuples, mapped types
type Status = 'active' | 'inactive' | 'banned';
type Point = [number, number];
type Maybe<T> = T | null;

// Prefer interface for object shapes, type for everything else
```

### Literal Types
```typescript
type Method = 'GET' | 'POST' | 'PUT' | 'DELETE';
type HttpStatus = 200 | 201 | 400 | 404 | 500;

const config = {
  method: 'GET' as const, // Type is 'GET', not string
};
```

### `as const` (Const Assertions)
```typescript
const routes = {
  home: '/',
  users: '/users',
  settings: '/settings',
} as const;
// Type: { readonly home: '/'; readonly users: '/users'; readonly settings: '/settings' }

type Route = typeof routes[keyof typeof routes];
// Type: '/' | '/users' | '/settings'
```

## Generics

### Basic Generics
```typescript
function first<T>(arr: T[]): T | undefined {
  return arr[0];
}

first([1, 2, 3]);     // T inferred as number
first(['a', 'b']);    // T inferred as string
first<number>([]);    // T explicitly set
```

### Generic Constraints
```typescript
interface HasId {
  id: string;
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id);
}

// T must have an id property
findById(users, '123');
```

### Multiple Type Parameters
```typescript
function mapEntries<K extends string, V, R>(
  obj: Record<K, V>,
  fn: (key: K, value: V) => R
): Record<K, R> {
  const result = {} as Record<K, R>;
  for (const key in obj) {
    result[key] = fn(key, obj[key]);
  }
  return result;
}
```

### Generic Classes
```typescript
class Repository<T extends { id: string }> {
  private items = new Map<string, T>();

  create(item: T): void {
    this.items.set(item.id, item);
  }

  findById(id: string): T | undefined {
    return this.items.get(id);
  }

  findAll(): T[] {
    return Array.from(this.items.values());
  }

  delete(id: string): boolean {
    return this.items.delete(id);
  }
}
```

## Utility Types

### Built-in Utility Types
```typescript
interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  createdAt: Date;
}

// Partial — all properties optional
type UpdateUser = Partial<User>;

// Required — all properties required
type StrictUser = Required<User>;

// Readonly — all properties readonly
type ReadonlyUser = Readonly<User>;

// Pick — select specific properties
type UserPublic = Pick<User, 'id' | 'name'>;

// Omit — exclude specific properties
type UserSafe = Omit<User, 'role' | 'createdAt'>;

// Record — create object type from keys
type UserRoleMap = Record<'admin' | 'user' | 'guest', User[]>;

// Exclude — remove from union
type ActiveStatus = Exclude<'active' | 'inactive' | 'banned', 'banned'>;
// 'active' | 'inactive'

// Extract — keep only matching from union
type BannedStatus = Extract<'active' | 'inactive' | 'banned', 'banned'>;
// 'banned'

// NonNullable — remove null and undefined
type NonNull = NonNullable<string | null | undefined>;
// string

// ReturnType — get function return type
type FetchResult = ReturnType<typeof fetchUser>;

// Parameters — get function parameter types
type FetchParams = Parameters<typeof updateUser>;

// Awaited — unwrap Promise type
type UserResult = Awaited<Promise<User>>;
// User
```

### Custom Utility Types
```typescript
// DeepPartial
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

// DeepReadonly
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};

// Nullable
type Nullable<T> = { [P in keyof T]: T[P] | null };

// ValueOf
type ValueOf<T> = T[keyof T];

// Mutable (remove readonly)
type Mutable<T> = { -readonly [P in keyof T]: T[P] };

// Optional — make specific properties optional
type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
```

## Type Guards and Narrowing

### Built-in Narrowing
```typescript
function process(value: string | number) {
  if (typeof value === 'string') {
    value; // narrowed to string
  } else {
    value; // narrowed to number
  }
}

function handle(value: string | null) {
  if (value !== null) {
    value; // narrowed to string
  }
}
```

### Type Predicates
```typescript
interface Dog { bark(): void }
interface Cat { meow(): void }

function isDog(animal: Dog | Cat): animal is Dog {
  return 'bark' in animal;
}

function makeSound(animal: Dog | Cat) {
  if (isDog(animal)) {
    animal.bark(); // narrowed to Dog
  } else {
    animal.meow(); // narrowed to Cat
  }
}
```

### Discriminated Unions
```typescript
interface Success<T> {
  status: 'success';
  data: T;
}

interface Error {
  status: 'error';
  message: string;
  code: number;
}

interface Loading {
  status: 'loading';
}

type Result<T> = Success<T> | Error | Loading;

function handleResult(result: Result<User>) {
  switch (result.status) {
    case 'success':
      result.data; // User
      break;
    case 'error':
      result.message; // string
      result.code; // number
      break;
    case 'loading':
      // no additional properties
      break;
  }
}
```

### Exhaustive Checking
```typescript
function assertNever(value: never): never {
  throw new Error(`Unexpected value: ${value}`);
}

type Shape = 'circle' | 'square' | 'triangle';

function getArea(shape: Shape): number {
  switch (shape) {
    case 'circle': return Math.PI;
    case 'square': return 1;
    case 'triangle': return 0.5;
    default: return assertNever(shape); // Compile error if Shape adds new member
  }
}
```

## Mapped Types
```typescript
// Basic mapped type
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

// With key remapping
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface Person {
  name: string;
  age: number;
}

type PersonGetters = Getters<Person>;
// { getName(): string; getAge(): number }

// Filter by type
type StringKeys<T> = {
  [K in keyof T as T[K] extends string ? K : never]: T[K];
};
```

## Template Literal Types
```typescript
type EventName = 'click' | 'focus' | 'blur';
type Element = 'button' | 'input' | 'link';

type EventHandler = `on${Capitalize<EventName>}${Capitalize<Element>}`;
// "onClickButton" | "onFocusInput" | "onBlurLink" | ...

type CSSProperty = 'margin' | 'padding';
type CSSSide = 'Top' | 'Right' | 'Bottom' | 'Left';
type CSSSpacing = `${CSSProperty}${CSSSide}`;
// "marginTop" | "marginRight" | ... | "paddingLeft"
```

## Module Augmentation
```typescript
// Extend third-party types
declare module 'express' {
  interface Request {
    user: {
      id: string;
      role: string;
    };
  }
}

// Extend global types
declare global {
  interface Window {
    analytics: Analytics;
  }
}

export {}; // Required for module augmentation
```

## Type-Safe API Client
```typescript
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';

interface ApiEndpoints {
  'GET /users': { response: User[]; query: { page: number } };
  'GET /users/:id': { response: User; params: { id: string } };
  'POST /users': { response: User; body: CreateUserDto };
  'DELETE /users/:id': { response: void; params: { id: string } };
}

type Endpoint = keyof ApiEndpoints;

async function api<T extends Endpoint>(
  endpoint: T,
  options?: ApiEndpoints[T] extends { body: infer B } ? { body: B } : never
): Promise<ApiEndpoints[T]['response']> {
  const [method, path] = endpoint.split(' ');
  // implementation...
}

// Usage — fully type-checked
const users = await api('GET /users', { query: { page: 1 } });
const user = await api('GET /users/:id', { params: { id: '123' } });
await api('POST /users', { body: { name: 'John', email: 'john@test.com' } });
```

## Common Pitfalls

### Avoid `any`
```typescript
// Bad
function process(data: any) { ... }

// Good
function process(data: unknown) {
  if (Array.isArray(data)) {
    // narrowed to unknown[]
  }
}

// Better: use generics
function process<T>(data: T[]): T | undefined {
  return data[0];
}
```

### Avoid Type Assertions (`as`)
```typescript
// Bad — bypasses type checking
const user = response.data as User;

// Good — validate at runtime
function isUser(data: unknown): data is User {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'name' in data
  );
}

if (isUser(response.data)) {
  response.data; // User
}
```

### Avoid Non-Null Assertion (`!`)
```typescript
// Bad
const el = document.getElementById('app')!;

// Good
const el = document.getElementById('app');
if (!el) throw new Error('Element not found');
el; // HTMLElement
```

### Index Signatures vs Record
```typescript
// Index signature
interface StringMap {
  [key: string]: number;
}

// Record (preferred)
type StringMap = Record<string, number>;
```

### `unknown` vs `any`
```typescript
// any — no type safety
let x: any;
x.foo.bar.baz; // Compiles, crashes at runtime

// unknown — requires type checking
let y: unknown;
y.foo; // Error: Object is of type 'unknown'

if (typeof y === 'object' && y !== null && 'foo' in y) {
  y.foo; // OK after narrowing
}
```

## tsconfig Best Practices
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

## When to Use Me

Use this skill when:
- Writing TypeScript code
- Setting up tsconfig
- Creating type definitions
- Implementing type-safe APIs
- Refactoring JavaScript to TypeScript
- Debugging type errors
- Designing generic utilities
- Building type-safe event systems

## Quality Checklist

- [ ] Strict mode enabled
- [ ] No `any` types used
- [ ] No unnecessary type assertions (`as`)
- [ ] No non-null assertions (`!`)
- [ ] Discriminated unions for state management
- [ ] Exhaustive checking with `never`
- [ ] Utility types used instead of manual mappings
- [ ] Generics properly constrained
- [ ] `unknown` preferred over `any` for unknown data
- [ ] Runtime validation for external data
- [ ] `noUncheckedIndexedAccess` enabled
- [ ] Declaration files generated for libraries
