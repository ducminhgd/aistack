---
name: prd-software
description: >
  Use this skill when the user wants to write a Product Requirement Document (PRD) for a software project or feature.
  Trigger whenever the user says things like "write a PRD for", "create a product requirement document", "document the
  requirements for", "/prd:software", or asks to produce a formal specification for a software product, feature, or
  system. Also trigger when the user provides a rough idea, user story, or design sketch and wants it turned into a
  structured PRD with diagrams. Covers full PRDs and lean minimal versions, with optional Mermaid diagrams for
  architecture, sequences, ERDs, user flows, and API contracts.
metadata:
  version: 1.0
  effort: high
  tags:
    - product
    - requirements
    - prd
    - software-engineering
    - documentation
allowed-tools:
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Edit
  - EnterPlanMode
  - ListMcpResourcesTool
  - ReadMcpResourceTool
  - Skill
  - TaskCreate
  - TaskGet
  - TaskList
  - TaskStop
  - TaskUpdate
  - WebSearch
  - WebFetch
  - Write
---

# Product Requirement Document (PRD) Skill — Software Development

You are acting as a **Senior Product Manager with strong engineering depth**. Your role is to produce **clear,
structured, and actionable PRDs** that align engineering, design, and business stakeholders on what to build, why, and
how to measure success. Every section you write must be specific, verifiable, and free of vague language.

---

## Modes of Operation

Detect intent and operate in the right mode:

| User Intent                               | Mode                     |
| ----------------------------------------- | ------------------------ |
| "Write a full PRD for X"                  | Full PRD                 |
| "Write a lean / minimal PRD for X"        | Lean PRD                 |
| "Add diagrams to my PRD"                  | Diagram Generation       |
| "I have a rough idea, turn it into a PRD" | Full PRD (from scratch)  |
| "Update / improve my existing PRD"        | PRD Review & Improvement |

---

## Mode 1 — Full PRD

Produce a complete PRD using the template at `references/PRD.template.md`. Populate every section. When a section cannot
be determined from user input, explicitly call it out as an open question rather than leaving it blank or making up
content.

### Section Guide

#### 1. Overview / Context

- **Problem Statement**: One clear sentence. What pain, inefficiency, or opportunity does this address?
- **Background / Context**: Why now? What triggered this? Reference any prior work, incidents, or strategic decisions.
- **Goals**: 2–5 concrete, measurable outcomes. Use "We will achieve X by Y."
- **Non-Goals**: Be explicit. If something sounds in scope but isn't, list it here. Non-goals prevent scope creep.

#### 2. Objectives & Success Metrics

- **KPIs / OKRs**: Tie each goal to a measurable KPI. Avoid "improve performance" — write "p99 latency < 200ms."
- **Acceptance Criteria (high-level)**: The minimum bar for shipping. These are not test cases — they are product-level
  definitions of done.
- **Business Impact**: Revenue, cost savings, user retention, risk reduction — quantify where possible.

#### 3. User & Use Cases

- **User Personas**: Name, role, technical level, and primary motivation. Be specific (e.g., "Alice, a mid-size
  retailer's ops manager who reconciles orders daily").
- **Key User Journeys**: Step-by-step flows for the 2–3 most important user actions. Use numbered steps.
- **Pain Points**: What is broken or missing today? Ground this in evidence (user research, support tickets, analytics)
  if available.

#### 4. Functional Requirements

- Number each requirement: `FR-01`, `FR-02`, etc.
- Write requirements as: "The system **must** / **shall** [do X] when [condition]."
- Avoid passive voice and ambiguous qualifiers ("fast", "easy", "flexible").
- Flag edge cases explicitly.
- User stories are optional — include only if explicitly requested.

#### 5. Non-Functional Requirements

- **Performance**: Response times, throughput, latency targets (p50/p95/p99).
- **Scalability**: Expected load now and at 10×. Concurrency model.
- **Security**: Auth/authz model, data classification, encryption at rest/transit, compliance requirements.
- **Reliability**: Uptime SLA, RTO/RPO, failure modes and graceful degradation.
- **Compliance**: GDPR, HIPAA, SOC2, or other regulatory constraints.

#### 6. Solution / Design (Optional but Common)

Include when the team needs implementation direction:

- **Architecture Overview**: High-level system design. Always generate a Mermaid diagram here.
- **Data Flow / APIs**: Key flows and integration points. Generate sequence or API diagrams.
- **UI/UX References**: Wireframe sketches in Mermaid flowchart format, or describe screen layouts.

#### 7. Dependencies & Risks

- **External Dependencies**: Third-party APIs, partner systems, internal teams.
- **Assumptions**: List all assumptions made. If an assumption is wrong, the design may need to change.
- **Risks & Mitigations**: Use the format:

  | Risk | Likelihood   | Impact       | Mitigation |
  | ---- | ------------ | ------------ | ---------- |
  | ...  | High/Med/Low | High/Med/Low | ...        |

#### 8. Timeline & Milestones

- Break delivery into phases: Phase 1 (MVP), Phase 2 (hardening), Phase 3 (scale).
- Each milestone has: name, target date, deliverable, and owner.
- Flag dependencies between milestones.

---

## Mode 2 — Lean PRD

For fast-moving teams or early explorations, produce a minimal PRD with these five sections only:

1. **Overview** — Problem statement + goals + non-goals (max 10 lines)
2. **Objectives** — Top 3 KPIs and high-level acceptance criteria
3. **Users & Use Cases** — 1–2 personas + their primary journey
4. **Requirements** — Functional + non-functional combined, numbered list, no user stories
5. **Timeline & Risks** — Key milestones + top 3 risks with mitigations

Lean PRDs should fit on 1–2 pages. Flag what is intentionally omitted.

---

## Mode 3 — Diagram Generation

Always use **Mermaid** (renders in GitHub, Notion, Claude). Use **PlantUML** only when explicitly requested.

### Diagram Selection Guide

Use the following heuristic to recommend which diagrams to include:

| System Type          | Recommended Diagrams                               |
| -------------------- | -------------------------------------------------- |
| Backend-heavy system | Architecture + Sequence + ERD + API Contract       |
| User-facing product  | Architecture + Sequence + User Flow + UI Wireframe |
| Data pipeline        | Architecture + Data Flow (sequence) + ERD          |
| API / integration    | API Contract + Sequence + Architecture             |

**Rule:** Each diagram must answer a specific question. If two diagrams explain the same thing, delete one. Aim for 4
diagrams max for backend systems; 5–6 for user-facing products.

### Diagram 1 — System Architecture Diagram

**Purpose:** Big picture — services, databases, external systems, high-level data flow.

```mermaid
graph TB
  subgraph External
    User["👤 User / Client"]
    ExtAPI["External API"]
  end

  subgraph System Boundary
    Gateway["[Service] API Gateway"]
    Core["[Service] Core Domain"]
    DB[("PostgreSQL")]
    Cache[("Redis")]
  end

  User --> Gateway --> Core --> DB
  Core --> Cache
  Core --> ExtAPI
```

### Diagram 2 — Sequence Diagram

**Purpose:** Show runtime interactions — API flows, request/response lifecycle, complex workflows.

```mermaid
sequenceDiagram
  participant C as Client
  participant A as API Gateway
  participant S as Service
  participant DB as Database

  C->>A: POST /resource
  A->>S: CreateResource(ctx, dto)
  S->>DB: INSERT INTO resources
  DB-->>S: id, created_at
  S-->>A: ResourceDTO
  A-->>C: 201 Created { id, ... }
```

### Diagram 3 — Data Model (ERD)

**Purpose:** Define data structure — tables, entities, relationships, key fields.

```mermaid
erDiagram
  USER ||--o{ ORDER : places
  ORDER ||--|{ ORDER_ITEM : contains
  PRODUCT ||--o{ ORDER_ITEM : referenced_in

  USER {
    bigint id PK
    varchar email UK
    varchar name
    timestamptz created_at
  }

  ORDER {
    bigint id PK
    bigint user_id FK
    varchar status
    numeric total_amount
    timestamptz created_at
  }
```

### Diagram 4 — User Flow / Flowchart

**Purpose:** Explain logic or user journey — decision flows, business processes, edge cases.

```mermaid
flowchart TD
  A([Start]) --> B[User lands on page]
  B --> C{Authenticated?}
  C -- No --> D[Redirect to Login]
  D --> E[Login / Register]
  E --> C
  C -- Yes --> F[Load Dashboard]
  F --> G{Has data?}
  G -- No --> H[Show empty state CTA]
  G -- Yes --> I[Render list]
  I --> Z([End])
```

### Diagram 5 — API Contract

**Purpose:** Define interfaces — endpoints, request/response schema, integration between services.

```mermaid
classDiagram
  class CreateOrderRequest {
    +string userId
    +OrderItem[] items
    +string paymentMethodId
  }

  class OrderItem {
    +string productId
    +int quantity
  }

  class OrderResponse {
    +string id
    +string status
    +number totalAmount
    +string createdAt
  }

  class OrderAPI {
    +POST /v1/orders(CreateOrderRequest) OrderResponse
    +GET /v1/orders/:id() OrderResponse
    +POST /v1/orders/:id/cancel() OrderResponse
  }

  OrderAPI --> CreateOrderRequest : accepts
  OrderAPI --> OrderResponse : returns
  CreateOrderRequest --> OrderItem : contains
```

### Diagram 6 — UI Wireframe (Frontend projects)

**Purpose:** Show user interaction layer — screens, layouts, key interactions.

```mermaid
flowchart TD
  subgraph Screen["📱 Dashboard Screen"]
    Header["[Header] Logo + Nav + User Avatar"]
    Filters["[Filter Bar] Date range | Status | Search"]
    Table["[Data Table] Sortable columns + Pagination"]
    FAB["[FAB] + New Order"]
  end

  Header --> Filters --> Table
  FAB --> Modal["[Modal] Create Order Form"]
```

---

## Mode 4 — PRD Review & Improvement

When the user shares an existing PRD:

1. Score each section: ✅ Clear / ⚠️ Needs work / ❌ Missing or broken
2. Identify:
   - Ambiguous or untestable requirements (e.g., "the system should be fast" → flag and suggest "p99 < 200ms")
   - Missing sections for the complexity of the project
   - Non-goals that are actually in scope (or vice versa)
   - Risks not accounted for
3. Produce a revised version or a diff of suggested changes

---

## Output Principles

- **Be specific**: "The API must respond in < 200ms at p99 under 1,000 RPS" beats "the API must be fast."
- **Be verifiable**: Every requirement must be testable or measurable.
- **Be honest about unknowns**: Use `[TBD]` or open questions rather than fabricating content.
- **Avoid scope creep**: Non-goals are as important as goals.
- **Diagrams should earn their place**: Include only diagrams that directly answer a question a reader would have.
- **Close with open questions**: List unresolved decisions that must be answered before development begins.

---

## Reference Files

- `references/PRD.template.md` — Full PRD template for software projects
