# Project Layout Rules — Clean Architecture

## Core Principles

Clean Architecture organizes code into concentric layers where **dependencies always point inward**. The inner layers know nothing about the outer layers.

```
┌─────────────────────────────────────┐
│           Frameworks & Drivers      │  ← Outermost: DB, HTTP, UI, CLI
│  ┌───────────────────────────────┐  │
│  │     Interface Adapters        │  │  ← Controllers, Presenters, Gateways
│  │  ┌─────────────────────────┐  │  │
│  │  │    Application / Use    │  │  │  ← Use Cases, Application Services
│  │  │    Cases                │  │  │
│  │  │  ┌───────────────────┐  │  │  │
│  │  │  │      Domain       │  │  │  │  ← Innermost: Entities, Domain Logic
│  │  │  └───────────────────┘  │  │  │
│  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Layer Responsibilities

| Layer | Also Called | Contains | Depends On |
|---|---|---|---|
| **Domain** | Entities | Entities, Value Objects, Domain Events, Interfaces | Nothing |
| **Application** | Use Cases | Use Cases, Application Services, DTOs, Commands/Queries | Domain only |
| **Interface Adapters** | Adapters | Controllers, Presenters, Gateways, Repository implementations | Application + Domain |
| **Frameworks & Drivers** | Infrastructure | DB drivers, HTTP framework, ORM, message brokers | All layers |

## Rules

1. **Dependency Rule**: Source code dependencies must point inward. Nothing in an inner layer can know anything about an outer layer.
2. **Interfaces at Boundaries**: Define repository and service interfaces in the Application layer; implement them in the Infrastructure layer.
3. **No Framework Leakage**: Domain entities must not import or depend on ORM models, HTTP types, or any framework type.
4. **DTOs at Layer Boundaries**: Use Data Transfer Objects to cross layer boundaries. Never pass domain entities directly to the presentation layer.
5. **Use Cases are Pure**: Use case / application service logic must be testable without a database, HTTP server, or any infrastructure.
6. **Domain is the Source of Truth**: Business rules live in the Domain layer. No business logic in handlers, controllers, or repositories.
7. **One Direction of Change**: A change in the database should not require a change in the Domain. A change in the UI should not require a change in Use Cases.

---

## Python — Clean Architecture Layout

### Directory Tree

```
service-name/
├── src/
│   └── service_name/
│       ├── domain/                  # Layer 1 — Domain (innermost)
│       │   ├── __init__.py
│       │   ├── entities/            # Core business objects
│       │   │   ├── __init__.py
│       │   │   └── user.py          # Dataclass or Pydantic BaseModel (no ORM)
│       │   ├── value_objects/       # Immutable typed wrappers
│       │   │   └── email.py
│       │   ├── events/              # Domain events
│       │   │   └── user_registered.py
│       │   └── exceptions.py        # Typed domain exceptions
│       │
│       ├── application/             # Layer 2 — Use Cases
│       │   ├── __init__.py
│       │   ├── use_cases/
│       │   │   ├── __init__.py
│       │   │   ├── register_user.py
│       │   │   └── get_user.py
│       │   ├── repositories/        # Abstract interfaces (not implementations)
│       │   │   └── user_repository.py
│       │   ├── services/            # Application services (orchestration)
│       │   │   └── notification_service.py
│       │   └── dto/                 # Input/Output data shapes
│       │       └── user_dto.py
│       │
│       ├── adapters/                # Layer 3 — Interface Adapters
│       │   ├── __init__.py
│       │   ├── http/                # FastAPI/Flask routers
│       │   │   ├── routers/
│       │   │   │   └── user_router.py
│       │   │   └── schemas/         # Request/Response Pydantic models
│       │   │       └── user_schema.py
│       │   └── messaging/           # Event publishers/consumers
│       │       └── user_event_publisher.py
│       │
│       └── infrastructure/          # Layer 4 — Frameworks & Drivers
│           ├── __init__.py
│           ├── db/
│           │   ├── models/          # SQLAlchemy ORM models
│           │   │   └── user_model.py
│           │   └── repositories/    # Concrete repo implementations
│           │       └── sql_user_repository.py
│           ├── config.py            # Settings via pydantic-settings
│           └── container.py         # Dependency injection wiring
│
├── tests/
│   ├── unit/
│   │   ├── domain/
│   │   └── application/
│   └── integration/
│       └── infrastructure/
├── migrations/                      # Alembic migrations
├── pyproject.toml
└── Dockerfile
```

### Key Conventions

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case.py` | `user_repository.py` |
| Classes | `PascalCase` | `RegisterUserUseCase` |
| Interfaces (ABCs) | `NounRepository` / `NounService` | `UserRepository`, `NotificationService` |
| Use Cases | `VerbNounUseCase` | `RegisterUserUseCase`, `GetUserUseCase` |
| DTOs | `NounDTO` | `CreateUserDTO`, `UserResponseDTO` |
| Domain Exceptions | `NounError` | `UserNotFoundError`, `DuplicateEmailError` |

### Code Example

```python
# domain/entities/user.py — No ORM, no framework imports
from dataclasses import dataclass, field
from uuid import UUID, uuid4
from service_name.domain.value_objects.email import Email

@dataclass
class User:
    id: UUID
    email: Email
    name: str
    is_active: bool = True

    @staticmethod
    def create(email: str, name: str) -> "User":
        return User(id=uuid4(), email=Email(email), name=name)


# application/repositories/user_repository.py — Interface only
from abc import ABC, abstractmethod
from uuid import UUID
from service_name.domain.entities.user import User

class UserRepository(ABC):
    @abstractmethod
    async def find_by_id(self, user_id: UUID) -> User | None: ...

    @abstractmethod
    async def save(self, user: User) -> None: ...


# application/use_cases/register_user.py — Pure logic, no DB/HTTP
from dataclasses import dataclass
from service_name.application.repositories.user_repository import UserRepository
from service_name.domain.entities.user import User
from service_name.domain.exceptions import DuplicateEmailError

@dataclass
class RegisterUserUseCase:
    user_repo: UserRepository

    async def execute(self, email: str, name: str) -> User:
        if await self.user_repo.find_by_email(email):
            raise DuplicateEmailError(email)
        user = User.create(email=email, name=name)
        await self.user_repo.save(user)
        return user


# infrastructure/db/repositories/sql_user_repository.py — Implements interface
from sqlalchemy.ext.asyncio import AsyncSession
from service_name.application.repositories.user_repository import UserRepository
from service_name.domain.entities.user import User
from service_name.infrastructure.db.models.user_model import UserModel

class SQLUserRepository(UserRepository):
    def __init__(self, session: AsyncSession):
        self._session = session

    async def save(self, user: User) -> None:
        model = UserModel.from_domain(user)
        self._session.add(model)
        await self._session.flush()
```

---

## Go — Clean Architecture Layout

### Directory Tree

```
service-name/
├── cmd/
│   └── server/
│       └── main.go              # Entry point — wire dependencies, start server
│
├── internal/
│   ├── domain/                  # Layer 1 — Domain (innermost)
│   │   ├── user.go              # Entity + domain methods
│   │   ├── email.go             # Value object
│   │   └── errors.go            # Typed domain errors
│   │
│   ├── application/             # Layer 2 — Use Cases
│   │   ├── user_service.go      # Use case orchestration
│   │   ├── repository.go        # Repository interfaces (defined here, not infra)
│   │   ├── notifier.go          # External service interfaces
│   │   └── dto/
│   │       └── user_dto.go      # Input/output structs
│   │
│   ├── adapters/                # Layer 3 — Interface Adapters
│   │   ├── http/
│   │   │   ├── handler/
│   │   │   │   └── user_handler.go
│   │   │   └── middleware/
│   │   │       └── auth.go
│   │   └── grpc/
│   │       └── user_server.go
│   │
│   └── infrastructure/          # Layer 4 — Frameworks & Drivers
│       ├── postgres/
│       │   └── user_repository.go   # Implements application.UserRepository
│       ├── redis/
│       │   └── cache.go
│       └── config/
│           └── config.go
│
├── pkg/                         # Shared, exported utilities (no business logic)
│   └── pagination/
│       └── pagination.go
│
├── migrations/
├── go.mod
├── go.sum
└── Dockerfile
```

### Key Conventions

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case.go` | `user_repository.go` |
| Interfaces | Defined in the layer that uses them | `application/repository.go` |
| Interface names | Single-method: `-er` suffix; multi: Noun | `Storer`, `UserRepository` |
| Use Cases | Methods on a service struct | `UserService.Register(ctx, cmd)` |
| `ctx` | First param on every method | `func (s *UserService) Get(ctx context.Context, id uuid.UUID)` |
| Errors | Typed sentinel or struct errors | `var ErrUserNotFound = errors.New("user not found")` |

### Code Example

```go
// internal/domain/user.go — No framework imports
package domain

import "github.com/google/uuid"

type User struct {
    ID       uuid.UUID
    Email    Email
    Name     string
    IsActive bool
}

func NewUser(email, name string) (*User, error) {
    e, err := NewEmail(email)
    if err != nil {
        return nil, err
    }
    return &User{
        ID:       uuid.New(),
        Email:    e,
        Name:     name,
        IsActive: true,
    }, nil
}


// internal/application/repository.go — Interface lives in application layer
package application

import (
    "context"
    "github.com/google/uuid"
    "service-name/internal/domain"
)

type UserRepository interface {
    FindByID(ctx context.Context, id uuid.UUID) (*domain.User, error)
    FindByEmail(ctx context.Context, email string) (*domain.User, error)
    Save(ctx context.Context, user *domain.User) error
}


// internal/application/user_service.go — Pure use case, no DB/HTTP
package application

import (
    "context"
    "service-name/internal/domain"
)

type UserService struct {
    repo UserRepository
}

func NewUserService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}

func (s *UserService) Register(ctx context.Context, email, name string) (*domain.User, error) {
    existing, _ := s.repo.FindByEmail(ctx, email)
    if existing != nil {
        return nil, domain.ErrDuplicateEmail
    }
    user, err := domain.NewUser(email, name)
    if err != nil {
        return nil, err
    }
    return user, s.repo.Save(ctx, user)
}


// internal/infrastructure/postgres/user_repository.go — Implements interface
package postgres

import (
    "context"
    "database/sql"
    "github.com/google/uuid"
    "service-name/internal/application"
    "service-name/internal/domain"
)

type UserRepository struct{ db *sql.DB }

var _ application.UserRepository = (*UserRepository)(nil) // compile-time check

func (r *UserRepository) FindByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
    // ... query and map to domain.User
}
```

---

## ReactJS — Clean Architecture Layout

In frontend, Clean Architecture maps to a **feature-based structure** with clear separation between UI, state management, and data access.

### Directory Tree

```
src/
├── domain/                      # Layer 1 — Domain (innermost)
│   ├── user/
│   │   ├── User.ts              # TypeScript interface / type (no React)
│   │   └── UserErrors.ts        # Typed domain errors
│   └── product/
│       └── Product.ts
│
├── application/                 # Layer 2 — Use Cases / Application Logic
│   ├── user/
│   │   ├── useRegisterUser.ts   # Custom hook wrapping the use case
│   │   ├── useGetUser.ts
│   │   └── UserRepository.ts    # Interface (abstract port)
│   └── product/
│       └── useListProducts.ts
│
├── adapters/                    # Layer 3 — Interface Adapters
│   ├── api/                     # HTTP client implementations (implements repositories)
│   │   ├── UserApiRepository.ts
│   │   └── apiClient.ts         # Axios/fetch wrapper
│   └── store/                   # State management adapters (Zustand, Redux)
│       └── userStore.ts
│
├── infrastructure/              # Layer 4 — Frameworks & Drivers
│   ├── http/
│   │   └── axiosInstance.ts     # Axios config, interceptors, token refresh
│   ├── storage/
│   │   └── localStorageAdapter.ts
│   └── config/
│       └── env.ts
│
├── ui/                          # Presentation — React Components only
│   ├── pages/
│   │   ├── RegisterPage.tsx
│   │   └── UserProfilePage.tsx
│   ├── components/              # Reusable UI components (dumb/presentational)
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   └── Button.test.tsx
│   │   └── UserCard/
│   │       └── UserCard.tsx
│   └── layouts/
│       └── AppLayout.tsx
│
├── shared/                      # Cross-cutting: utils, hooks, constants
│   ├── hooks/
│   │   └── useDebounce.ts
│   └── utils/
│       └── formatDate.ts
│
├── App.tsx
└── main.tsx
```

### Key Conventions

| Element | Convention | Example |
|---|---|---|
| Domain types | `PascalCase` interface | `interface User { id: string; email: string }` |
| Repository interfaces | `NounRepository` | `UserRepository` |
| Application hooks | `useVerbNoun` | `useRegisterUser`, `useGetUser` |
| API adapters | `NounApiRepository` | `UserApiRepository` |
| Pages | `NounPage.tsx` | `RegisterPage.tsx` |
| Components | `PascalCase/index.tsx` | `UserCard/UserCard.tsx` |
| No business logic in components | UI components receive data and callbacks via props | |

### Code Example

```typescript
// domain/user/User.ts — Plain TypeScript, no React/Axios
export interface User {
  id: string;
  email: string;
  name: string;
  isActive: boolean;
}

export interface CreateUserInput {
  email: string;
  name: string;
}


// application/user/UserRepository.ts — Abstract port
import { User, CreateUserInput } from "@/domain/user/User";

export interface UserRepository {
  create(input: CreateUserInput): Promise<User>;
  findById(id: string): Promise<User>;
}


// application/user/useRegisterUser.ts — Use case as a custom hook
import { useState } from "react";
import { UserRepository } from "./UserRepository";
import { CreateUserInput, User } from "@/domain/user/User";

export function useRegisterUser(repo: UserRepository) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  async function register(input: CreateUserInput): Promise<User | null> {
    setLoading(true);
    setError(null);
    try {
      return await repo.create(input);
    } catch (e) {
      setError(e as Error);
      return null;
    } finally {
      setLoading(false);
    }
  }

  return { register, loading, error };
}


// adapters/api/UserApiRepository.ts — Implements the interface
import { UserRepository } from "@/application/user/UserRepository";
import { User, CreateUserInput } from "@/domain/user/User";
import { apiClient } from "./apiClient";

export class UserApiRepository implements UserRepository {
  async create(input: CreateUserInput): Promise<User> {
    const { data } = await apiClient.post<User>("/users", input);
    return data;
  }

  async findById(id: string): Promise<User> {
    const { data } = await apiClient.get<User>(`/users/${id}`);
    return data;
  }
}


// ui/pages/RegisterPage.tsx — UI only; no direct API calls
import { useRegisterUser } from "@/application/user/useRegisterUser";
import { UserApiRepository } from "@/adapters/api/UserApiRepository";

const repo = new UserApiRepository();

export function RegisterPage() {
  const { register, loading, error } = useRegisterUser(repo);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = new FormData(e.currentTarget);
    await register({
      email: form.get("email") as string,
      name: form.get("name") as string,
    });
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" required />
      <input name="name" type="text" required />
      <button type="submit" disabled={loading}>Register</button>
      {error && <p>{error.message}</p>}
    </form>
  );
}
```

---

## Cross-Language Rules Summary

| Rule | Python | Go | ReactJS |
|---|---|---|---|
| Domain has no framework imports | No SQLAlchemy, no FastAPI | No `net/http`, no ORM | No React, no Axios |
| Interfaces defined in Application layer | `ABC` in `application/repositories/` | `interface` in `internal/application/` | TypeScript `interface` in `application/` |
| Repository implementations in Infrastructure | `infrastructure/db/repositories/` | `internal/infrastructure/postgres/` | `adapters/api/` |
| DTOs cross layer boundaries | `application/dto/` | `application/dto/` | Props / Input types |
| No business logic in handlers/controllers/UI | Use cases called from routers | Use cases called from handlers | Logic in hooks, not components |
| Compile/runtime verification of interface impl | `mypy` type checking | `var _ Interface = (*Impl)(nil)` | TypeScript strict mode |
| Test use cases without infrastructure | Mock `UserRepository` ABC | Mock `UserRepository` interface | Mock `UserRepository` interface |
