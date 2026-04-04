---
name: python-master
description: Write clean, type-safe, and efficient Python code. Covers type hints, async programming, dataclasses, Pydantic, pytest, packaging, and Pythonic patterns.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: backend
  category: language
---

# Python Master

## What I Do

I help write clean, efficient, and Pythonic code following modern best practices. I ensure proper typing, testing, packaging, and adherence to PEP standards.

## Type Hints

### Basic Types
```python
from typing import List, Dict, Optional, Union, Any, Tuple, Callable

def process_user(
    name: str,
    age: int,
    tags: list[str],           # Python 3.9+ builtin generics
    metadata: dict[str, Any] | None = None,  # Python 3.10+ union syntax
) -> dict[str, Any]:
    return {"name": name, "age": age}
```

### Advanced Typing
```python
from typing import TypeVar, Generic, Protocol, TypedDict, Literal, TypeAlias

T = TypeVar("T")
K = TypeVar("K", bound="HasId")

class HasId(Protocol):
    id: str

class UserDict(TypedDict):
    id: str
    name: str
    email: str
    role: Literal["admin", "user", "guest"]

Status: TypeAlias = Literal["active", "inactive", "banned"]

class Repository(Generic[T]):
    def __init__(self) -> None:
        self._items: dict[str, T] = {}
    
    def get(self, id: str) -> T | None:
        return self._items.get(id)
    
    def save(self, item: T) -> None:
        if hasattr(item, "id"):
            self._items[item.id] = item
```

### Type Guards
```python
from typing import TypeGuard

def is_user(data: dict[str, Any]) -> TypeGuard[UserDict]:
    return (
        isinstance(data.get("id"), str)
        and isinstance(data.get("name"), str)
        and isinstance(data.get("email"), str)
    )

def process(data: dict[str, Any]) -> None:
    if is_user(data):
        reveal_type(data)  # UserDict
```

## Dataclasses

### Basic Usage
```python
from dataclasses import dataclass, field
from datetime import datetime

@dataclass(frozen=True)
class Point:
    x: float
    y: float

@dataclass
class User:
    id: str
    name: str
    email: str
    created_at: datetime = field(default_factory=datetime.utcnow)
    tags: list[str] = field(default_factory=list)
    
    @property
    def display_name(self) -> str:
        return f"{self.name} <{self.email}>"
```

## Pydantic

### Validation Models
```python
from pydantic import BaseModel, Field, field_validator, ConfigDict
from email_validator import validate_email

class CreateUserInput(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    
    name: str = Field(min_length=1, max_length=100)
    email: str
    password: str = Field(min_length=8, max_length=128)
    age: int | None = Field(None, ge=0, le=150)
    
    @field_validator("email")
    @classmethod
    def validate_email_format(cls, v: str) -> str:
        validated = validate_email(v)
        return validated.normalized
    
    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain uppercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain digit")
        return v
```

## Async/Await

### Asyncio Patterns
```python
import asyncio
import aiohttp

async def fetch_user(session: aiohttp.ClientSession, user_id: str) -> dict:
    async with session.get(f"/api/users/{user_id}") as resp:
        resp.raise_for_status()
        return await resp.json()

async def fetch_all_users(user_ids: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_user(session, uid) for uid in user_ids]
        return await asyncio.gather(*tasks, return_exceptions=True)

# Semaphore for rate limiting
async def fetch_with_limit(urls: list[str], max_concurrent: int = 5) -> list:
    semaphore = asyncio.Semaphore(max_concurrent)
    
    async def fetch(url: str) -> str:
        async with semaphore:
            async with aiohttp.ClientSession() as session:
                async with session.get(url) as resp:
                    return await resp.text()
    
    return await asyncio.gather(*[fetch(url) for url in urls])

# Timeout handling
async def with_timeout(coro, timeout: float = 5.0):
    return await asyncio.wait_for(coro, timeout=timeout)
```

### Async Context Managers
```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def database_connection():
    conn = await asyncpg.connect(DATABASE_URL)
    try:
        yield conn
    finally:
        await conn.close()

async def query_users():
    async with database_connection() as conn:
        return await conn.fetch("SELECT * FROM users")
```

## Testing with pytest

### Fixtures
```python
import pytest

@pytest.fixture
def mock_db():
    db = TestDatabase()
    db.create_tables()
    yield db
    db.drop_tables()

@pytest.fixture
def sample_user(mock_db):
    return mock_db.users.create(name="John", email="john@test.com")

@pytest.fixture
def auth_client(client, sample_user):
    token = create_token(sample_user.id)
    client.headers["Authorization"] = f"Bearer {token}"
    return client
```

### Parametrized Tests
```python
@pytest.mark.parametrize("email,expected", [
    ("user@example.com", True),
    ("invalid", False),
    ("", False),
    ("user@.com", False),
])
def test_email_validation(email: str, expected: bool) -> None:
    assert is_valid_email(email) == expected

@pytest.mark.parametrize("user_data,status_code", [
    ({"name": "John", "email": "john@test.com"}, 201),
    ({"name": "", "email": "john@test.com"}, 400),
    ({"name": "John", "email": "invalid"}, 400),
    ({}, 400),
])
def test_create_user_validation(client, user_data, status_code):
    response = client.post("/users", json=user_data)
    assert response.status_code == status_code
```

### Mocking
```python
from unittest.mock import patch, MagicMock, AsyncMock

def test_send_email():
    with patch("services.email.smtp.SMTP") as mock_smtp:
        send_email("user@test.com", "Subject", "Body")
        mock_smtp.return_value.send_message.assert_called_once()

async def test_async_api_call():
    mock_response = AsyncMock()
    mock_response.json.return_value = {"id": 1, "name": "John"}
    
    with patch("aiohttp.ClientSession.get", return_value=mock_response):
        result = await fetch_user("1")
        assert result["name"] == "John"
```

## Error Handling

### Custom Exceptions
```python
class AppError(Exception):
    """Base exception for application errors."""
    def __init__(self, message: str, code: str = "INTERNAL_ERROR") -> None:
        super().__init__(message)
        self.code = code

class NotFoundError(AppError):
    def __init__(self, resource: str, id: str) -> None:
        super().__init__(f"{resource} with id {id} not found", "NOT_FOUND")

class ValidationError(AppError):
    def __init__(self, errors: list[dict]) -> None:
        super().__init__("Validation failed", "VALIDATION_ERROR")
        self.errors = errors
```

### Context Managers
```python
from contextlib import contextmanager

@contextmanager
def transaction(db):
    try:
        db.begin()
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise

def update_user(user_id: str, data: dict) -> None:
    with transaction(db) as conn:
        conn.execute("UPDATE users SET ... WHERE id = ?", user_id)
```

## Packaging

### pyproject.toml
```toml
[project]
name = "my-package"
version = "1.0.0"
description = "Package description"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.100.0",
    "pydantic>=2.0",
    "sqlalchemy>=2.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "ruff>=0.1.0",
    "mypy>=1.0",
]

[tool.ruff]
target-version = "py311"
line-length = 100
select = ["E", "F", "I", "N", "W", "UP", "B", "SIM"]

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
```

## Common Patterns

### Decorators
```python
import functools
import time

def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__} took {elapsed:.4f}s")
        return result
    return wrapper

def retry(max_attempts: int = 3, delay: float = 1.0):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    time.sleep(delay * (2 ** attempt))
            return None
        return wrapper
    return decorator
```

### Generators
```python
def read_chunks(file_path: str, chunk_size: int = 8192):
    with open(file_path, "rb") as f:
        while chunk := f.read(chunk_size):
            yield chunk

def paginate(query, page_size: int = 100):
    offset = 0
    while True:
        results = query.limit(page_size).offset(offset).all()
        if not results:
            break
        yield from results
        offset += page_size
```

## Web Frameworks

### FastAPI
```python
from fastapi import FastAPI, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional

app = FastAPI(title="My API", version="1.0.0")

class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(min_length=1, max_length=100)
    password: str = Field(min_length=8)

class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    
    model_config = ConfigDict(from_attributes=True)

@app.post("/users", response_model=UserResponse, status_code=201)
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == user.email).first()
    if existing:
        raise HTTPException(status_code=409, detail="Email already exists")
    
    db_user = User(**user.model_dump(), hashed_password=hash_password(user.password))
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# Run: uvicorn main:app --reload
```

### Flask (Lightweight)
```python
from flask import Flask, request, jsonify
from functools import wraps

app = Flask(__name__)

def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get("Authorization")
        if not token or not verify_token(token):
            return jsonify({"error": "Unauthorized"}), 401
        return f(*args, **kwargs)
    return decorated

@app.route("/api/users", methods=["GET"])
@require_auth
def get_users():
    users = db.session.query(User).all()
    return jsonify([{"id": u.id, "name": u.name} for u in users])
```

## Data Science Patterns

### Pandas Best Practices
```python
import pandas as pd

# Read efficiently
df = pd.read_csv("data.csv", 
    dtype={"id": "int32", "status": "category"},
    parse_dates=["created_at"],
    usecols=["id", "name", "status", "created_at"]
)

# Vectorized operations (never iterate rows)
df["total"] = df["price"] * df["quantity"]
df["status"] = df["status"].astype("category")

# Method chaining (readable pipelines)
result = (
    pd.read_csv("sales.csv")
    .query("amount > 0 and status == 'completed'")
    .assign(month=lambda df: pd.to_datetime(df["date"]).dt.month)
    .groupby(["month", "category"])
    .agg(total=("amount", "sum"), count=("amount", "count"))
    .reset_index()
    .sort_values("total", ascending=False)
)

# Memory optimization
def reduce_memory(df: pd.DataFrame) -> pd.DataFrame:
    for col in df.select_dtypes(include=["int64"]).columns:
        df[col] = pd.to_numeric(df[col], downcast="integer")
    for col in df.select_dtypes(include=["float64"]).columns:
        df[col] = pd.to_numeric(df[col], downcast="float")
    return df
```

## Multiprocessing

### Process Pool
```python
from multiprocessing import Pool, cpu_count
from concurrent.futures import ProcessPoolExecutor, as_completed

# CPU-bound tasks — use multiprocessing, NOT threading
def process_chunk(data: list[str]) -> list[dict]:
    results = []
    for item in data:
        results.append(heavy_computation(item))
    return results

def parallel_process(items: list[str], n_workers: int | None = None) -> list[dict]:
    n_workers = n_workers or cpu_count()
    chunk_size = max(1, len(items) // n_workers)
    chunks = [items[i:i + chunk_size] for i in range(0, len(items), chunk_size)]
    
    with Pool(n_workers) as pool:
        results = pool.map(process_chunk, chunks)
    
    return [item for sublist in results for item in sublist]

# With futures for more control
def parallel_with_futures(items: list[str]) -> list[dict]:
    with ProcessPoolExecutor() as executor:
        futures = {executor.submit(process_item, item): item for item in items}
        results = []
        for future in as_completed(futures):
            try:
                results.append(future.result())
            except Exception as e:
                print(f"Error processing {futures[future]}: {e}")
    return results
```

### Threading vs Multiprocessing
```
I/O-bound (network, disk):   Use threading or asyncio
CPU-bound (computation):     Use multiprocessing
Mixed workload:              Use asyncio + ProcessPoolExecutor

GIL (Global Interpreter Lock):
- Only one thread executes Python bytecode at a time
- threading helps I/O-bound tasks (releases GIL during I/O)
- multiprocessing bypasses GIL (separate processes)
- numpy/pandas release GIL during C operations
```

## Publishing to PyPI

### Build and Publish
```toml
# pyproject.toml — complete example
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "my-package"
version = "1.0.0"
description = "A useful Python package"
readme = "README.md"
requires-python = ">=3.11"
license = {text = "MIT"}
authors = [{name = "Author", email = "author@example.com"}]
classifiers = [
    "Development Status :: 4 - Beta",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = [
    "pydantic>=2.0",
    "httpx>=0.24",
]

[project.optional-dependencies]
dev = ["pytest>=7.0", "ruff>=0.1", "mypy>=1.0"]

[project.urls]
Homepage = "https://github.com/user/my-package"
Documentation = "https://my-package.readthedocs.io"

[tool.hatch.build.targets.wheel]
packages = ["src/my_package"]
```

```bash
# Build
python -m build

# Upload to TestPyPI first
python -m twine upload --repository testpypi dist/*

# Upload to PyPI
python -m twine upload dist/*

# Or use uv (faster)
uv publish
```

## When to Use Me

Use this skill when:
- Writing Python applications or libraries
- Setting up type hints and mypy
- Creating data models with Pydantic
- Building APIs with FastAPI or Flask
- Writing async code with asyncio
- Processing data with pandas
- Setting up pytest test suites
- Packaging and publishing to PyPI
- Implementing multiprocessing for CPU-bound tasks
- Writing decorators and context managers

## Quality Checklist

- [ ] Type hints on all public functions and methods
- [ ] mypy passes with strict mode
- [ ] Dataclasses or Pydantic for data models
- [ ] Custom exceptions with hierarchy
- [ ] pytest fixtures for test setup
- [ ] Parametrized tests for multiple inputs
- [ ] ruff for linting and formatting
- [ ] pyproject.toml for configuration
- [ ] Context managers for resource management
- [ ] Async code uses proper error handling
- [ ] Vectorized operations in pandas (no row iteration)
- [ ] Multiprocessing for CPU-bound, threading for I/O-bound
- [ ] No bare except clauses
- [ ] Docstrings for public APIs
- [ ] Package builds and installs cleanly
- [ ] No bare except clauses
- [ ] Docstrings for public APIs
