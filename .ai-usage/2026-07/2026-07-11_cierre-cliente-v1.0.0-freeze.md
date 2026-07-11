# Sesión — Cierre del cliente en v1.0.0 y congelamiento total del versionario

- **Fecha:** 2026-07-11
- **Modelo:** Claude Fable 5 (claude-code)
- **Metodología:** Relevamiento del estado final del cliente (CHANGELOG v1.0.0, release #62, código de `Score.ts` para verificar P23) → edición documental directa replicando el patrón del cierre del backend (sesión `2026-07-09-002`)
- **Duración estimada:** ~40 minutos
- **Feature:** ninguna (sesión de documentación/gobernanza, no SDD; no genera `.feature`)
- **Repositorio principal:** `arrowmaze-project-core` (consume el estado de `arrowmaze-game`, no lo modifica)

## Contexto

El cliente **cerró su versión 1.0.0** el 2026-07-11: el release `dev → main` (#62) de
`arrowmaze-game` liberó el alcance completo — motor de juego (A1–A5), renderizado e input (B1–B3),
flujo de partida con `GameFlowController` (C1), carga de niveles (C2), selección con progreso y
desbloqueo por grafo (C3), pantallas de soporte (C4), persistencia local SQLite (D1), sincronización
remota con gate de sesión y scheduler single-flight (D2), audio (G1), i18n ES/EN (G2), temporizador
visual (G3), editor FORGE con playtest (H1) — más extensiones de producto fuera del roadmap
original: tema claro/oscuro ("G4"), tutorial guiado con el corazón como último nivel, leaderboard
por nivel en el cliente y UI de auth con badge de usuario.

Según la **política de versionado** registrada en la sesión `2026-07-09-002`, al cerrar la v1.0.0
del cliente su documentación en project-core se **congela**, igual que ya ocurrió con el backend
(2026-07-09). Con ambos repos de implementación congelados, project-core pasa a funcionar como
**bitácora histórica** del proyecto — el registro auditable de *cómo* se llegó a la v1.0.0.

## Matriz de decisiones

| # | Decisión | Resultado | Rationale |
|---|---|---|---|
| D1 | Estado de P23 (tiempo→score) al cierre | **Congelado sin materializar** — G3 quedó solo visual; el score de v1.0.0 se basa en ticks | Verificado en `arrowmaze-game/src/domain/value-objects/Score.ts`: `timeScore = max(0, BASE − ticksUsed × DECAY)`, sin término de tiempo real. Si la enmienda de A5 se retoma, evoluciona en el repo del cliente |
| D2 | Estado de P20 (alcance del leaderboard) | **Resuelto en implementación → por nivel** | El cliente v1.0.0 liberó la clasificación por nivel (#46) sobre F4 del backend; no se implementó leaderboard global |
| D3 | Estado de P21 (conflictos de sync) | **Cerrado en implementación** — D2 con gate de sesión + scheduler single-flight (cliente #52) | La sincronización quedó operativa en v1.0.0; su evolución futura vive en el repo del cliente |
| D4 | Alcance de la actualización de la vitácora | **Sitio completo** — bitácora (JSON embebido), portada y "Cómo se hizo" (stats, pills de features, sprints, timeline, política) | Las tres páginas mostraban al cliente "en curso"; dejarlas desalineadas contradiría el cierre. Se corrigieron además los contadores obsoletos del bloque `repositories` (19/31/6 → 27/31/8, reconciliados por conteo real) |

## Artefactos generados

- `.ai-usage/2026-07/2026-07-11_cierre-cliente-v1.0.0-freeze.md` (este archivo).
- `.ai-usage/manifest.json` — nueva entrada de esta sesión; `totalSessions` 26 → 27; `lastUpdated`/`dateRange.end` = 2026-07-11.
- `README.md` — tabla de versionado con el cliente **cerrado y congelado en v1.0.0**; "Fase 3: Cierre"; sección "Próximos pasos" reemplazada por "Estado de cierre"; métricas y pie actualizados.
- `docs/FEATURES.md` — estado final congelado: C1/C3/C4/D1/D2/G1–G3/H1 → ✅; blockquote de cierre del cliente; nota de extensiones de producto; 7 sprints completados; tabla de decisiones con estado al cierre (P20/P21 cerrados, P23 congelado).
- `CLAUDE.md` — fase actual = proyecto cerrado en v1.0.0, repo como bitácora histórica; "Next Steps" → "Project Closure Status".
- `vitacora/bitacora.html` — sesión añadida al JSON embebido + metadata y contadores por repo actualizados.
- `vitacora/index.html` y `vitacora/proyecto.html` — stats, badges de congelamiento, pills de features, sprints, timeline (hito 2026-07-11) y política actualizados.

## Modificaciones manuales del equipo

- Ninguna corrección de código (sesión puramente documental). El usuario definió el alcance
  ("congelar y documentar el cliente hasta v1.0.0 en project-core, según la política de
  versionado/freeze") y aportó el desglose de requisitos de documentación de la entrega.

## Validación realizada

- `.ai-usage/manifest.json` y el bloque `<script id="manifest-data">` de `vitacora/bitacora.html`
  parseados con `python3 -m json.tool` — ambos válidos.
- `totalSessions` verificado por longitud real del array (26 → 27 en manifest; 65 → 66 en la
  vitácora unificada); contadores por repo reconciliados por conteo (`project-core` 27,
  `arrowmaze-game` 31, `arrowmaze-backend` 8).
- P23 verificado contra el código real del cliente (`Score.ts` usa ticks, no segundos).
- Grep de residuos: no queda texto que describa al cliente como "en curso" / "sin cerrar" en
  `README.md`, `docs/FEATURES.md`, `CLAUDE.md` ni en las páginas de la vitácora.

## Pendientes que deja esta sesión

- **Ninguno en project-core.** El versionario está completo: ambos repos de implementación
  congelados en v1.0.0 y el roadmap de 7 sprints cerrado. Este repo queda como memoria histórica
  del proyecto (specs, decisiones, bitácora de IA y sitio de la vitácora) hasta la v1.0.0.
