## Features — Versión definitiva

> **Estado de implementación** sincronizado con el repo `arrow-maze-client` (2026-07-04).
> Specs del grupo G (audio, i18n, temporizador) listas desde la sesión SDD 2026-07-04.
> Spec de **C3** (selección de niveles con mapa de progreso) lista desde la sesión SDD 2026-07-05.
> Para los puntos clave de las features aún pendientes del cliente, ver
> [`BORRADOR-features-pendientes.md`](./BORRADOR-features-pendientes.md).
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
| [A5](../features/A5-game_session_scoring.feature) | Cálculo y composición de la puntuación por sesión de juego | A4 | ✅ Implementado — 🔶 enmienda futura pendiente de P23 (penalización por tiempo, ver G3) |

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
| C1 | Máquina de estados del ciclo de vida de una partida | A4 | ✅ Implementado (falta flujo UI PAUSED/MENU, ver C4) |
| [C2](../features/C2-carga-deserializacion-niveles.feature) | Carga y deserialización de definiciones de niveles desde archivos locales | A1, A2 | ✅ Implementado |
| [C3](../features/C3-seleccion-niveles-progreso.feature) | Pantalla de selección de niveles con indicador de progreso y control de desbloqueo | C2, D1 | 📝 Spec lista (Presentation; desbloqueo por grafo, lee D1) |
| C4 | Pantallas de soporte del juego (inicio, victoria, derrota, pausa, ajustes) | C1 | ⚠️ Parcial (`GameOverlay` de fin de partida) |

---

### GRUPO D — Persistencia local

| # | Feature | Depende de | Estado |
|---|---|---|---|
| D1 | Persistencia local del progreso y puntuaciones del jugador en SQLite | A5 | ❌ Pendiente |
| D2 | Sincronización del progreso local con el servidor remoto | D1, E2 | ❌ Pendiente |

---

### GRUPO E — Identidad y sesión

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [E1](../features/E1-register_and_login.feature) | Registro e inicio de sesión de usuario | — | 📝 Spec lista (backend) |
| [E2](../features/E2-active_session_management.feature) | Gestión de sesión activa y renovación de credenciales JWT | E1 | 📝 Spec lista (backend) |

---

### GRUPO F — Backend / API REST

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [F1](../features/F1-api_users_auth.feature) | API de autenticación de usuarios (registro, login, logout con JWT) | — | 📝 Spec lista (backend) |
| [F2](../features/F2-level-api-distribution.feature) | API de distribución y actualización remota de definiciones de niveles | Contrato C2 | 📝 Spec lista (backend) |
| [F3](../features/F3-recepcion-consulta-progreso.feature) | API de recepción y consulta del progreso del jugador | F1 | 📝 Spec lista (backend) |
| F4 | Sistema de clasificación por nivel (leaderboard) | F1, F3 | ❌ Pendiente (sin spec) |

---

### GRUPO G — Características de producto

| # | Feature | Depende de | Estado |
|---|---|---|---|
| [G1](../features/G1-audio-sfx-musica.feature) | Sistema de reproducción de audio, efectos sonoros y música de fondo | B2 | 📝 Spec lista |
| [G2](../features/G2-internacionalizacion.feature) | Soporte de internacionalización y cambio de idioma (ES/EN) | C4 | 📝 Spec lista |
| [G3](../features/G3-temporizador-nivel.feature) | Temporizador visual por nivel (mm:ss, pausa, IClock) | C1 | 📝 Spec lista (solo Presentation; integración con score pendiente de P23) |

---

## Orden de implementación

```
Sprint 1 ── A1 → A2 → A3                      ✅ Completado
            Motor núcleo puro sin UI

Sprint 2 ── A4 → A5 → B1 → B3                  ✅ Completado
            Condiciones de fin de partida + render básico + input

Sprint 3 ── C2 → B2 → C1 → C4                  ⚠️ En curso (C2/B2/C1 ✅, C4 parcial)
            Niveles reales desde JSON + animaciones + pantallas

Sprint 4 ── D1 → C3                            ⚠️ D1 ❌ · C3 📝 spec lista (foco actual)
            Persistencia local + selección de niveles

Sprint 5 ── E1 → E2 → F1 → F2                  📝 Specs listas (backend pendiente)
            Autenticación + backend + distribución de niveles

Sprint 6 ── F3 → F4 → D2                       📝 Spec F3 lista; F4/D2 pendientes
            Progreso remoto + leaderboard + sincronización

Sprint 7 ── G1 → G2 → G3                       📝 Specs listas (implementación pendiente)
            Audio + i18n + temporizador visual (integración tiempo→score espera P23)
```

> **Foco de trabajo del cliente (orden sugerido):** D1 → C4 (completar) → C3 → G2 → G1 → G3 → D2.

---

## Decisiones que aún bloquean features específicos

| Decisión | Bloquea | Estado |
|---|---|---|
| **P15** — Formato JSON del nivel (esquema de nodos y piezas) | C2, F2 | ✅ Resuelto (materializado en C2 / `LevelData`) |
| **NQ4** — Tecnología de renderizado (CSS / Canvas / WebGL) | B1, B2 | ✅ Resuelto → **SVG** |
| **P23** — ¿El temporizador afecta el score o es solo visual? | A5 (enmienda) | 🟡 **Parcial** — decidido que **SÍ debe afectar el score** (2026-07-04); queda por decidir **cómo** (candidatos: término `segundos × TIME_DECAY` [favorito], conversión a ticks, o bonus por rapidez). G3 v1 es solo visual; la enmienda de A5 se hará en su propia sesión SDD |
| **P20** — ¿Leaderboard solo por nivel o también global? | F4 | 🟡 Abierto — borrador: por nivel primero |
| **P21** — Resolución de conflictos en sincronización | D2 | 🟡 Abierto — borrador: conservar mayor score |
| **P22** — Origen de los assets de audio | G1 | ✅ Resuelto → **empaquetados en la app**, royalty-free (NEFFEX/NCS), pool por dificultad, atribución en Ajustes |
| **P24** — Alcance de i18n (solo UI o también niveles) | G2 | ✅ Resuelto → **solo UI**; fallback de claves a inglés |

> La **regla de desbloqueo de niveles (C3)** quedó resuelta → **grafo de prerequisitos (DAG)**, un nodo
> se desbloquea cuando todos sus prerequisitos están completados (AND, confirmado) y la raíz siempre está
> disponible (SDD 2026-07-05). Sub-decisiones cerradas en la elicitación 2026-07-05: `starThresholds`
> autorados en el `LevelMap` (aditivo, sin tocar F2/C2) y curva de dos umbrales absolutos [twoStar, threeStar].
>
> Decisiones de cliente adicionales abiertas (detalle en el borrador):
> alcance de usuario local invitado vs login (D1), estado de flujo `PAUSED` en presentación (C4).
