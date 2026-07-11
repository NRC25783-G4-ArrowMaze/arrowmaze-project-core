## Features — Versión definitiva

> **Estado final congelado (2026-07-11).** El **backend está cerrado y congelado en `v1.0.0`**
> (grupos E–F, 2026-07-09) y el **cliente está cerrado y congelado en `v1.0.0`** (grupos A–D, G, H —
> release #62 de `arrowmaze-game`, 2026-07-11). Las versiones futuras de ambos repos evolucionan de
> forma independiente y ya no se reflejan aquí (ver política de versionado en el README). Esta matriz
> queda como **registro histórico** del alcance de la v1.0.0.
>
> Leyenda: ✅ Implementado · ⚠️ Parcial · ❌ Pendiente · 📝 Spec lista (sin implementar)

---

### GRUPO A — Motor de juego

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [A1](../features/A1-board_graph.feature) | Inicialización y representación del tablero como grafo de nodos en memoria | — | ✅ Implementado |
| [A2](../features/A2-arrow_placement.feature) | Definición y colocación de entidades como listas enlazadas sobre el grafo | A1 | ✅ Implementado |
| [A3](../features/A3-arrow_movement.feature) | Resolución y desplazamiento de entidades direccionales | A1, A2 | ✅ Implementado |
| [A4](../features/A4-game_end_detection.feature) | Detección de victoria por vaciado del tablero y de derrota por agotamiento de movimientos disponibles | A3 | ✅ Implementado |
| [A5](../features/A5-game_session_scoring.feature) | Cálculo y composición de la puntuación por sesión de juego | A4 | ✅ Implementado — 🔒 en `v1.0.0` el score se basa en ticks; la enmienda de P23 (penalización por tiempo real) no se materializó y quedó congelada (ver G3) |

> **Extensiones del motor (posteriores al roadmap):** slide de flecha (1 gesto = 1 movimiento),
> colisión de cola (fix), colisión configurable (`return`/`stay`) y preview jugable — ✅ implementadas en el cliente.

---

### GRUPO B — Renderizado y presentación

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [B1](../features/B1-board-rendering.feature) | Renderizado visual del tablero y sus entidades sobre el grafo de nodos | A1, A2 | ✅ Implementado (SVG) |
| [B2](../features/B2-animation_feedback.feature) | Sistema de animaciones y retroalimentación visual de acciones del motor | A3, B1 | ✅ Implementado |
| [B3](../features/B3-input-routing.feature) | Captura y enrutamiento de la entrada del jugador hacia el motor de juego | B1 | ✅ Implementado |

---

### GRUPO C — Flujo y estados del juego

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [C1](../features/C1-maquina_estados_partida.feature) | Máquina de estados del flujo de una partida (autómata de pila: ACTIVE/PAUSED/SETTINGS) | A4 | ✅ Implementado (`GameFlowController`, cliente v0.1.0) |
| [C2](../features/C2-carga-deserializacion-niveles.feature) | Carga y deserialización de definiciones de niveles desde archivos locales | A1, A2 | ✅ Implementado |
| [C3](../features/C3-seleccion-niveles-progreso.feature) | Pantalla de selección de niveles con indicador de progreso y control de desbloqueo | C2, D1 | ✅ Implementado (selector con progreso, desbloqueo por grafo y trofeos de leaderboard) |
| [C4](../features/C4-pantallas-soporte.feature) | Pantallas de soporte del juego (inicio, victoria, derrota, pausa, ajustes) | C1 | ✅ Implementado (overlays de fin de partida, pausa y ajustes con idioma/audio/tema) |

---

### GRUPO D — Persistencia local

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [D1](../features/D1-persistencia-local.feature) | Persistencia local del progreso y puntuaciones del jugador en SQLite | A5 | ✅ Implementado (SQLite vía `jeep-sqlite`/`sql.js`; bootstrap tolerante a fallos de persistencia) |
| [D2](../features/D2-sincronizacion-local-remota.feature) | Sincronización del progreso local con el servidor remoto | D1, E2 | ✅ Implementado (endpoint `/api/v1/progress`; gate de sesión + scheduler single-flight, cliente #52) |

---

### GRUPO E — Identidad y sesión

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [E1](../features/E1-register_and_login.feature) | Registro e inicio de sesión de usuario | — | ✅ Implementado (backend) |
| [E2](../features/E2-active_session_management.feature) | Gestión de sesión activa y renovación de credenciales JWT | E1 | ✅ Implementado (backend) |

---

### GRUPO F — Backend / API REST

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [F1](../features/F1-api_users_auth.feature) | API de autenticación de usuarios (registro, login, logout con JWT) | — | ✅ Implementado (backend) |
| [F2](../features/F2-level-api-distribution.feature) | API de distribución y actualización remota de definiciones de niveles | Contrato C2 | ✅ Implementado (backend + seed de niveles iniciales; cliente con carga remota y fallback offline) |
| [F3](../features/F3-recepcion-consulta-progreso.feature) | API de recepción y consulta del progreso del jugador | F1 | ✅ Implementado (backend) |
| F4 | Sistema de clasificación por nivel (leaderboard) | F1, F3 | ✅ Implementado (backend; sin spec formal) |

> **Arquitectura del backend (backend v1.0.0, 2026-07-09):** el backend documenta patrones GoF
> (Factory Method, Singleton, Adapter, Strategy), 2 aspectos AOP (`ErrorHandlerAspect`,
> `RequestLoggingAspect`) y expone documentación OpenAPI/Swagger en `/api/docs`
> (`arrowmaze-backend/docs/design-patterns.md`). Este trabajo fue **mergeado (PR #17)** y
> **liberado como `v1.0.0`** (release #18), con CI de build+tests en cada PR. Ver `docs/STACK.md`
> sección 3/5 para el detalle de rutas y DI. El backend queda **congelado en v1.0.0** en este
> repositorio (ver política de versionado en el README).

---

### GRUPO G — Características de producto

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [G1](../features/G1-audio-sfx-musica.feature) | Sistema de reproducción de audio, efectos sonoros y música de fondo | B2 | ✅ Implementado (SFX por acción + música por dificultad, preferencia de silencio — cliente #37) |
| [G2](../features/G2-internacionalizacion.feature) | Soporte de internacionalización y cambio de idioma (ES/EN) | C4 | ✅ Implementado (catálogos ES/EN con paridad de claves, cambio en caliente — cliente #35) |
| [G3](../features/G3-temporizador-nivel.feature) | Temporizador visual por nivel (mm:ss, pausa, IClock) | C1 | ✅ Implementado (solo visual, se pausa con el flujo — cliente #36); integración con score congelada (P23) |

> **Extensión de producto (fuera del roadmap original):** tema claro/oscuro con cambio en caliente
> ("G4", cliente #53), tutorial guiado con el corazón como último nivel (#54), leaderboard por nivel
> en el cliente (#46) y UI de login/registro/logout con badge de usuario (#38, #43) — ✅ implementadas
> en la `v1.0.0` del cliente.

---

### GRUPO H — Herramientas internas

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [H1](../features/H1-forge-editor-niveles.feature) | FORGE — Editor visual interactivo de niveles (herramienta ADMIN) | C2, F2 | ✅ Implementado (editor con playtest jugable y edición admin de mapas creados — cliente #60) |

> **Cierre del cliente (cliente v1.0.0, 2026-07-11):** todo el alcance del cliente — motor (A),
> presentación (B), flujo (C), persistencia y sincronización (D), producto (G) y FORGE (H1) — quedó
> implementado y liberado como **`v1.0.0`** (release #62 de `arrowmaze-game`). El cliente queda
> **congelado en v1.0.0** en este repositorio (ver política de versionado en el README).

---

## Orden de implementación

```
Sprint 1 ── A1 → A2 → A3                      ✅ Completado
            Motor núcleo puro sin UI

Sprint 2 ── A4 → A5 → B1 → B3                  ✅ Completado
            Condiciones de fin de partida + render básico + input

Sprint 3 ── C2 → B2 → C1 → C4                  ✅ Completado
            Niveles reales desde JSON + animaciones + pantallas

Sprint 4 ── D1 → C3                            ✅ Completado
            Persistencia local + selección de niveles

Sprint 5 ── E1 → E2 → F1 → F2                  ✅ Completado (backend; F2 con seed + cliente offline-first)
            Autenticación + backend + distribución de niveles

Sprint 6 ── F3 → F4 → D2                       ✅ Completado
            Progreso remoto + leaderboard + sincronización

Sprint 7 ── G1 → G2 → G3                       ✅ Completado (G3 solo visual; tiempo→score congelado, ver P23)
            Audio + i18n + temporizador visual
```

> **Los 7 sprints están completados.** El backend cerró en `v1.0.0` el 2026-07-09 y el cliente en
> `v1.0.0` el 2026-07-11; esta matriz queda congelada como registro del alcance final.

---

## Decisiones que aún bloquean features específicos

> **Al cierre de la v1.0.0 no queda ningún bloqueador activo.** La tabla registra el estado final
> de cada decisión al momento del congelamiento.

| Decisión | Bloqueaba | Estado al cierre |
|---|---|---|
| **P15** — Formato JSON del nivel (esquema de nodos y piezas) | C2, F2 | ✅ Resuelto (materializado en C2 / `LevelData`) |
| **NQ4** — Tecnología de renderizado (CSS / Canvas / WebGL) | B1, B2 | ✅ Resuelto → **SVG** |
| **P23** — ¿El temporizador afecta el score o es solo visual? | A5 (enmienda) | 🔒 **Congelado** — se decidió que SÍ debía afectar el score (2026-07-04), pero la enmienda de A5 **no se materializó en v1.0.0**: G3 quedó solo visual y el score sigue basado en ticks. Si se retoma, evoluciona en el repo del cliente |
| **P20** — ¿Leaderboard solo por nivel o también global? | F4 | ✅ Resuelto en implementación → **por nivel** (backend F4 + UI de clasificación en el cliente #46) |
| **P21** — Resolución de conflictos en sincronización | D2 | ✅ Cerrado en implementación → D2 con gate de sesión y scheduler single-flight (cliente #52); evolución futura en el repo del cliente |
| **P22** — Origen de los assets de audio | G1 | ✅ Resuelto → **empaquetados en la app**, royalty-free (NEFFEX/NCS), pool por dificultad, atribución en Ajustes |
| **P24** — Alcance de i18n (solo UI o también niveles) | G2 | ✅ Resuelto → **solo UI**; fallback de claves a inglés |

> La **regla de desbloqueo de niveles (C3)** quedó resuelta → **grafo de prerequisitos (DAG)**, un nodo
> se desbloquea cuando todos sus prerequisitos están completados (AND, confirmado) y la raíz siempre está
> disponible (SDD 2026-07-05). Sub-decisiones cerradas en la elicitación 2026-07-05: `starThresholds`
> autorados en el `LevelMap` (aditivo, sin tocar F2/C2) y curva de dos umbrales absolutos [twoStar, threeStar].
>
> Las decisiones de cliente que quedaban abiertas en el borrador (usuario local invitado vs login en D1,
> estado de flujo `PAUSED` en presentación para C4) se **cerraron en la implementación** de la v1.0.0
> del cliente: modo invitado con sincronización condicionada a sesión activa, y pausa/ajustes integrados
> al autómata de C1.
