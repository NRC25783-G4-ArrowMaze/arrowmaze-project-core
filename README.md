# Arrow Maze — Puzzle Game Engine

Una aplicación de puzzle interactivo basada en **Specification-Driven Development (SDD)**, Clean Architecture y Domain-Driven Design.

## 🎮 Descripción rápida

Arrow Maze es un puzzle donde debes guiar flechas a través de un tablero para alcanzar objetivos. Actualmente en fase de especificación y diseño arquitectónico (pre-implementación).

---

## 📁 Estructura del proyecto

```
arrowmaze-project-core/
├── features/                    # Especificaciones BDD (Gherkin/Spanish)
│   ├── A1-board_graph.feature
│   ├── A2-arrow_placement.feature
│   ├── A3-arrow_movement.feature
│   ├── A4-game_end_detection.feature
│   └── A5-game_session_scoring.feature
│
├── docs/                        # Documentación de arquitectura y diseño
│   ├── STACK.md                # Stack tecnológico elegido + estructura de carpetas
│   ├── FEATURES.md             # Matriz de features y roadmap de implementación
│   └── README.md               # Este archivo
│
├── ai-usage/                    # Registros de sesiones de IA (SDD)
│   ├── MANIFEST.md              # Índice central de sesiones con metadata
│   ├── 2026-05/                 # Mayo: Fundación & Arquitectura
│   └── 2026-06/                 # Junio: Lógica del juego & Specs
│
├── CLAUDE.md                    # Instrucciones para Claude Code (este proyecto)
└── .claude/                     # Configuración local de Claude Code
```

---

## 🚀 Documentación principal

### Para entender el proyecto:

1. **[CLAUDE.md](./CLAUDE.md)** — Guía de referencia para trabajar con este codebase
   - Descripción general del proyecto
   - Estructura del repositorio y decisiones arquitectónicas
   - Invariantes clave del juego
   - Workflow de Specification-Driven Development

2. **[docs/FEATURES.md](./docs/FEATURES.md)** — Matriz de features y roadmap
   - 7 grupos de features (A–G) con dependencias
   - Orden de implementación (7 sprints)
   - Decisiones pendientes que bloquean features

3. **[docs/STACK.md](./docs/STACK.md)** — Stack tecnológico y arquitectura
   - Tech stack elegido (React + Capacitor + Express.js)
   - Estructura de carpetas para frontend y backend
   - Ejemplos de Clean Architecture en código
   - Setup inicial y primer sprint

### Para ver el historial de decisiones:

- **[ai-usage/MANIFEST.md](./ai-usage/MANIFEST.md)** — Índice de todas las sesiones SDD
  - Meta: fecha, modelo, duración
  - Decisiones registradas
  - Artefactos generados (.feature files, notas de diseño)

---

## 🏗️ Arquitectura de alto nivel

El proyecto sigue **Clean Architecture + Domain-Driven Design**:

```
Presentación (React)
    ↓ depende de
Aplicación (Use Cases)
    ↓ depende de
Adaptadores (Repositories)
    ↓ depende de
Dominio (Entidades puras) ← NUNCA DEPENDE DE NADA
```

**Separación clara:**
- **Domain Layer** — Lógica de negocio pura (tablero, flechas, puntuación)
- **Application Layer** — Casos de uso orquestadores
- **Infrastructure Layer** — Detalles técnicos (BD, API, UI)

---

## 📋 Fases del proyecto

### Fase 1: Especificación (Actual)
- ✅ Decisiones de arquitectura (Clean Architecture + DDD)
- ✅ Especificaciones en Gherkin (features A1–A5 diseñadas)
- ✅ Stack técnico elegido: React + Capacitor + Express.js
- 🔄 Finalizar features B–G
- 📋 Resolver decisiones pendientes (P15, NQ4, etc.)

### Fase 2: Implementación (Próxima)
- Crear scaffolding: `package.json`, `tsconfig.json`, configuración
- Implementar Sprint 1: A1–A3 (motor núcleo)
- Mapear tests 1:1 con Gherkin
- Setup CI/CD

### Fase 3: Completitud
- Sprints 4–7: UI, persistencia, backend, sincronización

---

## 🎯 Sprint 1 (Motor núcleo)

**Objetivo:** Implementar A1–A3 sin interfaz de usuario

| Feature | Descripción | Estado |
|---|---|---|
| A1 | Inicialización del tablero como grafo de nodos | 📋 Especificado |
| A2 | Colocación de flechas como listas enlazadas | 📋 Especificado |
| A3 | Movimiento y resolución de colisiones | 📋 Especificado |

Bloqueadores: **P15** (esquema JSON), **NQ4** (tecnología de renderizado)

---

## 🧪 Especificaciones (Gherkin)

Todas las features están especificadas en **Gherkin (BDD)** en español:

```bash
features/
├── A1-board_graph.feature          # Inicialización del tablero
├── A2-arrow_placement.feature      # Colocación de flechas
├── A3-arrow_movement.feature       # Movimiento de flechas
├── A4-game_end_detection.feature   # Victoria/derrota
└── A5-game_session_scoring.feature # Cálculo de puntuación
```

Cada `.feature` incluye:
- Background (setup)
- Múltiples escenarios
- Tablas de ejemplos
- Invariantes explícitas

---

## 🔑 Decisiones clave

### Board como grafo
- Celdas = nodos, puertos = bordes
- Flechas navegan por puertos (no direcciones cardinales)
- Formulario opuesto: `(entrada + P/2) % P`

### GameSession como agregado raíz
- Gestiona movimientos disponibles, estado, puntuación
- NO contiene directamente Board ni Arrow[] (referencia indirecta)

### Score como Value Object
- Inmutable, calculado al final
- Fórmula: `BASE - ticks × DECAY - Σ(penalizaciones) + bonificación`

---

## 💻 Tecnología elegida

| Aspecto | Tech | Motivo |
|---|---|---|
| Frontend | React 18 + TypeScript + Vite | Compilación 1-2s; test sin emulador; IA genera bien |
| Móvil | Capacitor | Reutiliza web app → Android/iOS |
| Backend | Express.js + Node.js | Mismo lenguaje (TypeScript) en ambos lados |
| BD | PostgreSQL (prod) + SQLite (local) | Flexible; SQLite para testing |
| Testing | Jest + React Testing Library | Estándar; rápido en terminal |
| Deploy | GitHub Actions | CI/CD integrado |

**Score:** 8.73/10

---

## 🛠️ Próximos pasos

1. **Resolver P15** — Definir esquema JSON para niveles
2. **Resolver NQ4** — Elegir tecnología de renderizado (CSS/Canvas/WebGL)
3. **Completar specs B–G** — Extender SDD a features de UI, backend, etc.
4. **Setup scaffolding** — Crear repos `arrow-maze-client` y `arrow-maze-backend`
5. **Implementar A1–A5** — Sprint 1–2 usando specs validadas

---

## 📚 Referencias

### Documentos principales
- [CLAUDE.md](./CLAUDE.md) — Guía de este codebase
- [docs/STACK.md](./docs/STACK.md) — Stack y arquitectura
- [docs/FEATURES.md](./docs/FEATURES.md) — Features y roadmap
- [ai-usage/MANIFEST.md](./ai-usage/MANIFEST.md) — Historial SDD

### Especificaciones Gherkin
- [features/A1-board_graph.feature](./features/A1-board_graph.feature)
- [features/A2-arrow_placement.feature](./features/A2-arrow_placement.feature)
- [features/A3-arrow_movement.feature](./features/A3-arrow_movement.feature)
- [features/A4-game_end_detection.feature](./features/A4-game_end_detection.feature)
- [features/A5-game_session_scoring.feature](./features/A5-game_session_scoring.feature)

---

## ⚠️ Notas importantes

1. **Pre-implementación** — Este proyecto está en fase de diseño. No hay código fuente aún.
2. **Especificaciones en español** — Todas las features y muchos documentos de decisión están en español.
3. **SDD riguroso** — Las decisiones de diseño están congeladas en Gherkin antes de que comience la implementación.
4. **No saltar pasos** — La cadena A1 → A2 → A3 → A4 → A5 es estricta.

---

**Última actualización:** 2026-06-15  
**Mantenido por:** Jrgil20  
**Contacto:** fariasjr223@gmail.com
