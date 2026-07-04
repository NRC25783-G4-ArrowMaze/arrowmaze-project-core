# BORRADOR — Puntos clave de features pendientes (Cliente / Juego)

> ⚠️ **Documento de trabajo (no vinculante).** Esto **no** son specs `.feature`.
> Son los **puntos clave a considerar** cuando cada feature pase por su sesión SDD
> (elicitación → consolidación → `.feature`). Sirve como insumo para no partir de cero.
> Antes de escribir cada `.feature` hay que **cerrar las decisiones abiertas** marcadas con 🔶.
>
> **Enfoque: repo `arrow-maze-client`.** Sincronizado con el README del cliente.
> Pendientes reales de construir: **C3, C4 (completar), D1, D2, G1, G2, G3**.

---

## Estado actual del cliente (sync con README de `arrow-maze-client`)

| Grupo | Features | Estado |
|---|---|---|
| **A — Motor** | A1, A2, A3, A4, A5 | ✅ Completo |
| **B — Render** | B1, B2, B3 | ✅ Completo (SVG) |
| **C — Flujo** | C1 ✅ · C2 ✅ · **C3 ❌** · **C4 ⚠️ parcial** | C1/C2 hechos |
| **D — Persistencia** | **D1 ❌** · **D2 ❌** | Pendiente |
| **G — Producto** | **G1 ❌** · **G2 ❌** · **G3 ❌** | Pendiente |
| **Extensiones motor** | Slide · colisión de cola · colisión configurable · preview jugable | ✅ Completo |

**Ya no pendientes (cerrar del borrador):**
- **C1** — máquina de estados de `GameSession` (IN_PROGRESS / WON / LOST) ✅ implementada. *Nota:* lo que sí puede faltar es el flujo de **UI** de alto nivel (MENU / LOADING / PAUSED); esa parte se aborda junto con C4 (pausa) y G3 (reloj), no como C1.
- **C2** — carga/deserialización de `LevelData` ✅.
- **NQ4** (tecnología de render) **resuelto → SVG**. Ya no bloquea B1/B2/G1/G3.

**Orden sugerido para lo pendiente:** D1 → C4 (completar) → C3 → G2 → G1 → G3 → D2.

---

## GRUPO C — Flujo y estados del juego

### C3 — Selección de niveles con progreso y desbloqueo  ❌ *pendiente*
**Depende de:** C2 ✅, D1 ❌ · **Capa:** Presentation + lectura de persistencia

Puntos clave:
- El listado se arma con `LevelMetadata` (mismo contrato de F2: `id`, `name`, `difficulty`, `allowedMoves`) — **no** se descarga `LevelData` completo hasta entrar al nivel.
- Indicador de progreso por nivel leído de D1: mejor score, estado (no jugado / completado), y posible representación en estrellas.
- 🔶 **Regla de desbloqueo a definir:** ¿secuencial (completar N desbloquea N+1), por dificultad, o todos abiertos? Define el primer nivel siempre disponible.
- Estado por nivel para la UI: `bloqueado` / `disponible` / `completado`.
- Comportamiento al tocar un nivel bloqueado (ignorar vs mensaje).
- Debe funcionar **offline** (lee de D1 local); el refresco de catálogo remoto (F2) es complementario, no bloqueante.
- **Bloqueada por D1:** sin persistencia no hay progreso real que mostrar (hoy solo hay niveles de ejemplo / preview).

---

### C4 — Pantallas de soporte  ⚠️ *parcial — falta completar*
**Depende de:** C1 ✅ · **Capa:** Presentation

**Ya hecho:** overlay de fin de partida (`GameOverlay`) → cubre **Victoria / Derrota**.

**Falta construir:** pantalla de **Inicio**, **Pausa** y **Ajustes**.

Puntos clave:
- Cada pantalla se muestra según el estado de flujo de UI; hoy `GameSession` cubre IN_PROGRESS/WON/LOST a nivel dominio, pero **falta el estado de flujo `PAUSED`** (y opcionalmente MENU/LOADING) para soportar la pantalla de Pausa.
- **Victoria** (hecho vía `GameOverlay`): muestra el `Score` (visible solo en WON, A5) + acciones `Reintentar` / `Siguiente nivel` / `Volver al menú` — revisar que estén las 3 acciones.
- **Derrota** (hecho vía `GameOverlay`): sin score (A5 → null) + `Reintentar` / `Volver al menú`.
- **Pausa** (falta): `Reanudar` / `Reiniciar` / `Salir`; debe **congelar el reloj** (ver G3) sin perder estado de tablero/flechas.
- **Ajustes** (falta): contenedor que enlaza idioma (→ **G2**) y audio/volumen (→ **G1**).
- **Inicio** (falta): entrada al juego / acceso a selección de niveles (→ C3).
- Navegación reversible y sin estados huérfanos (toda pantalla puede volver al menú).

---

## GRUPO D — Persistencia local (cliente)

### D1 — Persistencia local de progreso y puntuaciones (SQLite)  ❌ *pendiente*
**Depende de:** A5 ✅ · **Capa:** Infrastructure (repositorio) · **Tecnología:** SQLite (vía Capacitor en móvil)

Puntos clave:
- Qué se persiste por nivel: `bestScore`, estado `completado`, fecha/tick de obtención, y flag de desbloqueo (insumo de C3).
- **Solo se guarda la mejor marca:** un score nuevo solo sobrescribe si es mayor que el almacenado (no degradar).
- Modelo de repositorio alineado a Clean Architecture: puerto `ProgressRepository` en Application, adaptador SQLite en Infrastructure (hoy ya existe el patrón con `ILevelRepository` / `InMemoryBoardRepository` — seguir ese molde).
- 🔶 **Alcance de usuario local:** ¿perfil único de dispositivo (invitado) o progreso por `userId` cuando hay login (E1)? Define cómo se asocia el progreso anónimo al iniciar sesión.
- Versionado/migración del esquema local (campo de versión para futuras migraciones).
- Idempotencia de escritura y lectura determinista (mismo nivel → mismo registro).
- Es la **fuente local** que D2 sincroniza y la que **desbloquea C3**.

---

### D2 — Sincronización del progreso local con servidor remoto  ❌ *pendiente*
**Depende de:** D1 ❌, E2 · **Capa:** Application + Infrastructure (cliente HTTP)

Puntos clave:
- Modelo **offline-first**: el juego siempre funciona con D1; la sync es oportunista.
- Requiere sesión autenticada: usa el JWT de E2 (Bearer); sin token válido no sincroniza.
- 🔶 **P21 — Resolución de conflictos (decisión bloqueante):** estrategia recomendada por dominio = **conservar el mayor score por nivel** (merge por máximo), no last-write-wins ciego. Confirmar antes de escribir el `.feature`.
- Disparadores de sync: al iniciar sesión, al terminar un nivel, y/o reintento periódico/al reconectar.
- Operaciones **idempotentes** (reenviar el mismo progreso no duplica ni corrompe).
- Sincronización parcial y reanudable ante fallo de red (cola de pendientes + reintentos).
- Define dirección: push (local→remoto), pull (remoto→local) y reconciliación bidireccional.
- Consume el contrato de **F3** (ver apéndice backend). **Último de la lista:** depende de D1 + backend.

---

## GRUPO G — Características de producto (cliente)

### G1 — Audio (efectos y música de fondo)  ❌ *pendiente*
**Depende de:** B2 ✅ · **Capa:** Presentation/Infrastructure

Puntos clave:
- 🔶 **P22 — Origen de los assets de audio (decisión bloqueante):** empaquetados en la app vs descargados. Define antes del `.feature`.
- Dos categorías independientes: **SFX** (eventos del motor: mover, bloquear, victoria/derrota) y **música de fondo**.
- Controles en Ajustes (C4): mute global + volumen separado para SFX y música.
- La preferencia de audio se **persiste a nivel de usuario** (junto con D1 / preferencias).
- Restricciones de autoplay en móvil/navegador: el audio arranca tras interacción del usuario.
- Los SFX se enganchan a los `outcome` de B2 (`advanced`/`blocked`/`destroyed`) sin acoplarse al dominio (mismo patrón "caller" que ya usa la animación).

---

### G2 — Internacionalización (ES / EN)  ❌ *pendiente* · ⭐ *requisitos ya indicados por el usuario*
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

### G3 — Temporizador visual por nivel  ❌ *pendiente*
**Depende de:** C1 ✅ · **Capa:** Presentation (+ posible Domain según P23)

Puntos clave:
- 🔶 **P23 — ¿El timer afecta el score o es solo visual? (decisión bloqueante):** impacta A5 y G3.
  - Si **solo visual** → vive en Presentation y no toca el dominio.
  - Si **afecta score** → debe medirse en **ticks deterministas** (coherente con A5/A3), no en segundos de reloj.
- El timer se **pausa** cuando la UI entra en `PAUSED` (estado de flujo de C4) y se **detiene** en `WON`/`LOST`.
- Relación con `allowedMoves`: aclarar si es solo informativo o si existe además un límite de tiempo por nivel.
- Formato de presentación (mm:ss o ticks) y reinicio al hacer `restart`.

---

## Decisiones bloqueantes a cerrar (cliente)

| Decisión | Bloquea | Estado / recomendación |
|---|---|---|
| **NQ4** — Tecnología de render | B1/B2 | ✅ **Resuelto → SVG** |
| **P21** — Conflictos de sincronización | **D2** | 🔶 **Conservar mayor score** (merge por máximo) |
| **P22** — Origen de assets de audio | **G1** | 🔶 Empaquetados en la app inicialmente |
| **P23** — Timer ¿afecta score? | **G3**, A5 | 🔶 Empezar **solo visual** (no toca dominio) |
| **P24** — Alcance de i18n | **G2** | 🔶 **Solo UI**; niveles fuera de alcance v1 |
| Regla de desbloqueo de niveles | **C3** | 🔶 Definir secuencial vs abierto |
| Alcance de usuario local (invitado vs login) | **D1** | 🔶 Definir asociación de progreso anónimo |
| Estado de flujo `PAUSED` (UI) | **C4**, G3 | 🔶 Falta; agregar a la capa de presentación |

---

## Apéndice — Dependencias backend (referencia, no es el foco)

Solo se listan porque **D2** y **C3** consumen su contrato. Detalle completo cuando se aborde el repo `arrow-maze-backend`.

- **F3 — API de progreso del jugador** (`/api/progress`, JWT, aislamiento por `userId`, persiste solo la mejor marca). Es el espejo remoto de D1 y lo que sincroniza D2. 📝 Spec lista: [`features/F3-recepcion-consulta-progreso.feature`](../features/F3-recepcion-consulta-progreso.feature).
- **F4 — Leaderboard por nivel** (`/api/v1/leaderboard/:levelId`, ranking por score, top-N + posición propia). 🔶 P20: por nivel vs global.
