---
name: react-master
description: Build performant, accessible React applications with modern patterns. Covers hooks, component architecture, state management, performance optimization, and best practices.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
  category: frontend
---

# React Master

## What I Do

I help build performant, accessible React applications using modern patterns and best practices. I ensure components are reusable, well-structured, and follow React's design principles.

## Component Architecture

### Component Types
```tsx
// Presentational (UI only)
function UserCard({ name, avatar, status }: UserCardProps) {
  return (
    <div className="user-card">
      <img src={avatar} alt="" />
      <h3>{name}</h3>
      <StatusBadge status={status} />
    </div>
  );
}

// Container (data fetching, state)
function UserCardContainer({ userId }: { userId: string }) {
  const { data: user, isLoading, error } = useUser(userId);
  
  if (isLoading) return <UserCardSkeleton />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return <NotFound />;
  
  return <UserCard {...user} />;
}
```

### Composition Over Configuration
```tsx
// Bad: Prop drilling and boolean props
function Modal({ 
  showHeader, showFooter, headerTitle, footerContent, children 
}: ModalProps) { ... }

// Good: Compound components
function Modal({ children }: { children: React.ReactNode }) {
  return <div className="modal">{children}</div>;
}

Modal.Header = function ModalHeader({ children }: { children: React.ReactNode }) {
  return <div className="modal-header">{children}</div>;
};

Modal.Body = function ModalBody({ children }: { children: React.ReactNode }) {
  return <div className="modal-body">{children}</div>;
};

Modal.Footer = function ModalFooter({ children }: { children: React.ReactNode }) {
  return <div className="modal-footer">{children}</div>;
};

// Usage
<Modal>
  <Modal.Header><h2>Title</h2></Modal.Header>
  <Modal.Body><p>Content</p></Modal.Body>
  <Modal.Footer><button>Close</button></Modal.Footer>
</Modal>
```

## Hooks

### Rules of Hooks
- Only call hooks at the top level (not in loops, conditions, or nested functions)
- Only call hooks from React function components or custom hooks
- Hooks must be called in the same order every render

### useState
```tsx
// Functional updates for state that depends on previous state
setCount(prev => prev + 1);

// Initialize from expensive computation
const [state, setState] = useState(() => computeExpensiveValue());
```

### useEffect
```tsx
useEffect(() => {
  const subscription = subscribeToData();
  return () => subscription.unsubscribe();
}, [dependency]);

// Common patterns
useEffect(() => { ... });           // Every render
useEffect(() => { ... }, []);      // Mount only
useEffect(() => { ... }, [dep]);   // Mount + when dep changes
```

### useMemo and useCallback
```tsx
// useMemo: memoize expensive computations
const sortedItems = useMemo(() => {
  return [...items].sort((a, b) => a.price - b.price);
}, [items]);

// useCallback: memoize functions for child component props
const handleClick = useCallback((id: string) => {
  setSelectedId(id);
}, [setSelectedId]);

// Only use when:
// 1. Passing to memoized child components (React.memo)
// 2. Computationally expensive operations
```

### useReducer
```tsx
interface State {
  items: CartItem[];
  total: number;
  status: 'idle' | 'loading' | 'success' | 'error';
}

type Action =
  | { type: 'ADD_ITEM'; payload: CartItem }
  | { type: 'REMOVE_ITEM'; payload: string }
  | { type: 'SET_STATUS'; payload: State['status'] };

function cartReducer(state: State, action: Action): State {
  switch (action.type) {
    case 'ADD_ITEM':
      return { ...state, items: [...state.items, action.payload], total: state.total + action.payload.price };
    case 'REMOVE_ITEM':
      const item = state.items.find(i => i.id === action.payload);
      return { ...state, items: state.items.filter(i => i.id !== action.payload), total: state.total - (item?.price ?? 0) };
    case 'SET_STATUS':
      return { ...state, status: action.payload };
    default:
      return state;
  }
}

const [cart, dispatch] = useReducer(cartReducer, initialState);
```

### Custom Hooks
```tsx
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}

function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  return debounced;
}

function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() => window.matchMedia(query).matches);
  useEffect(() => {
    const mql = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    mql.addEventListener('change', handler);
    return () => mql.removeEventListener('change', handler);
  }, [query]);
  return matches;
}
```

## State Management

### When to Use What
| Solution | Use Case |
|----------|----------|
| `useState` | Local component state |
| `useReducer` | Complex state logic, multiple sub-values |
| Context | Theme, auth, locale — low-frequency updates |
| Zustand | Medium apps, simple global state |
| Redux Toolkit | Large apps, complex state, devtools needed |
| TanStack Query | Server state, caching, synchronization |

### Context Best Practices
```tsx
// Split contexts by update frequency
const ThemeContext = createContext<Theme>(defaultTheme);
const UserContext = createContext<User | null>(null);

// Memoize context value to prevent unnecessary re-renders
const value = useMemo(() => ({ user, logout }), [user, logout]);

// Custom hook for consuming context
function useUser() {
  const context = useContext(UserContext);
  if (context === undefined) throw new Error('useUser must be used within UserProvider');
  return context;
}
```

### Server State vs Client State
```tsx
// Server state — use TanStack Query
function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => fetch(`/api/users/${id}`).then(res => res.json()),
    staleTime: 5 * 60 * 1000,
  });
}

// Client state — use useState/useReducer/Context
const [isModalOpen, setIsModalOpen] = useState(false);
const [cart, dispatch] = useReducer(cartReducer, initialCart);
```

## Performance Optimization

### React.memo
```tsx
const UserCard = React.memo(function UserCard({ user, onSelect }: UserCardProps) {
  return <div onClick={() => onSelect(user.id)}><h3>{user.name}</h3><p>{user.email}</p></div>;
});
```

### Virtualization
```tsx
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualizedList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  });

  return (
    <div ref={parentRef} style={{ overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map(virtualRow => (
          <div key={virtualRow.key} style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: `${virtualRow.size}px`, transform: `translateY(${virtualRow.start}px)` }}>
            {items[virtualRow.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Code Splitting
```tsx
const Dashboard = lazy(() => import('./Dashboard'));
const Settings = lazy(() => import('./Settings'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

## Accessibility (a11y)

### Semantic HTML
```tsx
// Bad
<div onClick={handleClick} role="button">Submit</div>

// Good
<button onClick={handleClick}>Submit</button>
```

### Focus Management
```tsx
function Modal({ isOpen, onClose, children }: ModalProps) {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousFocus = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (isOpen) {
      previousFocus.current = document.activeElement as HTMLElement;
      modalRef.current?.focus();
    } else {
      previousFocus.current?.focus();
    }
  }, [isOpen]);

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      return () => document.removeEventListener('keydown', handleEscape);
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div ref={modalRef} role="dialog" aria-modal="true" tabIndex={-1}>
      {children}
    </div>
  );
}
```

### ARIA Patterns
```tsx
// Accordion
function AccordionItem({ title, children, isOpen, onToggle }: AccordionProps) {
  const id = useId();
  return (
    <div>
      <h3>
        <button aria-expanded={isOpen} aria-controls={`panel-${id}`} id={`trigger-${id}`} onClick={onToggle}>
          {title}
        </button>
      </h3>
      <div id={`panel-${id}`} role="region" aria-labelledby={`trigger-${id}`} hidden={!isOpen}>
        {children}
      </div>
    </div>
  );
}
```

## Error Boundaries
```tsx
class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback?: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  constructor(props: { children: React.ReactNode; fallback?: React.ReactNode }) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? (
        <div role="alert">
          <h2>Something went wrong</h2>
          <p>{this.state.error?.message}</p>
          <button onClick={() => this.setState({ hasError: false, error: null })}>Try again</button>
        </div>
      );
    }
    return this.props.children;
  }
}
```

## Testing Patterns

### Component Testing
```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';

test('submits form with valid data', async () => {
  const onSubmit = vi.fn();
  render(<LoginForm onSubmit={onSubmit} />);

  fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'user@test.com' } });
  fireEvent.change(screen.getByLabelText(/password/i), { target: { value: 'password123' } });
  fireEvent.click(screen.getByRole('button', { name: /login/i }));

  await waitFor(() => {
    expect(onSubmit).toHaveBeenCalledWith({ email: 'user@test.com', password: 'password123' });
  });
});
```

## Suspense and Concurrent Features

### Suspense Boundaries
```tsx
// Wrap async components with Suspense
function ProductPage({ id }: { id: string }) {
  return (
    <div>
      <ProductInfo id={id} />
      <Suspense fallback={<ReviewsSkeleton />}>
        <ProductReviews id={id} />
      </Suspense>
      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedProducts id={id} />
      </Suspense>
    </div>
  );
}

// Nested Suspense — each section loads independently
<Suspense fallback={<PageSkeleton />}>
  <Suspense fallback={<ContentSkeleton />}>
    <Content />
  </Suspense>
</Suspense>
```

### useTransition
```tsx
function SearchPage() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<Product[]>([]);
  const [isPending, startTransition] = useTransition();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setQuery(value); // Urgent — update input immediately
    
    startTransition(() => {
      // Non-urgent — defer search results
      const filtered = searchProducts(value);
      setResults(filtered);
    });
  };

  return (
    <div>
      <input value={query} onChange={handleChange} />
      {isPending && <Spinner />}
      <ResultsList results={results} />
    </div>
  );
}
```

### useDeferredValue
```tsx
function SearchResults({ query }: { query: string }) {
  // Defer the search results update
  const deferredQuery = useDeferredValue(query);
  const results = useMemo(() => searchProducts(deferredQuery), [deferredQuery]);

  return (
    <div>
      {/* Input stays responsive */}
      <ResultsList results={results} />
    </div>
  );
}
```

## Form Handling

### Controlled Forms
```tsx
function SignupForm({ onSubmit }: { onSubmit: (data: FormData) => void }) {
  const [form, setForm] = useState({ name: '', email: '', password: '' });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validate = () => {
    const errs: Record<string, string> = {};
    if (!form.name.trim()) errs.name = 'Name is required';
    if (!form.email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) errs.email = 'Invalid email';
    if (form.password.length < 8) errs.password = 'Min 8 characters';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;
    
    setIsSubmitting(true);
    try {
      await onSubmit(form);
    } catch (err) {
      setErrors({ form: 'Failed to create account' });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} noValidate>
      {errors.form && <div role="alert" className="error">{errors.form}</div>}
      
      <label>
        Name
        <input
          value={form.name}
          onChange={e => setForm(prev => ({ ...prev, name: e.target.value }))}
          aria-invalid={!!errors.name}
          aria-describedby={errors.name ? 'name-error' : undefined}
        />
        {errors.name && <span id="name-error" className="error">{errors.name}</span>}
      </label>
      
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Sign Up'}
      </button>
    </form>
  );
}
```

### useActionState (React 19)
```tsx
import { useActionState } from 'react';

async function signup(prevState: any, formData: FormData) {
  const email = formData.get('email') as string;
  const password = formData.get('password') as string;
  
  try {
    await api.signup({ email, password });
    return { success: true };
  } catch (err) {
    return { error: err.message };
  }
}

function SignupForm() {
  const [state, formAction, isPending] = useActionState(signup, null);

  return (
    <form action={formAction}>
      <input name="email" type="email" required />
      <input name="password" type="password" required minLength={8} />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Sign Up'}
      </button>
      {state?.error && <p role="alert">{state.error}</p>}
      {state?.success && <p>Account created!</p>}
    </form>
  );
}
```

## When to Use Me

Use this skill when:
- Building React components or pages
- Optimizing React performance
- Managing complex state
- Implementing custom hooks
- Setting up error boundaries
- Improving component accessibility
- Testing React components
- Implementing code splitting
- Building forms with validation
- Using Suspense for async UI
- Implementing concurrent features

## Quality Checklist

- [ ] Components follow single responsibility principle
- [ ] Props are typed with TypeScript interfaces/types
- [ ] Custom hooks extracted for reusable logic
- [ ] Context split by update frequency
- [ ] Server state separated from client state
- [ ] React.memo used only where profiling shows benefit
- [ ] Code splitting implemented for routes
- [ ] Error boundaries wrap component trees
- [ ] Accessibility: semantic HTML, ARIA, focus management
- [ ] Keys are stable and unique (not array index)
- [ ] Effects have proper cleanup functions
- [ ] Dependencies arrays are complete and correct
- [ ] Suspense boundaries for async components
- [ ] Forms have proper validation and error states
- [ ] useTransition for non-urgent state updates
- [ ] Accessibility: semantic HTML, ARIA, focus management
- [ ] Keys are stable and unique (not array index)
- [ ] Effects have proper cleanup functions
- [ ] Dependencies arrays are complete and correct
