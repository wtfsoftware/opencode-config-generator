---
name: rust-master
description: Write safe, efficient Rust code leveraging the ownership system. Covers ownership, lifetimes, traits, error handling, smart pointers, async, and cargo.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: backend
  category: language
---

# Rust Master

## What I Do

I help write safe, efficient Rust code that leverages the borrow checker and type system. I ensure proper memory management, error handling, and idiomatic patterns.

## Ownership and Borrowing

### Ownership Rules
```rust
// Each value has exactly one owner
let s1 = String::from("hello");
let s2 = s1;  // s1 is moved, no longer valid
// println!("{}", s1); // Error: value borrowed here after move

// Borrowing — immutable references
let s = String::from("hello");
let r1 = &s;  // immutable borrow
let r2 = &s;  // multiple immutable borrows OK
println!("{} {}", r1, r2);

// Mutable reference — only one at a time
let mut s = String::from("hello");
let r = &mut s;
r.push_str(", world");
// let r2 = &mut s; // Error: cannot borrow as mutable more than once
```

### Borrow Checker Patterns
```rust
// Clone when you need ownership
fn process(data: String) { /* takes ownership */ }
let s = String::from("data");
process(s.clone()); // s still valid
process(s);         // s moved

// Return references with lifetimes
fn first_word(s: &str) -> &str {
    let bytes = s.as_bytes();
    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }
    &s[..]
}

// Split borrows — borrow different fields
struct Config {
    name: String,
    value: i32,
}

let mut config = Config { name: String::from("app"), value: 42 };
let name = &config.name;        // immutable borrow of name
let value = &mut config.value;  // mutable borrow of value — OK!
```

## Lifetimes

### Lifetime Elision Rules
```rust
// Compiler can infer these:
fn first_word(s: &str) -> &str { /* ... */ }

// Explicit when needed:
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}

// Struct with lifetime
struct Parser<'a> {
    input: &'a str,
    position: usize,
}

impl<'a> Parser<'a> {
    fn remaining(&self) -> &'a str {
        &self.input[self.position..]
    }
}

// Static lifetime
const MESSAGE: &str = "Hello, world!"; // &'static str
```

### Common Lifetime Errors
```rust
// Bad: returning reference to local variable
fn get_greeting() -> &str {
    let s = String::from("hello");
    &s  // Error: returns reference to local value
}

// Good: return owned String
fn get_greeting() -> String {
    String::from("hello")
}
```

## Traits

### Defining and Implementing
```rust
trait Summary {
    fn summarize(&self) -> String;
    
    // Default implementation
    fn summary_length(&self) -> usize {
        self.summarize().len()
    }
}

struct Article {
    title: String,
    content: String,
}

impl Summary for Article {
    fn summarize(&self) -> String {
        format!("{}: {}", self.title, &self.content[..50])
    }
}
```

### Trait Bounds
```rust
// Function with trait bound
fn notify<T: Summary + Display>(item: &T) {
    println!("{}", item.summarize());
}

// Where clause for readability
fn process<T, U>(t: &T, u: &U) -> String
where
    T: Summary + Debug,
    U: Display + Clone,
{
    format!("{:?} - {}", t, u)
}

// Returning types that implement traits
fn get_notifier() -> impl Summary {
    Article {
        title: String::from("Breaking"),
        content: String::from("..."),
    }
}
```

### Associated Types
```rust
trait Graph {
    type Node;
    type Edge;
    fn nodes(&self) -> &[Self::Node];
    fn edges(&self) -> &[Self::Edge];
}

struct WeightedGraph {
    nodes: Vec<Node>,
    edges: Vec<WeightedEdge>,
}

impl Graph for WeightedGraph {
    type Node = Node;
    type Edge = WeightedEdge;
    fn nodes(&self) -> &[Self::Node] { &self.nodes }
    fn edges(&self) -> &[Self::Edge] { &self.edges }
}
```

## Error Handling

### Result and Option
```rust
use std::fs::File;
use std::io::{self, Read};

// Returning Result
fn read_file(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

// Matching on Result
match read_file("config.txt") {
    Ok(contents) => println!("Loaded: {}", contents),
    Err(e) if e.kind() == io::ErrorKind::NotFound => {
        eprintln!("File not found, using defaults");
    }
    Err(e) => eprintln!("Error: {}", e),
}

// Option chaining
fn get_user_email(users: &HashMap<u32, User>, id: u32) -> Option<&str> {
    users.get(&id).and_then(|u| u.email.as_deref())
}

// unwrap_or, unwrap_or_else, expect
let port = config.get("port").unwrap_or(8080);
let file = File::open("config.toml").expect("Failed to open config");
```

### Custom Error Types
```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum AppError {
    #[error("user not found: {0}")]
    NotFound(String),
    
    #[error("invalid input: {field} - {message}")]
    Validation { field: String, message: String },
    
    #[error(transparent)]
    Io(#[from] std::io::Error),
    
    #[error(transparent)]
    Database(#[from] sqlx::Error),
}

type Result<T> = std::result::Result<T, AppError>;

fn find_user(id: &str) -> Result<User> {
    let user = db.query(id).await?; // sqlx::Error -> AppError via From
    user.ok_or_else(|| AppError::NotFound(id.to_string()))
}
```

### anyhow for Applications
```rust
use anyhow::{Context, Result, bail};

fn load_config(path: &str) -> Result<Config> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("Failed to read config at {}", path))?;
    
    let config: Config = toml::from_str(&content)
        .context("Failed to parse TOML config")?;
    
    if config.port == 0 {
        bail!("Port cannot be zero");
    }
    
    Ok(config)
}
```

## Smart Pointers

### Box<T>
```rust
// Heap allocation for large data
let large_data = Box::new([0u8; 1_000_000]);

// Recursive types
enum List {
    Cons(i32, Box<List>),
    Nil,
}

// Trait objects
trait Draw { fn draw(&self); }
struct Button;
impl Draw for Button { fn draw(&self) { /* ... */ } }

let widgets: Vec<Box<dyn Draw>> = vec![Box::new(Button)];
```

### Rc<T> and Arc<T>
```rust
use std::rc::Rc;
use std::sync::Arc;

// Single-threaded reference counting
let a = Rc::new(String::from("shared"));
let b = Rc::clone(&a);
let c = Rc::clone(&a);

// Thread-safe reference counting
let data = Arc::new(vec![1, 2, 3]);
let handles: Vec<_> = (0..3).map(|i| {
    let data = Arc::clone(&data);
    std::thread::spawn(move || {
        println!("Thread {}: {:?}", i, data);
    })
}).collect();
```

### RefCell<T> and Mutex<T>
```rust
use std::cell::RefCell;
use std::sync::Mutex;

// Interior mutability (single-threaded, runtime borrow checking)
let data = RefCell::new(vec![1, 2, 3]);
data.borrow_mut().push(4);

// Thread-safe interior mutability
let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];
for _ in 0..10 {
    let counter = Arc::clone(&counter);
    handles.push(std::thread::spawn(move || {
        let mut num = counter.lock().unwrap();
        *num += 1;
    }));
}
```

## Concurrency

### Channels
```rust
use std::sync::mpsc;

let (tx, rx) = mpsc::channel();

std::thread::spawn(move || {
    for i in 0..5 {
        tx.send(i).unwrap();
    }
});

for received in rx {
    println!("Got: {}", received);
}
```

### Async/Await with Tokio
```rust
use tokio;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Concurrent tasks
    let task1 = tokio::spawn(fetch_data("url1"));
    let task2 = tokio::spawn(fetch_data("url2"));
    
    let (result1, result2) = tokio::join!(task1, task2);
    
    // Select — first to complete
    tokio::select! {
        result = fetch_with_timeout() => println!("Done: {:?}", result),
        _ = tokio::time::sleep(std::time::Duration::from_secs(5)) => {
            println!("Timeout!");
        }
    }
    
    Ok(())
}

async fn fetch_data(url: &str) -> String {
    reqwest::get(url).await.unwrap().text().await.unwrap()
}
```

### Send and Sync
```rust
// Send: type can be transferred across thread boundaries
// Sync: type can be shared between threads (&T is Send)

// Most types are automatically Send + Sync
// Raw pointers are NOT Send or Sync
// Rc is NOT Send (use Arc instead)
// RefCell is NOT Sync (use Mutex instead)
```

## Cargo

### Workspace
```toml
# Cargo.toml (root)
[workspace]
members = ["crates/*"]
resolver = "2"

# crates/api/Cargo.toml
[package]
name = "myapp-api"
version = "0.1.0"
edition = "2021"

[dependencies]
myapp-core = { path = "../core" }
tokio = { version = "1", features = ["full"] }
```

### Features
```toml
[features]
default = ["std"]
std = []
async = ["tokio"]
cli = ["clap"]

[dependencies]
tokio = { version = "1", optional = true }
clap = { version = "4", optional = true }
```

### Profiles
```toml
[profile.release]
opt-level = 3
lto = true
codegen-units = 1
strip = true

[profile.dev]
opt-level = 0
debug = true
```

## Common Patterns

### Builder Pattern
```rust
#[derive(Debug, Default)]
struct Server {
    host: String,
    port: u16,
    workers: usize,
}

impl Server {
    fn new() -> Self {
        Self::default()
    }
    
    fn host(mut self, host: impl Into<String>) -> Self {
        self.host = host.into();
        self
    }
    
    fn port(mut self, port: u16) -> Self {
        self.port = port;
        self
    }
    
    fn workers(mut self, workers: usize) -> Self {
        self.workers = workers;
        self
    }
    
    fn start(self) -> Result<()> {
        println!("Starting {} on {}:{}", self.workers, self.host, self.port);
        Ok(())
    }
}

// Usage
Server::new()
    .host("0.0.0.0")
    .port(8080)
    .workers(4)
    .start()?;
```

### Newtype Pattern
```rust
struct UserId(u64);
struct Email(String);

impl Email {
    fn new(s: impl Into<String>) -> Result<Self, &'static str> {
        let s = s.into();
        if s.contains('@') {
            Ok(Email(s))
        } else {
            Err("Invalid email")
        }
    }
}
```

## When to Use Me

Use this skill when:
- Writing Rust applications or libraries
- Implementing ownership and borrowing patterns
- Designing trait hierarchies
- Handling errors with Result/Option
- Writing async code with Tokio
- Setting up Cargo workspaces
- Implementing thread-safe concurrency

## Quality Checklist

- [ ] Ownership rules followed — no unnecessary clones
- [ ] Lifetimes explicit when elision fails
- [ ] Traits small and focused
- [ ] Error types use thiserror for libraries
- [ ] anyhow used for applications
- [ ] ? operator for error propagation
- [ ] Arc for thread-safe sharing, Rc for single-threaded
- [ ] Mutex for thread-safe mutation, RefCell for single-threaded
- [ ] Async functions use proper cancellation
- [ ] Cargo features for optional functionality
- [ ] cargo clippy passes with no warnings
- [ ] cargo fmt applied
