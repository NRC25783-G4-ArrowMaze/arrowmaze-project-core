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

**Estado actual:** ✅ Arquitectura finalizada, ✅ 23 features especificadas en grupos A–H, 🔄 En implementación (C3, C4, D1, D2, G1–G3, H1). Ver estado detallado por feature en [docs/FEATURES.md](./docs/FEATURES.md).

---

## 🔗 Repositorios relacionados

| Repo | Tech | Rol |
|---|---|---|
| **arrowmaze-project-core** (este) | Markdown + Gherkin | 📋 **Fuente única de verdad** — Especificaciones y decisiones arquitectónicas |
| [**arrow-maze-client**](https://github.com/NRC25783-G4-ArrowMaze/arrowmaze-game) | React 18 + Vite + TypeScript + Capacitor | 🎨 Implementación del frontend (sincroniza specs desde aquí) |
| [**arrow-maze-backend**](https://github.com/NRC25783-G4-ArrowMaze/arrowmaze-backend) | Express.js + Node.js + TypeScript + PostgreSQL | 🔌 Implementación del backend (sincroniza specs desde aquí) |

**Flujo de trabajo:**
```
Cambios en specs/decisiones
        ↓
Actualizar features/*.feature + docs/ en project-core
        ↓
arrow-maze-client y arrow-maze-backend sincronizan
desde las specs aquí
```

---

## 📁 Estructura de este repositorio

```
arrowmaze-project-core/
├── features/                    # Especificaciones BDD (Gherkin/Spanish) — 23 features, grupos A-H
│   ├── A1-A5                    # Motor de juego (tablero, flechas, movimiento, fin, score)
│   ├── B1-B3                    # Renderizado y presentación (SVG, animaciones, input)
│   ├── C1-C4                    # Flujo y estados del juego (máquina de estados, niveles, pantallas)
│   ├── D1-D2                    # Persistencia local (SQLite) y sincronización remota
│   ├── E1-E2                    # Identidad y sesión (registro/login, JWT)
│   ├── F1-F3                    # Backend / API REST (auth, distribución de niveles, progreso)
│   ├── G1-G3                    # Producto (audio, i18n, temporizador)
│   └── H1                       # FORGE — editor visual de niveles (herramienta ADMIN)
│
├── docs/                        # Documentación de arquitectura y diseño
│   ├── STACK.md                 # Stack tecnológico elegido + estructura de carpetas
│   ├── FEATURES.md              # Matriz de features y roadmap de implementación (fuente de verdad de estado)
│   └── BORRADOR-features-pendientes.md  # Puntos clave para features aún sin cerrar (cliente)
│
├── .ai-usage/                    # Registros de sesiones de IA (SDD)
│   ├── manifest.json             # Índice central de sesiones con metadata
│   ├── 2026-05/                  # Mayo: Fundación & Arquitectura
│   ├── 2026-06/                  # Junio: Lógica del juego & Specs
│   └── 2026-07/                  # Julio: Flujo, persistencia y herramientas internas
│
├── CLAUDE.md                    # Instrucciones para Claude Code (este proyecto)
└── .claude/                     # Configuración local de Claude Code
```

> Ver el detalle completo de cada feature (dependencias, estado, link al `.feature`) en [docs/FEATURES.md](./docs/FEATURES.md).

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
   - 8 grupos de features (A–H) con dependencias
   - Orden de implementación (7 sprints)
   - Decisiones pendientes que bloquean features

3. **[docs/STACK.md](./docs/STACK.md)** — Stack tecnológico y arquitectura
   - Tech stack elegido (React + Capacitor + Express.js)
   - Estructura de carpetas para frontend y backend
   - Ejemplos de Clean Architecture en código
   - Setup inicial y primer sprint

### Para ver el historial de decisiones:

- **[.ai-usage/manifest.json](./.ai-usage/manifest.json)** — Índice centralizado de todas las sesiones SDD (22 sesiones)
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

### Fase 1: Especificación
**En project-core:**
- ✅ Decisiones de arquitectura (Clean Architecture + DDD)
- ✅ Especificaciones Gherkin de los grupos A–H (23 features; ver estado individual en [docs/FEATURES.md](./docs/FEATURES.md))
- ✅ Stack técnico documentado: React + Capacitor + Express.js
- ✅ P15 (esquema JSON) y NQ4 (tecnología de renderizado → SVG) resueltos

**En arrow-maze-client + arrow-maze-backend:**
- Sincronizan specs desde project-core
- Implementan según roadmap en `docs/FEATURES.md`

### Fase 2: Completitud (actual)
- Cerrar features en curso: C3, C4, D1, D2, G1–G3, H1
- Resolver decisiones abiertas: P20 (leaderboard), P21 (conflictos de sync), P23 (score vs. tiempo)

---

## 🧪 Especificaciones (Gherkin)

Todas las features están especificadas en **Gherkin (BDD)** en español:

```bash
features/
├── A1-board_graph.feature                    # Inicialización del tablero
├── A2-arrow_placement.feature                # Colocación de flechas
├── A3-arrow_movement.feature                 # Movimiento de flechas
├── A4-game_end_detection.feature             # Victoria/derrota
├── A5-game_session_scoring.feature           # Cálculo de puntuación
├── B1-board-rendering.feature                # Renderizado visual del tablero (SVG)
├── B2-animation_feedback.feature             # Animaciones y feedback visual
├── B3-input-routing.feature                  # Captura y enrutamiento de input
├── C1-maquina_estados_partida.feature        # Máquina de estados de la partida
├── C2-carga-deserializacion-niveles.feature  # Carga de niveles desde archivo
├── C3-seleccion-niveles-progreso.feature     # Selección de niveles con progreso
├── C4-pantallas-soporte.feature              # Pantallas de soporte (pausa, ajustes, etc.)
├── D1-persistencia-local.feature             # Persistencia local en SQLite
├── D2-sincronizacion-local-remota.feature    # Sincronización local ↔ servidor
├── E1-register_and_login.feature             # Registro e inicio de sesión
├── E2-active_session_management.feature      # Gestión de sesión activa (JWT)
├── F1-api_users_auth.feature                 # API de autenticación
├── F2-level-api-distribution.feature         # API de distribución de niveles
├── F3-recepcion-consulta-progreso.feature    # API de progreso del jugador
├── G1-audio-sfx-musica.feature                # Audio, SFX y música
├── G2-internacionalizacion.feature            # Internacionalización (ES/EN)
├── G3-temporizador-nivel.feature              # Temporizador visual por nivel
└── H1-forge-editor-niveles.feature            # FORGE — editor visual de niveles
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

## 🛠️ Próximos pasos (en project-core)

### Inmediatos

1. 🔄 **Completar implementación de D1/D2** — Persistencia local y sincronización (foco actual del cliente)
2. 🔄 **Completar C3/C4** — Selección de niveles y pantallas de pausa/ajustes
3. 📋 **Resolver P20/P21/P23** — Leaderboard global, conflictos de sync y score vs. tiempo

### Mediano plazo

4. 🔄 **Implementar G1–G3** — Audio, i18n y temporizador (specs ya listas)
5. 🔄 **Implementar H1** — FORGE, editor visual de niveles (spec lista, plan de 6 fases)

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
- [.ai-usage/manifest.json](./.ai-usage/manifest.json) — Historial SDD

### Especificaciones Gherkin
> Listado completo con estado y dependencias en [docs/FEATURES.md](./docs/FEATURES.md). Los 23 archivos `.feature` viven en [features/](./features/) (grupos A–H).

---

## ⚠️ Notas importantes

1. **Fuente única de especificaciones** — Este repo define QUÉ se implementa. El código está en arrow-maze-client y arrow-maze-backend.
2. **Especificaciones en español** — Todas las features y documentos de decisión están en español. Referir siempre a original si hay duda de traducción.
3. **SDD riguroso** — Las decisiones de diseño se congelan en Gherkin ANTES de cambios de implementación. Cambios de spec → sesión SDD aquí primero.
4. **Cadena de dependencias estricta** — A1 → A2 → A3 → A4 → A5 es hard dependency dentro del motor. Cada grupo posterior (B–H) declara sus propias dependencias en la tabla de [docs/FEATURES.md](./docs/FEATURES.md); no reordenar sin validar impacto.

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
3. **Timeline:** 7 sprints; Sprints 1, 2 y 5 completados, resto en curso (ver [docs/FEATURES.md](./docs/FEATURES.md))
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
| **Sesiones SDD completadas** | 22 | ✅ Registradas en `.ai-usage/manifest.json` |
| **Decisiones documentadas** | 30+ | ✅ Registradas |
| **Features especificadas** | 23 (grupos A-H) | ✅ Ver estado individual en [docs/FEATURES.md](./docs/FEATURES.md) |
| **Escenarios Gherkin** | ~300 | ✅ Cubiertos |
| **Bloqueadores activos** | P20, P21, P23 | ⏳ Requieren resolución |
| **Tiempo ahorrado (IA)** | ~60 horas | 📈 80% efficiency gain |

---

**Última actualización:** 2026-07-08  
**Proyecto:** Arrow Maze — Specification-Driven Development + Clean Architecture  
**Mantenido por:** Jrgil20  
**Contacto:** fariasjr223@gmail.com  
**Estado:** 🟡 Grupos A, B, E, F implementados | 🔄 Completando C, D, G, H | ⏳ Resolviendo P20, P21, P23
