# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 🎮 Project Overview

**Arrow Maze** is a puzzle game engine implemented using **Specification-Driven Development (SDD)** with Clean Architecture and Domain-Driven Design (DDD).

**Current Phase:** Specification and architectural design (pre-implementation). No production code yet—focus is on BDD feature specifications and design decisions.

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
│   ├── A1-board_graph.feature   # Board initialization and graph representation
│   ├── A2-arrow_placement.feature
│   ├── A3-arrow_movement.feature
│   ├── A4-game_end_detection.feature
│   └── A5-game_session_scoring.feature
├── ai-usage/                    # Structured AI session documentation
│   ├── MANIFEST.md              # Central index of all AI usage reports
│   ├── 2026-05/                 # May: Foundation & Architecture
│   └── 2026-06/                 # June: Game Logic & Specs
├── FEATURES.md                  # Feature dependency matrix + implementation roadmap
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

## 🎯 Specification-Driven Development Workflow

### How This Project Uses AI

1. **Elicitation** — Claude structures Q&A to disambiguate design decisions
   - Deliverable: decision matrix (closed/open questions)
   - Example: "Penalización lineal vs exponencial por fallas consecutivas?"

2. **Consolidation** — Feature spec synthesized from validated decisions
   - Deliverable: `.feature` file (Gherkin BDD, Spanish)
   - Includes: scenarios, background, examples

3. **Review & Iteration** — Design reviewed before implementation
   - Validation: edge cases, invariants, topology
   - Pattern: quality-driven, not speed-driven

### AI Usage Records

**Location:** `/ai-usage/MANIFEST.md` — central index with metadata for all sessions

Each session includes:
- Date, model, duration
- Decisions made (matrix format)
- Artefacts generated (`.feature` files, architectural notes)
- Methodology and validation performed

**Why this matters:** SDD requires explicit traceability from decision → design → spec → implementation.

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

### Future Project Configuration

When implementation begins:
- `package.json` — Node.js dependencies + scripts
- `tsconfig.json` — TypeScript configuration
- `.env` — environment variables (if needed)
- Jest/Cucumber configuration for test runners

---

## 🛠️ Commands (When Development Starts)

These are **templates**—exact commands TBD pending architecture finalization:

```bash
# Install dependencies
npm install

# Run all tests
npm run test

# Run unit tests only
npm run test:unit

# Run feature/scenario tests (Gherkin)
npm run test:features

# Lint & format
npm run lint
npm run format

# Build (if applicable)
npm run build

# Watch mode for development
npm run dev
```

**Until implementation:** no build/test/lint commands apply. Focus is on Gherkin specs and design docs.

---

## 📚 Important References

### Primary Decision Log
- **FEATURES.md** — feature matrix, implementation roadmap, blocking decisions

### Specification Files
- **features/*.feature** — executable specs (Gherkin)
- Search by feature ID: A1, A2, A3, A4, A5 (Sprints 1–2 designed; B–G pending)

### AI Usage & Design Rationale
- **ai-usage/MANIFEST.md** — index of all AI sessions with metadata
- **ai-usage/2026-05/** — architectural foundation decisions
- **ai-usage/2026-06/** — game logic and scoring specs

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

2. **Pre-implementation phase** — No source code exists yet. CLAUDE.md will evolve as actual development begins.

3. **Specification-Driven** — Design decisions are frozen in Gherkin before coding begins. Request changes via structured Q&A, not ad-hoc modifications.

4. **SDD dependency chain** — A1 → A2 → A3 → A4 → A5 forms a strict dependency chain. Don't skip steps.

5. **Architectural constraints** — Clean Architecture + DDD is not optional; it's foundational. Every feature must respect layer boundaries.

---

## 🚀 Next Steps (For Future Sessions)

1. **P15 resolution** — Finalize JSON schema for level definitions (blocks Sprint 3)
2. **NQ4 resolution** — Choose rendering technology (CSS/Canvas/WebGL)
3. **Feature B–G design** — Extend SDD to remaining feature groups
4. **Setup scaffolding** — `package.json`, TypeScript config, test infrastructure
5. **Implement A1–A5** — Core game motor using validated specs

---

**Last updated:** 2026-06-15  
**Maintained by:** Jrgil20  
**Reference:** `/ai-usage/MANIFEST.md` for complete design history
