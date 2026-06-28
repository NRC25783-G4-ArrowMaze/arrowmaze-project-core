# BORRADOR — Puntos clave de features pendientes (Cliente / Juego)

> ⚠️ **Documento de trabajo (no vinculante).** Esto **no** son specs `.feature`.
> Son los **puntos clave a considerar** cuando cada feature pase por su sesión SDD
> (elicitación → consolidación → `.feature`). Sirve como insumo para no partir de cero.
> Antes de escribir cada `.feature` hay que **cerrar las decisiones abiertas** marcadas con 🔶.
>
> **Enfoque: repo `arrow-maze-client`.** Features del cliente sin archivo `.feature`:
> **C1, C3, C4, D1, D2, G1, G2, G3**.
> Orden sugerido (por dependencias / sprint): C1 → C2✅ → C4 → D1 → C3 → D2 → G1 → G2 → G3.
>
> El backend (F3, F4) queda como **apéndice de referencia** al final, solo porque D2 y C3
> consumen su contrato.

---

## GRUPO C — Flujo y estados del juego

### C1 — Máquina de estados del ciclo de vida de la partida
**Depende de:** A4 · **Capa:** Application/Domain

Puntos clave:
- Estados explícitos: `MENU` → `LOADING` → `IN_PROGRESS` → (`PAUSED` ⇄ `IN_PROGRESS`) → `WON` / `LOST`.
- La FSM **consume** el `GameStatus` que ya emite A4 (WON/LOST/IN_PROGRESS); no recalcula reglas de fin de partida, solo orquesta transiciones de UI/flujo.
- Transiciones válidas declaradas como tabla; toda transición no listada debe rechazarse (no saltos arbitrarios).
- Acciones de jugador que disparan transiciones: `start`, `pause`, `resume`, `restart`, `quit`/`abandon`.
- `PAUSED` debe **congelar** el reloj de juego (ver G3) sin perder estado de tablero/flechas.
- `restart` reinicia la `GameSession` del mismo nivel desde cero (mismo `LevelData`).
- Idempotencia de estados terminales: invocar transiciones sobre `WON`/`LOST` no cambia el resultado (coherente con `evaluateStatus()` de A4).
- Define el contrato que consumen C4 (qué pantalla mostrar) y G3 (cuándo corre el timer).

---

### C3 — Selección de niveles con progreso y desbloqueo
**Depende de:** C2, D1 · **Capa:** Presentation + lectura de persistencia

Puntos clave:
- El listado se arma con `LevelMetadata` (mismo contrato de F2: `id`, `name`, `difficulty`, `allowedMoves`) — **no** se descarga `LevelData` completo hasta entrar al nivel.
- Indicador de progreso por nivel leído de D1: mejor score, estado (no jugado / completado), y posible representación en estrellas.
- 🔶 **Regla de desbloqueo a definir:** ¿secuencial (completar N desbloquea N+1), por dificultad, o todos abiertos? Define el primer nivel siempre disponible.
- Estado por nivel para la UI: `bloqueado` / `disponible` / `completado`.
- Comportamiento al tocar un nivel bloqueado (ignorar vs mensaje).
- Debe funcionar **offline** (lee de D1 local); el refresco de catálogo remoto (F2) es complementario, no bloqueante.

---

### C4 — Pantallas de soporte (inicio, victoria, derrota, pausa, ajustes)
**Depende de:** C1 · **Capa:** Presentation

Puntos clave:
- Pantallas mínimas: **Inicio**, **Victoria**, **Derrota**, **Pausa**, **Ajustes**.
- Cada pantalla se muestra en función del estado de la FSM de C1 (fuente única de verdad del flujo).
- **Victoria:** muestra el `Score` (visible solo en WON, según A5) + acciones `Reintentar` / `Siguiente nivel` / `Volver al menú`.
- **Derrota:** sin score (A5 → null en LOST) + acciones `Reintentar` / `Volver al menú`.
- **Pausa:** `Reanudar` / `Reiniciar` / `Salir`; coherente con que C1 congela el reloj.
- **Ajustes:** punto de entrada para idioma (→ **G2**) y audio/volumen (→ **G1**). Es el contenedor que enlaza esas preferencias.
- Navegación reversible y sin estados huérfanos (toda pantalla debe poder volver al menú).

---

## GRUPO D — Persistencia local (cliente)

### D1 — Persistencia local de progreso y puntuaciones (SQLite)
**Depende de:** A5 · **Capa:** Infrastructure (repositorio) · **Tecnología:** SQLite (vía Capacitor en móvil)

Puntos clave:
- Qué se persiste por nivel: `bestScore`, estado `completado`, fecha/tick de obtención, y flag de desbloqueo (insumo de C3).
- **Solo se guarda la mejor marca:** un score nuevo solo sobrescribe si es mayor que el almacenado (no degradar).
- Modelo de repositorio alineado a Clean Architecture: puerto `ProgressRepository` en Application, adaptador SQLite en Infrastructure.
- 🔶 **Alcance de usuario local:** ¿perfil único de dispositivo (invitado) o progreso por `userId` cuando hay login (E1)? Define cómo se asocia el progreso anónimo al iniciar sesión.
- Versionado/migración del esquema local (campo de versión para futuras migraciones).
- Idempotencia de escritura y lectura determinista (mismo nivel → mismo registro).
- Es la **fuente local** que D2 sincroniza con el backend.

---

### D2 — Sincronización del progreso local con servidor remoto
**Depende de:** D1, E2 · **Capa:** Application + Infrastructure (cliente HTTP)

Puntos clave:
- Modelo **offline-first**: el juego siempre funciona con D1; la sync es oportunista.
- Requiere sesión autenticada: usa el JWT de E2 (Bearer); sin token válido no sincroniza.
- 🔶 **P21 — Resolución de conflictos (decisión bloqueante):** estrategia recomendada por dominio = **conservar el mayor score por nivel** (merge por máximo), no last-write-wins ciego. Confirmar antes de escribir el `.feature`.
- Disparadores de sync: al iniciar sesión, al terminar un nivel, y/o reintento periódico/al reconectar.
- Operaciones **idempotentes** (reenviar el mismo progreso no duplica ni corrompe).
- Sincronización parcial y reanudable ante fallo de red (cola de pendientes + reintentos).
- Define dirección: push (local→remoto), pull (remoto→local) y reconciliación bidireccional.
- Consume el contrato de **F3** (ver apéndice backend).

---

## GRUPO G — Características de producto (cliente)

### G1 — Audio (efectos y música de fondo)
**Depende de:** B2 · **Capa:** Presentation/Infrastructure

Puntos clave:
- 🔶 **P22 — Origen de los assets de audio (decisión bloqueante):** empaquetados en la app vs descargados. Define antes del `.feature`.
- Dos categorías independientes: **SFX** (eventos del motor: mover, bloquear, victoria/derrota) y **música de fondo**.
- Controles en Ajustes (C4): mute global + volumen separado para SFX y música.
- La preferencia de audio se **persiste a nivel de usuario** (junto con D1 / preferencias).
- Restricciones de autoplay en móvil/navegador: el audio arranca tras interacción del usuario.
- Los SFX se enganchan a los eventos visuales de B2 (sincronía con animaciones, sin acoplarse al dominio).

---

### G2 — Internacionalización (ES / EN)  ⭐ *requisitos ya indicados por el usuario*
**Depende de:** C4 · **Capa:** Presentation

Puntos clave (confirmados):
- **Botón de cambio de idioma Inglés / Español** accesible (ubicado en Ajustes, C4).
- **Idioma por defecto = idioma del dispositivo:** al primer arranque se lee el locale del sistema; si es ES → español, si es EN (o cualquier otro) → inglés (fallback).
- La preferencia de idioma es **a nivel de usuario** (se persiste por usuario/perfil y se respeta en próximos arranques, por encima del default del dispositivo).
- Cambio de idioma **en caliente** (sin reiniciar la app); toda la UI se re-renderiza.
- Catálogo de cadenas externalizado (claves → traducciones ES/EN), con idioma de **fallback** definido para claves faltantes.

Punto abierto:
- 🔶 **P24 — Alcance de i18n (decisión bloqueante):** ¿solo la UI, o también el contenido de los niveles (`name`, textos del `LevelData`)? Por defecto: **solo UI**; confirmar.

---

### G3 — Temporizador visual por nivel
**Depende de:** C1 · **Capa:** Presentation (+ posible Domain según P23)

Puntos clave:
- 🔶 **P23 — ¿El timer afecta el score o es solo visual? (decisión bloqueante):** impacta A5 y G3.
  - Si **solo visual** → vive en Presentation y no toca el dominio.
  - Si **afecta score** → debe medirse en **ticks deterministas** (coherente con A5/A3), no en segundos de reloj.
- El timer se **pausa** cuando C1 entra en `PAUSED` y se **detiene** en `WON`/`LOST`.
- Relación con `allowedMoves`: aclarar si es solo informativo o si existe además un límite de tiempo por nivel.
- Formato de presentación (mm:ss o ticks) y reinicio al hacer `restart` (C1).

---

## Decisiones bloqueantes a cerrar (cliente)

| Decisión | Bloquea | Recomendación borrador |
|---|---|---|
| **NQ4** — Tecnología de render (CSS/Canvas/WebGL) | B1/B2 → afecta G1/G3 visualmente | Pendiente; cerrar antes de B1/B2 |
| **P21** — Conflictos de sincronización | **D2** | **Conservar mayor score** (merge por máximo) |
| **P22** — Origen de assets de audio | **G1** | Empaquetados en la app inicialmente |
| **P23** — Timer ¿afecta score? | **G3**, A5 | Empezar **solo visual** (no toca dominio) |
| **P24** — Alcance de i18n | **G2** | **Solo UI**; niveles fuera de alcance v1 |
| Regla de desbloqueo de niveles | **C3** | Definir secuencial vs abierto |
| Alcance de usuario local (invitado vs login) | **D1** | Definir asociación de progreso anónimo |

---

## Apéndice — Dependencias backend (referencia, no es el foco)

Solo se listan porque **D2** y **C3** consumen su contrato. Detalle completo cuando se aborde el repo `arrow-maze-backend`.

- **F3 — API de progreso del jugador** (`/api/v1/progress`, JWT, aislamiento por `userId`, persiste solo la mejor marca). Es el espejo remoto de D1 y lo que sincroniza D2.
- **F4 — Leaderboard por nivel** (`/api/v1/leaderboard/:levelId`, ranking por score, top-N + posición propia). 🔶 P20: por nivel vs global.
