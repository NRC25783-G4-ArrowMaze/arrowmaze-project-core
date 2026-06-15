# Arrow Maze — Project Core 🎯

**Fuente única de verdad** para decisiones de arquitectura, especificaciones y diseño del puzzle game Arrow Maze.

## 🏗️ ¿Qué es Arrow Maze Project Core?

Este repositorio es el **compendio centralizado** de:
- ✅ **Decisiones arquitectónicas** documentadas y validadas
- ✅ **Especificaciones Gherkin (BDD)** listas para implementación
- ✅ **Histórico completo de sesiones SDD** con rationale de cada decisión
- ✅ **Blueprint** que guía la implementación en `arrow-maze-client` (React) y `arrow-maze-backend` (Express)

**Punto de control:** Junio 15, 2026 — A partir de aquí, todas las decisiones se centralizan en este repositorio.

## 🎮 Descripción del juego

Arrow Maze es un puzzle donde debes guiar flechas a través de un tablero para alcanzar objetivos. Implementado usando **Clean Architecture + Domain-Driven Design**, con especificaciones completas **antes** de escribir código (Specification-Driven Development).

**Estado actual:** Pre-implementación. ✅ Arquitectura finalizada, ✅ 5 features especificadas (A1-A5), ⏳ Implementación comienza Semana 1.

---

## 🔗 Repositorios relacionados

| Repo | Tech | Rol | Estado |
|---|---|---|---|
| **arrowmaze-project-core** (este) | Markdown + Gherkin | 📋 Decisiones y specs | ✅ Activo |
| [**arrow-maze-client**](https://github.com/NRC25783-G4-ArrowMaze/arrowmaze-game) | React 18 + Vite + TypeScript + Capacitor | 🎨 Frontend web + móvil | ⏳ Por crear |
| [**arrow-maze-backend**](https://github.com/NRC25783-G4-ArrowMaze/arrowmaze-backend) | Express.js + Node.js + TypeScript + PostgreSQL | 🔌 API REST + DB | ⏳ Por crear |

**Flujo de sincronización:**
```
Decisiones/Specs en project-core
        ↓
Implementación en arrow-maze-client (sigue specs A1-A5 + B/C/D)
Implementación en arrow-maze-backend (sigue specs F1-F4 + E)
        ↓
Testing contra Gherkin features
        ↓
Deployment coordinado
```

---

## 📁 Estructura de este repositorio

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

## 📌 Por qué "Project Core"

A partir de **Junio 15, 2026**, arrowmaze-project-core es:

| Aspecto | Antes | Ahora |
|---|---|---|
| **Decisiones** | Dispersas en múltiples documentos | ✅ Centralizadas aquí |
| **Fuente de verdad** | ❌ No definida | ✅ Este repositorio |
| **Histórico de decisiones** | En archivos locales separados | ✅ `.ai-usage/` centralizado |
| **Syncronización** | Manual entre repos | ✅ Features en project-core → ambos repos |
| **Specs BDD** | En gists externos | ✅ `features/` en este repo |

**Implicaciones para el equipo:**
- Todos los cambios de spec → actualizar `.feature` en project-core primero
- Todos los cambios de arquitectura → documentar en `.ai-usage/` con sesión SDD
- Frontend y backend **sincronizan specs** desde `features/` aquí
- Decisiones son **reproducibles y auditables** (historial completo en `.ai-usage/`)

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

- **[.ai-usage/manifest.json](./.ai-usage/manifest.json)** — Índice centralizado de todas las sesiones SDD (7 sesiones)
  - **Sesión checkpoint:** [2026-06-15: Project Core Checkpoint](./.ai-usage/2026-06/2026-06-15_project-core-checkpoint.md)
  - **Todas las sesiones:** Mayo 3 - Junio 15, 2026
  - Decisiones registradas con rationale completo
  - Artefactos generados (.feature files, matrices, reportes)
  - Métricas de IA assistance y team contribution

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

### Inmediatos (Semana 1 de implementación)

1. ✅ **P15 resolution** — Definir JSON schema para niveles (bloquea C2, F2)
2. ✅ **NQ4 resolution** — Elegir renderizado: CSS vs Canvas vs WebGL (bloquea B1, B2)
3. 📋 **Setup scaffolding** — Crear `arrow-maze-client` y `arrow-maze-backend` con estructura Clean Architecture
4. 🧪 **Implementar A1–A5** — Sprint 1–2 (motor núcleo sin UI)

### Mediano plazo

5. 📋 **Completar specs B–G** — Extender SDD a features de UI, backend, persistencia
6. 🎨 **UI/Rendering** — Implementar B1, B2 (renderizado + animaciones)
7. 🔌 **Backend + API** — Implementar F1–F4 (autenticación, distribución de niveles, leaderboard)

### Referencias completas en:

- **Roadmap detallado:** [docs/FEATURES.md](./docs/FEATURES.md) — 7 sprints, orden de dependencias
- **Bloqueadores activos:** Tabla en [docs/FEATURES.md](./docs/FEATURES.md#decisiones-que-aún-bloquean-features-específicos)
- **Estado de decisiones:** [.ai-usage/manifest.json](./.ai-usage/manifest.json)

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

---

## 💡 Cómo usar este repositorio

### Si eres implementador (developer)

1. **Empieza por CLAUDE.md** — Guía del proyecto y decisiones clave
2. **Lee docs/FEATURES.md** — Qué implementar y en qué orden (roadmap)
3. **Consulta features/*.feature** — Especificaciones exactas en Gherkin
4. **Valida decisiones** — Abre `.ai-usage/manifest.json` para ver rationale de cada decision
5. **Sigue Clean Architecture** — Estructura en `docs/STACK.md` es tu blueprint

### Si eres gestor/stakeholder

1. **Overview:** Este README + stats en [Project Core Checkpoint](./.ai-usage/2026-06/2026-06-15_project-core-checkpoint.md)
2. **Decisiones:** Búsca por feature (A1, A2, A3, etc.) en `.ai-usage/manifest.json`
3. **Timeline:** 7 sprints (~7 semanas), comenzando con resolución de P15 + NQ4
4. **Blockers:** Tabla en [docs/FEATURES.md](./docs/FEATURES.md) - qué bloquea qué

### Si necesitas hacer cambios

1. **Cambio en especificación:** Actualiza `.feature` correspondiente + crea sesión en `.ai-usage/`
2. **Cambio arquitectónico:** Documenta en `docs/STACK.md` + crea sesión SDD en `.ai-usage/`
3. **Cambio de decisión:** Abre issue, discute, documenta rationale, actualiza manifest
4. **Sincronización:** Ambos repos (`arrow-maze-client`, `arrow-maze-backend`) sincronizan desde aquí

---

## 📊 Métricas del proyecto (Estado actual)

| Métrica | Valor | Status |
|---|---|---|
| **Sesiones SDD completadas** | 7 | ✅ Finalizadas |
| **Decisiones documentadas** | 30+ | ✅ Registradas |
| **Features especificadas** | A1-A5 (5) | ✅ Listas para impl. |
| **Escenarios Gherkin** | ~100 | ✅ Cubiertos |
| **Bloqueadores activos** | P15, NQ4 | ⏳ Requieren resolución |
| **Tiempo ahorrado (IA)** | ~60 horas | 📈 80% efficiency gain |
| **Código listo para usar** | 70% | ⚠️ Requiere validación compilación |

---

**Última actualización:** 2026-06-15 (Checkpoint)  
**Proyecto:** Arrow Maze — Specification-Driven Development + Clean Architecture  
**Mantenido por:** Jrgil20  
**Contacto:** fariasjr223@gmail.com  
**Estado:** 🔴 Pre-implementación → 🟢 Listo para Semana 1 (tras resolver P15 + NQ4)
