# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 🎮 Project Overview

**Arrow Maze** is a puzzle game engine implemented using **Specification-Driven Development (SDD)** with Clean Architecture and Domain-Driven Design (DDD).

**Current Phase:** Specification authority + active client implementation. In `arrowmaze-game`: 
- **A1–A5** (motor), **B1–B3** (render/input): ✅ Implementado
- **C1** (flujo de partida): ✅ Veredicto de Dominio (IN_PROGRESS|WON|LOST desde A4); 📝 Spec lista (SDD 2026-07-07: autómata de pila ACTIVE/PAUSED/SETTINGS), 🏗️ Implementación en PR #22 (GameFlowController)
- **C2** (carga niveles): ✅ Implementado
- **C3** (selección de niveles): 📝 Spec lista (SDD 2026-07-05), sin implementar (bloqueada por D1)
- **C4** (pantallas de soporte): ⚠️ Parcial (GameOverlay fin de partida), bloqueada por C1 (ahora desbloqueada)
- **G1–G3** (audio, i18n, timer): 📝 Specs listas (SDD 2026-07-04), sin implementar
- **P23** (integración tiempo→score): 🟡 Parcial — decidido que SÍ afecta el score; el CÓMO espera sesión SDD propia de enmienda A5

Pending client work: D1 (persistencia local), C4 (finish), D2 (sincronización), G1–G3 implementation. The **backend is closed at `v1.0.0`** (E1–E2, F1–F4 implemented) in `arrowmaze-backend` and is now **frozen** in this repo; future backend versions evolve independently and are no longer mirrored here. This repo remains the single source of truth for specs and architecture decisions.

**Versioning policy (versionario hasta v1.0.0):** project-core documents each implementation repo **up to its `v1.0.0`**. Once a repo closes v1.0.0 its documentation here is **frozen**; later versions evolve independently and are *not* re-mirrored here (that would be a manual, non-automated duplicate). The client (`arrowmaze-game`) is **not yet closed** — it keeps being documented until it closes its own v1.0.0, then the same freeze applies. After those freezes this repo acts as a **historical bitácora** and may become highly outdated. See the "Política de versionado y congelamiento" section in the README.

**Key Characteristics:**
- **Methodology:** SDD with structured Q&A using Claude + Gherkin BDD
- **Specification language:** Spanish (features and decision documents)
- **Architecture pattern:** Clean Architecture (Domain → Application → Infrastructure)
- **Approach:** Design decisions are made iteratively and recorded in AI usage reports before implementation begins

---

## 📁 Repository Structure

```
arrowmaze-project-core/
├── features/                    # BDD Feature files (Gherkin/Spanish)
│   ├── A1-board_graph.feature
│   ├── A2-arrow_placement.feature
│   ├── A3-arrow_movement.feature
│   ├── A4-game_end_detection.feature
│   ├── A5-game_session_scoring.feature
│   ├── B1-board-rendering.feature
│   ├── B2-animation_feedback.feature
│   ├── B3-input-routing.feature
│   ├── C1-maquina_estados_partida.feature
│   ├── C2-carga-deserializacion-niveles.feature
│   ├── C3-seleccion-niveles-progreso.feature
│   ├── G1-audio-sfx-musica.feature
│   ├── G2-internacionalizacion.feature
│   └── G3-temporizador-nivel.feature
├── docs/                        # Design and architecture documentation
│   ├── FEATURES.md              # Feature dependency matrix + implementation roadmap
│   └── STACK.md                 # Technology stack decisions + folder structure for implementation
├── .ai-usage/                   # Structured AI session documentation (hidden folder)
│   ├── manifest.json            # Central index of all AI usage reports
│   ├── 2026-05/                 # May: Foundation & Architecture
│   ├── 2026-06/                 # June: Game Logic & Early Specs
│   └── 2026-07/                 # July: SDD Sessions (C3, C1, G1-G3, H1)
├── CLAUDE.md                    # This file
├── README.md                    # Brief project title (minimal)
└── .claude/                     # Claude Code local settings
```

---

## 🏗️ Architecture Overview

### Design Pattern: Clean Architecture + DDD

**Expected layers (when implementation begins):**

1. **Domain Layer** — Business logic and rules
   - Value Objects (VO): `Score`, `GameStatus`
   - Aggregates: `GameSession`, `Board`, `Arrow`
   - Domain Services: gameplay rules, movement validation
   - No external dependencies (pure business rules)

2. **Application Layer** — Use cases and orchestration
   - Use Cases: `PlayMoveUseCase`, `AdvanceArrowUseCase`, etc.
   - Application Services: coordinate domain logic
   - DTOs: shape data for interfaces

3. **Infrastructure Layer** — External dependencies
   - Persistence: `LevelRepository`, `ProgressRepository` (SQLite planned)
   - UI adapters: renderer, input handler
   - External APIs: authentication, leaderboards

### Key Architectural Decisions

- **GameSession as aggregate root** — manages game state (moves remaining, status, score), does NOT contain Board or Arrow[] directly
- **PlayMoveUseCase as wrapper** — orchestrates `AdvanceArrowUseCase` without extending it (SRP principle)
- **Score as immutable VO** — moved-only entity, calculated at game end
- **Graph-based board topology** — O(1) traversal using modular arithmetic; ports indexed, not cardinal directions
- **Deterministic ticks** — game time measured in ticks, not wall-clock seconds (reproducible in tests)

---

## 📘 Implementation-Ready Architecture (Next Phase)

Technology stack and folder structure decisions **have been finalized**. See **`docs/STACK.md`** for:

- **Tech stack chosen:** React 18 + TypeScript + Vite (frontend) | Express.js + TypeScript (backend) | Capacitor (mobile) | PostgreSQL + SQLite (databases)
- **Why this stack:** Fast build times, excellent TypeScript support on both ends, strong IA code generation, natural Clean Architecture fit
- **Folder structure** for both client (`arrow-maze-client`) and backend (`arrow-maze-backend`) repos—detailed layer breakdowns (domain, application, adapters, infrastructure)
- **Testing strategy:** Jest + React Testing Library (frontend), Jest + Supertest (backend); unit/integration/e2e patterns
- **Initial setup commands** — npm projects, folder scaffolding, dependency installation
- **First-sprint roadmap** — minimal Board entity, basic use case, React component skeleton

When implementation begins, clone the structure from STACK.md's folder trees exactly. Do not invent intermediate abstractions—build what the spec demands, no more.

**Backend architecture status (backend v1.0.0, 2026-07-09):** `arrowmaze-backend` already
materializes cross-cutting concerns via two AOP aspects (`ErrorHandlerAspect`,
`RequestLoggingAspect`) and exposes the API through OpenAPI/Swagger at `/api/docs`. GoF patterns
(Factory Method, Singleton, Adapter, Strategy) are documented in
`arrowmaze-backend/docs/design-patterns.md`. This work was **merged (PR #17)** and **released as
`v1.0.0`** (release #18), with build+test CI on every PR. The backend is now **frozen at v1.0.0**
in this repo — later backend versions evolve independently and are no longer mirrored here (see the
versioning policy in the README).

---

## 📋 Feature Groups and Dependencies

Features are organized into 7 groups (A–G) with clear dependencies. See **FEATURES.md** for the complete matrix.

**Sprint 1 (Core motor):**
- **A1** — Board graph initialization
- **A2** — Arrow placement (linked list structure)
- **A3** — Arrow movement and collision

**Sprint 2 (Game end logic):**
- **A4** — Victory/defeat detection + move consumption
- **A5** — Score calculation

**Sprites 3–7:** UI rendering, levels, persistence, auth, audio, i18n (not yet designed)

**Blocking decisions:**
- P15: JSON level schema (blocks C2, F2)
- NQ4: Rendering technology—CSS vs Canvas vs WebGL (blocks B1, B2)
- Others tracked in FEATURES.md

---

## 🎯 Specification-Driven Development (SDD) Workflow

This repo **owns the specs**. Implementation repos sync from here.

### How Specs Are Created

1. **Elicitation** — Claude structures Q&A to disambiguate design decisions
   - Deliverable: decision matrix (closed/open questions)
   - Example: "Penalización lineal vs exponencial por fallas consecutivas?"

2. **Consolidation** — Feature spec synthesized from validated decisions
   - Deliverable: `.feature` file (Gherkin BDD, Spanish)
   - Includes: scenarios, background, examples, invariants

3. **Review & Iteration** — Design validated before implementation repos start
   - Validation: edge cases, topology, dependencies
   - Pattern: quality-driven, not speed-driven

### How Implementation Syncs

- Implementation repos pull specs from `features/` here
- Changes to spec → update `.feature` file here first, then implementation follows
- No ad-hoc implementation changes; all changes traced back to SDD session

### AI Usage Records

**Location:** `.ai-usage/manifest.json` — central index with metadata for all sessions (hidden folder)

Each session includes:
- Date, model, duration
- Decisions made (matrix format)
- Artefacts generated (`.feature` files, architectural notes, tech stack analysis)
- Methodology and validation performed

**Why this matters:** SDD requires explicit traceability from decision → design → spec → implementation. All design rationale is recorded before code begins.

---

## 🧪 Testing & Specification

### Gherkin Feature Files (Scenario-based testing)

- **Language:** Spanish (Gherkin syntax)
- **Location:** `/features/A*.feature`
- **Format:** Given-When-Then with tables, backgrounds, scenario outlines

**Example snippets:**
```gherkin
Escenario: Flecha se desplaza un puerto en dirección válida
  Dado un tablero 3×3 con flecha en C0 apuntando al puerto 1
  Cuando se ejecuta un movimiento
  Entonces la flecha avanza a C1
  Y su cabeza está en puerto 3
```

### Test Coverage Strategy (planned)

When implementation begins:
1. **Unit tests** map 1:1 to domain invariants
2. **Integration tests** validate Domain → Application orchestration
3. **Scenario tests** directly execute Gherkin steps against domain code

**Command structure** (to be defined):
- `npm run test` — all tests
- `npm run test:unit` — domain logic only
- `npm run test:features` — Gherkin → step definitions
- `npm run test:integration` — use cases + domain

---

## 🔑 Key Design Decisions & Invariants

### Board & Graph (A1)

- **Cell ports:** indexed 0–(P-1), where P = total ports (always even)
- **Opposite port formula:** `(entry + P/2) % P`
- **Topology:** agnóstic to visual shape (square, hexagon, etc.); only constraint is even port count

### Arrow Movement (A3)

- **Simultaneous movement:** all arrows advance at the same tick
- **Head-only collision check:** only the arrow's head checks for collisions
- **Collision outcomes:** `blocked` (halts arrow, consumes move), `success` (advances)
- **Atomicity:** entire move succeeds or fails as unit

### Move Consumption (A4)

- ✅ `outcome=blocked` (collision) → consumes move
- ✅ Natural success → consumes move
- ❌ `success=false` due to system error → does NOT consume
- **Idempotence:** `evaluateStatus()` on terminal states always returns same result

### Scoring (A5)

**Formula:**
```
finalScore = max(0,
    max(0, BASE − ticks × DECAY)
  − Σ(BASE_PENALTY × consecutiveFailCount[i])
  + (flawlessVictory ? FLAWLESS_BONUS : 0)
)
```

**Key rules:**
- Only visible in WON state; NULL in LOST or IN_PROGRESS
- Flawless = zero fails + WON status
- Consecutive fail count resets on any success
- Clamps to 0 (never negative); no upper limit

---

## 💾 Configuration & Local Setup

### Claude Code Settings

**Location:** `.claude/settings.local.json`

Defines permissions for Claude to:
- Fetch Gherkin specs from GitHub gists
- Run curl commands for research

**Do not edit settings unless adding new permissions.**

### When Implementation Begins

Both `arrow-maze-client` and `arrow-maze-backend` repos will include:
- `package.json` — Node.js dependencies + scripts (React/Express, Jest, testing libraries)
- `tsconfig.json` — TypeScript configuration (strict mode, target ES2020)
- `.env.example` — environment variable template
- `jest.config.js` — test runner config with ts-jest
- `vite.config.ts` (frontend) / Express app structure (backend) — see `docs/STACK.md` for full structure

---

## 🛠️ Commands (Implementation Phase)

**This is the specification/design repo.** The actual implementation will occur in two separate repos: `arrow-maze-client` and `arrow-maze-backend`. See `docs/STACK.md` for exact setup commands for each.

### Design/Specification Phase (Current)

```bash
# No build/test/test commands yet—focus is on Gherkin specs and design docs
# Read feature files in ./features/
# Review design decisions in .ai-usage/
# Check implementation roadmap in docs/FEATURES.md
```

### Implementation Phase (Next)

**Frontend (`arrow-maze-client`):**
```bash
npm create vite@latest arrow-maze-client -- --template react-ts
cd arrow-maze-client
npm install
npm run dev           # Start dev server
npm run test          # Run Jest tests
npm run build         # Build for production
```

**Backend (`arrow-maze-backend`):**
```bash
mkdir arrow-maze-backend && cd arrow-maze-backend
npm init -y
npm install express typescript ts-node cors dotenv
npm install jsonwebtoken bcryptjs pg
npx ts-node src/main.ts    # Run backend
npm run test                 # Run tests
```

See **`docs/STACK.md`** for the complete folder structures and sprint-level implementation plan for both repos.

---

## 📚 Important References

### Primary Design Documents
- **`docs/FEATURES.md`** — feature matrix, implementation roadmap, blocking decisions, sprint order
- **`docs/STACK.md`** — technology stack, folder structure for client/backend, setup commands, testing patterns (crucial for implementation phase)

### Specification Files
- **`features/*.feature`** — executable specs (Gherkin, Spanish)
- Search by feature ID: A1, A2, A3, A4, A5 (Sprints 1–2 designed; B–G pending)

### AI Usage & Design Rationale
- **`.ai-usage/manifest.json`** — index of all AI sessions with metadata (hidden folder)
- **`.ai-usage/2026-05/`** — architectural foundation decisions
- **`.ai-usage/2026-06/`** — game logic and scoring specs
- Each session file is dated and linked in manifest.json

---

## 🎯 Working with This Codebase

### When Reviewing Specs
- Check **FEATURES.md** for feature #, dependencies, and blocking decisions
- Read the corresponding `.feature` file for detailed scenarios
- Review the AI usage report to understand design context and rejected alternatives

### When Making Design Changes
- **Always consult FEATURES.md first** — understand dependencies before changing anything
- **Update the feature file** if scenarios change; don't change domain rules without reflection in Gherkin
- **Document the decision** — add a note to the AI usage report explaining why (rationale for future devs)

### Before Implementation
- **Validate all feature files** — ensure scenarios are deterministic and cover edge cases
- **Confirm architectural boundaries** — Domain/Application/Infrastructure separation is clear
- **Check invariants** — each feature should have explicit, testable invariants documented

### During Implementation
- **Implement domain layer first** — business rules in isolation, no external deps
- **Follow SRP strictly** — one use case = one responsibility; use cases compose, don't extend
- **Map tests 1:1 to Gherkin** — each scenario should have equivalent test

---

## ⚠️ Important Notes

1. **Spanish specification language** — All features and many decision docs are in Spanish. Machine translation may cause confusion; refer to original when in doubt.

2. **This repo is the spec authority** — All `.feature` files, design decisions, and architecture rules live here. Implementation repos (`arrow-maze-client`, `arrow-maze-backend`) sync specs from here, not the other way around.

3. **Spec changes require SDD sessions** — Request changes via structured Q&A (add to `.ai-usage/`), not ad-hoc edits to `.feature` files. Rationale must be documented.

4. **Strict dependency chain** — A1 → A2 → A3 → A4 → A5 is hard. Sprint order in `docs/FEATURES.md` is final; reordering requires validating impact on all downstream features.

5. **Clean Architecture is mandatory** — Domain/Application/Infrastructure/Presentation separation is non-negotiable. Every feature must respect layer boundaries per `docs/STACK.md`.

---

## 🚀 Next Steps

### Immediate (current focus)
1. ✅ **P15 resolved** — JSON level schema materialized in C2 (`LevelData`)
2. ✅ **NQ4 resolved** — Rendering technology = **SVG** (B1/B2 implemented)
3. **Continue client implementation** — pending order: D1 → C4 (finish) → C3 → G2 → G1 → G3 → D2 (see `docs/BORRADOR-features-pendientes.md`)
4. ✅ **P22/P24 resolved, P23 partial** (SDD 2026-07-04) — G1/G2/G3 specs ready (Presentation only); P23: time WILL affect score, the *how* (A5 amendment mechanism) is still open
5. **Close remaining decisions** — P23 (how time enters A5), P20 (F4), P21 (D2), level-unlock rule (C3), local-user scope (D1), UI `PAUSED` state (C4)

### Implementation Phase (After approval)
1. **Clone template structure** — Use `docs/STACK.md` folder structure exactly for both repos
2. **Implement A1–A5** — Core game motor in frontend domain layer, following specs
3. **Design B–G specs** — Extend SDD to remaining feature groups (rendering, levels, persistence, auth)
4. **Setup backend API** — Express.js + PostgreSQL for auth, levels, leaderboard
5. **Connect frontend-backend** — Use case repos adapt to API contracts from F1–F4

---

**Last updated:** 2026-07-09  
**Maintained by:** Jrgil20  
**Reference:** 
- Complete design history: `.ai-usage/manifest.json` (hidden folder)
- Implementation roadmap: `docs/FEATURES.md`
- Tech stack & architecture: `docs/STACK.md`
