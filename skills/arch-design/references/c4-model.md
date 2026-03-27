# C4 Diagram Generation

Always use **Mermaid** as default (renders in GitHub, Notion, Claude). Use **PlantUML** only when explicitly requested.

## Diagram Types

**C4 Context (Level 1)** — System boundary and external actors:
```mermaid
graph TB
    User["👤 User"] --> System["[System]\nYour System Name"]
    System --> ExtService["[External]\nThird-party Service"]
```

**C4 Container (Level 2)** — Internal containers/services:
```mermaid
graph TB
    subgraph System Boundary
        API["[Go Service]\nAPI Gateway"]
        Core["[Go Service]\nCore Module"]
        DB[("PostgreSQL")]
        Cache[("Redis/Valkey")]
    end
    User --> API --> Core --> DB
    Core --> Cache
```

**Sequence Diagram** — Key workflows:
```mermaid
sequenceDiagram
    participant C as Client
    participant A as API
    participant S as Service
    participant DB as Database
    C->>A: POST /resource
    A->>S: CreateResource(ctx, req)
    S->>DB: Insert
    DB-->>S: result
    S-->>A: domain object
    A-->>C: 201 Created
```

**ERD** — Data model:
```mermaid
erDiagram
    TENANT ||--o{ USER : has
    USER ||--o{ SESSION : has
```

**Flowchart** — Process flows, state machines:
```mermaid
flowchart LR
    A[Start] --> B{Condition}
    B -- yes --> C[Action]
    B -- no --> D[Alt Action]
```

**Rules for diagrams:**
- Always add a title and brief description above each diagram
- Keep diagrams focused — one diagram per concept, max ~15 nodes
- Use consistent naming with the rest of the design doc
- For multi-tenant systems, always show tenant isolation boundary