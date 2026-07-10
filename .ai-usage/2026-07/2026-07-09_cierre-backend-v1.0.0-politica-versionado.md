# Sesión — Cierre del backend en v1.0.0 y política de congelamiento del versionario

- **Fecha:** 2026-07-09
- **Modelo:** Claude Opus 4.8 (claude-code), planificación con sub-agente Explore en modo plan
- **Metodología:** Plan mode (exploración de `arrowmaze-project-core` → `AskUserQuestion` para fijar alcance de registro y forma de la política → plan escrito y aprobado) seguido de edición documental directa
- **Duración estimada:** ~35 minutos
- **Feature:** ninguna (sesión de documentación/gobernanza, no SDD; no genera `.feature`)
- **Repositorio principal:** `arrowmaze-project-core` (consume el estado de `arrowmaze-backend`, no lo modifica)

## Contexto

El backend **cerró su versión 1.0.0**: el trabajo de la rama `feature/patrones-aop-swagger`
(patrones GoF, aspectos AOP `ErrorHandlerAspect`/`RequestLoggingAspect` y OpenAPI/Swagger en
`/api/docs`) fue **mergeado (PR #17)** a `develop` y **promovido a `main` como release `v1.0.0`
(#18)**, con CI de build+tests en cada PR (tag `v1.0.0` presente en el repo del backend). Sin
embargo, `project-core` todavía describía ese trabajo como *"rama `feature/patrones-aop-swagger`,
PR #17 pendiente de aprobación"* — lenguaje ya obsoleto tras la sesión previa del 2026-07-09
(`2026-07-09_backend-arquitectura-sync-vitacora.md`), que se hizo mientras el PR aún esperaba.

Además, el usuario pidió dejar registrada una **política de versionado**: project-core es un
"versionario" que documenta cada repo de implementación **hasta su `v1.0.0`**. Al cerrar esa
versión, la documentación del repo se **congela**; las versiones posteriores evolucionan de forma
independiente y **no** se re-espejan aquí (sería un duplicado manual, no automatizado, sin sentido
de mantener). El **cliente (`arrowmaze-game`) aún no cierra** su versión: se sigue documentando
hasta que cierre su propia `v1.0.0`, y entonces aplica el mismo congelamiento. Tras esos cierres,
project-core pasa a funcionar como **bitácora histórica** que puede quedar altamente obsoleta —
función esperada, no defecto.

## Matriz de decisiones

| # | Decisión | Resultado | Rationale |
|---|---|---|---|
| D1 | Alcance del registro de este cambio meta | **Sesión SDD completa** (reporte + entrada en `manifest.json` + actualización de la vitácora), no solo editar los docs | El usuario lo eligió en `AskUserQuestion`; mantiene la traza auditable que exige la convención del repo |
| D2 | Forma de expresar la política de versionado | **Sección dedicada + tabla repo→versión→estado** en el README, con notas equivalentes en `CLAUDE.md` y `FEATURES.md` | El usuario prefirió una declaración explícita y escaneable sobre notas inline dispersas |
| D3 | Estado del cliente en la tabla | **`arrowmaze-game` = "sin cerrar / en curso"** — se sigue documentando hasta su v1.0.0 | El cliente aún no cierra; la política se le aplicará cuando cierre, no ahora |
| D4 | Deuda de bookkeeping C1-FSM heredada de sesiones previas | **Verificada y ya saldada** — la sesión `2026-07-07_c1-fsm-flujo-partida-sdd.md` sí está registrada como `2026-07-07-004` en `manifest.json` y en la vitácora | La "deuda" anotada en los reportes del 2026-07-09-001 quedó obsoleta: la entrada fue agregada en algún punto posterior. Se verificó por conteo que no hay reportes de sesión sin registrar ni `id`/`file` duplicados |

## Artefactos generados

- `.ai-usage/2026-07/2026-07-09_cierre-backend-v1.0.0-politica-versionado.md` (este archivo).
- `.ai-usage/manifest.json` — nueva entrada de esta sesión; `totalSessions` 24 → 25; `lastUpdated`/`dateRange.end` = 2026-07-09.
- `vitacora/index.html` — esta sesión añadida al array embebido (`repository: "project-core"`); bloque `metadata` actualizado (contador de `project-core`, `totalSessions`, `lastUpdated`, `dateRange.end`).
- `README.md` — nueva sección "🔒 Política de versionado y congelamiento" con tabla por repo; línea "Estado actual", fila de estado del pie y "Última actualización" (→ 2026-07-09).
- `docs/FEATURES.md` — estado del Grupo F actualizado (mergeado PR #17 + liberado `v1.0.0` #18 + CI; congelado) y nota de congelamiento en el blockquote de cabecera.
- `CLAUDE.md` — estado del backend actualizado a `v1.0.0` (merged/released/frozen); nota de política de versionado en "Project Overview".

## Modificaciones manuales del equipo

- Ninguna corrección de código (sesión puramente documental). El usuario fijó el alcance
  (sesión SDD completa) y la forma de la política (sección + tabla) vía `AskUserQuestion` antes de
  escribir el plan; aprobó el plan sin cambios posteriores.

## Validación realizada

- `.ai-usage/manifest.json` y el bloque `<script id="manifest-data">` de `vitacora/index.html`
  parseados con `python3 -m json.tool` — ambos válidos.
- `totalSessions` del manifest verificado por longitud real del array (24 → 25); contadores por
  repo de la vitácora reconciliados por conteo.
- Grep de residuos: no queda texto que describa el trabajo del backend como "pendiente de
  aprobación" / "PR #17 pending" en `docs/`, `README.md` ni `CLAUDE.md`.

## Pendientes que deja esta sesión

- **Ninguna deuda de bookkeeping pendiente.** Se verificó que todos los reportes de sesión en
  `.ai-usage/` tienen entrada en el manifest; los 2 `.md` sin entrada propia son intencionales
  (un reporte-resumen de período mayo–junio y la versión en formato `ai-usage-reporter` de la
  sesión `2026-07-09-001`, que no son sesiones distintas).
- El **cliente (`arrowmaze-game`) aún no cierra** su `v1.0.0`; cuando lo haga, aplicar el mismo
  congelamiento y actualizar la tabla de versiones del README. **Plan de futuro (definido por el
  usuario):** tras el cierre del cliente, project-core cargará "la vida del proyecto" — diagramas
  y la construcción general del proyecto con IA — como memoria histórica hasta la v1.0.0.
