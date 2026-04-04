---
name: go-master
description: Write idiomatic, efficient Go code following Go best practices. Covers project structure, interfaces, concurrency, error handling, testing, and HTTP servers.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: backend
  category: language
---

# Go Master

## What I Do

I help write idiomatic, efficient Go code following Go's design philosophy. I ensure proper project structure, concurrency patterns, error handling, and testing practices.

## Go Idioms

### Core Principles
- Simple is better than complex
- Errors are values — handle them explicitly
- Clear is better than clever
- Concurrency is not parallelism
- The bigger the interface, the weaker the abstraction
- Make the zero value useful
- `interface{}` says nothing

### Naming Conventions
```go
// Packages: short, lowercase, no underscores
package http // not httpserver, not HTTP

// Interfaces: -er suffix for single-method interfaces
type Reader interface { Read(p []byte) (n int, err error) }
type Closer interface { Close() error }

// MixedCaps for all names
type HTTPServer struct { ... }    // not HttpServer
func fetchUserData() { ... }      // not fetch_user_data

// Receivers: 1-2 characters, consistent across type
func (u *User) Validate() error { ... }
func (r *Repository) Find(id string) (*User, error) { ... }
```

## Project Structure

### Standard Layout
```
cmd/
  server/
    main.go          # Entry point for server
  cli/
    main.go          # Entry point for CLI
internal/
  app/
    app.go           # Application wiring
  handler/
    user.go          # HTTP handlers
  service/
    user.go          # Business logic
  repository/
    user.go          # Data access
  model/
    user.go          # Domain models
pkg/
  validator/         # Reusable packages (importable by others)
api/
  openapi.yaml       # API specification
configs/             # Configuration files
migrations/          # Database migrations
scripts/             # Build and install scripts
go.mod
go.sum
```

### Dependency Injection
```go
type Server struct {
    userService service.UserService
    logger      *log.Logger
    router      *http.ServeMux
}

func NewServer(userService service.UserService, logger *log.Logger) *Server {
    return &Server{
        userService: userService,
        logger:      logger,
        router:      http.NewServeMux(),
    }
}
```

## Interfaces

### Define Interfaces Where They Are Used
```go
// Bad: defining interface in the package that implements it
package storage
type UserRepository interface { ... }

// Good: defining interface where it's consumed
package service
type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
}

// Implementation can be in any package
package postgres
type UserRepo struct { db *sql.DB }
func (r *UserRepo) FindByID(ctx context.Context, id string) (*User, error) { ... }
func (r *UserRepo) Save(ctx context.Context, user *User) error { ... }
```

### Keep Interfaces Small
```go
// Good: focused interfaces
type Storer interface { Store(key string, value []byte) error }
type Finder interface { Find(key string) ([]byte, error) }
type Deleter interface { Delete(key string) error }

// Compose when needed
type Store interface {
    Storer
    Finder
    Deleter
}
```

### Accept Interfaces, Return Concrete Types
```go
// Function accepts interface
func ProcessData(r io.Reader) error {
    data, err := io.ReadAll(r)
    // ...
}

// Function returns concrete type
func NewUserRepo(db *sql.DB) *UserRepo {
    return &UserRepo{db: db}
}
```

## Error Handling

### Sentinel Errors
```go
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrInvalidInput = errors.New("invalid input")
)

func (r *UserRepo) FindByID(ctx context.Context, id string) (*User, error) {
    var user User
    err := r.db.QueryRowContext(ctx, "SELECT ... WHERE id = $1", id).Scan(&user.ID, &user.Name)
    if err == sql.ErrNoRows {
        return nil, ErrNotFound
    }
    if err != nil {
        return nil, fmt.Errorf("finding user %s: %w", id, err)
    }
    return &user, nil
}
```

### Error Wrapping
```go
// Wrap with context
if err != nil {
    return fmt.Errorf("processing request: %w", err)
}

// Unwrap and check
if errors.Is(err, ErrNotFound) {
    return http.StatusNotFound
}

// Type assertion for custom errors
var appErr *AppError
if errors.As(err, &appErr) {
    return appErr.Code
}
```

### Custom Error Types
```go
type AppError struct {
    Code    string
    Message string
    Err     error
}

func (e *AppError) Error() string {
    return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

func (e *AppError) Unwrap() error {
    return e.Err
}
```

### Never Ignore Errors
```go
// Bad
result, _ := doSomething()

// Good
result, err := doSomething()
if err != nil {
    return fmt.Errorf("doing something: %w", err)
}
```

## Concurrency

### Goroutines and Channels
```go
// Worker pool
func workerPool(jobs <-chan Job, results chan<- Result, workers int) {
    var wg sync.WaitGroup
    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for job := range jobs {
                results <- process(job)
            }
        }()
    }
    wg.Wait()
    close(results)
}

// Fan-out, fan-in
func fanOutFanIn(ctx context.Context, inputs []Input) []Result {
    ch := make(chan Result)
    var wg sync.WaitGroup
    
    // Fan-out
    for _, input := range inputs {
        wg.Add(1)
        go func(in Input) {
            defer wg.Done()
            select {
            case ch <- process(in):
            case <-ctx.Done():
            }
        }(input)
    }
    
    // Close channel when all done
    go func() {
        wg.Wait()
        close(ch)
    }()
    
    // Fan-in
    var results []Result
    for r := range ch {
        results = append(results, r)
    }
    return results
}
```

### Select Pattern
```go
func withTimeout(ctx context.Context, timeout time.Duration) error {
    ctx, cancel := context.WithTimeout(ctx, timeout)
    defer cancel()
    
    select {
    case result := <-doWork():
        return result
    case <-ctx.Done():
        return ctx.Err()
    }
}
```

### sync Package
```go
// Once — initialize exactly once
var once sync.Once
var config *Config

func GetConfig() *Config {
    once.Do(func() {
        config = loadConfig()
    })
    return config
}

// Mutex — protect shared state
type Counter struct {
    mu    sync.Mutex
    count int
}

func (c *Counter) Inc() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

// RWMutex — read-heavy workloads
type Cache struct {
    mu   sync.RWMutex
    data map[string]string
}

func (c *Cache) Get(key string) (string, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    val, ok := c.data[key]
    return val, ok
}

func (c *Cache) Set(key, val string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.data[key] = val
}

// WaitGroup — wait for goroutines
var wg sync.WaitGroup
for _, url := range urls {
    wg.Add(1)
    go func(u string) {
        defer wg.Done()
        fetch(u)
    }(url)
}
wg.Wait()
```

### Context
```go
func handleRequest(ctx context.Context, req *Request) error {
    // Pass context to all downstream calls
    user, err := getUser(ctx, req.UserID)
    if err != nil {
        return fmt.Errorf("getting user: %w", err)
    }
    
    // Check context for cancellation
    select {
    case <-ctx.Done():
        return ctx.Err()
    default:
    }
    
    return processUser(ctx, user)
}
```

## Testing

### Table-Driven Tests
```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {"valid", "user@example.com", false},
        {"missing @", "userexample.com", true},
        {"empty", "", true},
        {"missing domain", "user@", true},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateEmail(tt.email)
            if (err != nil) != tt.wantErr {
                t.Errorf("ValidateEmail() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

### HTTP Testing
```go
func TestGetUserHandler(t *testing.T) {
    repo := &mockUserRepo{}
    handler := NewHandler(repo)
    
    req := httptest.NewRequest("GET", "/users/123", nil)
    rr := httptest.NewRecorder()
    
    handler.ServeHTTP(rr, req)
    
    if rr.Code != http.StatusOK {
        t.Errorf("expected 200, got %d", rr.Code)
    }
}
```

### Benchmarks
```go
func BenchmarkParseJSON(b *testing.B) {
    data := []byte(`{"name":"John","age":30}`)
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        var u User
        json.Unmarshal(data, &u)
    }
}
```

## HTTP Server

### Graceful Shutdown
```go
func main() {
    srv := &http.Server{
        Addr:    ":8080",
        Handler: mux,
    }
    
    go func() {
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("server failed: %v", err)
        }
    }()
    
    // Wait for interrupt signal
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    
    log.Println("shutting down server...")
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    
    if err := srv.Shutdown(ctx); err != nil {
        log.Fatalf("server shutdown failed: %v", err)
    }
    log.Println("server stopped")
}
```

### Middleware Pattern
```go
type Middleware func(http.Handler) http.Handler

func LoggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        next.ServeHTTP(w, r)
        log.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start))
    })
}

func ChainMiddleware(handler http.Handler, middlewares ...Middleware) http.Handler {
    for i := len(middlewares) - 1; i >= 0; i-- {
        handler = middlewares[i](handler)
    }
    return handler
}
```

## When to Use Me

Use this skill when:
- Writing Go applications or libraries
- Setting up project structure
- Implementing concurrency patterns
- Designing interfaces
- Handling errors properly
- Writing table-driven tests
- Building HTTP servers
- Implementing graceful shutdown

## Quality Checklist

- [ ] Errors are handled explicitly, never ignored
- [ ] Errors are wrapped with context using fmt.Errorf
- [ ] Interfaces are small and defined where used
- [ ] Context is passed as first parameter
- [ ] Goroutines have clear lifecycle management
- [ ] Channels are closed by sender, not receiver
- [ ] sync primitives used for shared state
- [ ] Table-driven tests for all functions
- [ ] Graceful shutdown implemented
- [ ] Zero value of types is useful
- [ ] No package-level mutable state
- [ ] go fmt and go vet pass
