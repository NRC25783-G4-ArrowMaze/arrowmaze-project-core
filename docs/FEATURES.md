## Features — Versión definitiva

---

### GRUPO A — Motor de juego

| # | Feature | Depende de |
|---|---|---|
| [A1](../features/A1-board_graph.feature) | Inicialización y representación del tablero como grafo de nodos en memoria | — |
| [A2](../features/A2-arrow_placement.feature) | Definición y colocación de entidades como listas enlazadas sobre el grafo | A1 |
| [A3](../features/A3-arrow_movement.feature) | Resolución y desplazamiento de entidades direccionales | A1, A2 |
| [A4](../features/A4-game_end_detection.feature) | Detección de victoria por vaciado del tablero y de derrota por agotamiento de movimientos disponibles | A3 |
| [A5](../features/A5-game_session_scoring.feature) | Cálculo y composición de la puntuación por sesión de juego | A4 |

---

### GRUPO B — Renderizado y presentación

| # | Feature | Depende de |
|---|---|---|
| [B1](../features/B1-board-rendering.feature) | Renderizado visual del tablero y sus entidades sobre el grafo de nodos | A1, A2 |
| [B2](../features/B2-animation_feedback.feature) | Sistema de animaciones y retroalimentación visual de acciones del motor | A3, B1 |
| [B3](../features/B3-input-routing.feature) | Captura y enrutamiento de la entrada del jugador hacia el motor de juego | B1 |

---

### GRUPO C — Flujo y estados del juego

| # | Feature | Depende de |
|---|---|---|
| C1 | Máquina de estados del ciclo de vida de una partida | A4 |
| C2 | Carga y deserialización de definiciones de niveles desde archivos locales | A1, A2 |
| C3 | Pantalla de selección de niveles con indicador de progreso y control de desbloqueo | C2, D1 |
| C4 | Pantallas de soporte del juego (inicio, victoria, derrota, pausa, ajustes) | C1 |

---

### GRUPO D — Persistencia local

| # | Feature | Depende de |
|---|---|---|
| D1 | Persistencia local del progreso y puntuaciones del jugador en SQLite | A5 |
| D2 | Sincronización del progreso local con el servidor remoto | D1, E2 |

---

### GRUPO E — Identidad y sesión

| # | Feature | Depende de |
|---|---|---|
| [E1](../features/E1-register_and_login.feature) | Registro e inicio de sesión de usuario | — |
| [E2](../features/E2-active_session_management.feature) | Gestión de sesión activa y renovación de credenciales JWT | E1 |

---

### GRUPO F — Backend / API REST

| # | Feature | Depende de |
|---|---|---|
| [F1](../features/F1-api_users_auth.feature) | API de autenticación de usuarios (registro, login, logout con JWT) | — |
| [F2](../features/F2-level-api-distribution.feature) | API de distribución y actualización remota de definiciones de niveles | Contrato C2 |
| F3 | API de recepción y consulta del progreso del jugador | F1 |
| F4 | Sistema de clasificación por nivel (leaderboard) | F1, F3 |

---

### GRUPO G — Características de producto

| # | Feature | Depende de |
|---|---|---|
| G1 | Sistema de reproducción de audio, efectos sonoros y música de fondo | B2 |
| G2 | Soporte de internacionalización y cambio de idioma (ES/EN) | C4 |
| G3 | Sistema de temporizador visual por nivel | C1 |

---

## Orden de implementación

```
Sprint 1 ── A1 → A2 → A3
            Motor núcleo puro sin UI
            Bloqueante para todo lo demás

Sprint 2 ── A4 → A5 → B1 → B3
            Condiciones de fin de partida + render básico + input

Sprint 3 ── C2 → B2 → C1 → C4
            Niveles reales desde JSON + animaciones + pantallas

Sprint 4 ── D1 → C3
            Persistencia local + selección de niveles

Sprint 5 ── E1 → E2 → F1 → F2
            Autenticación + backend + distribución de niveles

Sprint 6 ── F3 → F4 → D2
            Progreso remoto + leaderboard + sincronización

Sprint 7 ── G1 → G2 → G3
            Audio + i18n + temporizador
```

---

## Decisiones que aún bloquean features específicos

| Decisión pendiente | Bloquea | Urgencia |
|---|---|---|
| **P15** — Formato JSON del nivel (esquema de nodos y piezas) | C2, F2 | 🔴 Sprint 1–2 |
| **NQ4** — Tecnología de renderizado (CSS / Canvas / WebGL) | B1, B2 | 🔴 Sprint 2 |
| **P23** — ¿El temporizador afecta el score o es solo visual? | A5, G3 | 🟡 Sprint 3 |
| **P20** — ¿Leaderboard solo por nivel o también global? | F4 | 🟡 Sprint 6 |
| **P21** — Resolución de conflictos en sincronización | D2 | 🟡 Sprint 6 |
| **P22** — Origen de los assets de audio | G1 | 🟢 Sprint 7 |
| **P24** — Alcance de i18n (solo UI o también niveles) | G2 | 🟢 Sprint 7 |
