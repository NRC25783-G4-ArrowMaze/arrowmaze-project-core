# Sesión — C4: Scaffolding del feature "Pantallas de soporte"

- **Fecha:** 2026-07-07
- **Modelo:** Claude Fable 5 (claude-code)
- **Metodología:** Scaffolding de spec (skill `newfeature`) — sin elicitación ni matriz de decisiones
- **Duración estimada:** ~10 minutos
- **Feature:** C4

## Contexto

C4 (Pantallas de soporte del juego) no estaba contemplado como sesión de trabajo activa; el usuario pidió crear el feature "que originalmente no estaba contemplado". C4 ya existía como fila en `docs/FEATURES.md` y `docs/BORRADOR-features-pendientes.md` con estado ⚠️ *parcial* (el `GameOverlay` de Victoria/Derrota ya implementado; faltan Inicio, Pausa y Ajustes), pero no tenía `.feature` propio.

Se usó el skill `newfeature` para generar el andamiaje siguiendo el formato de features existentes (`C3-seleccion-niveles-progreso.feature` como referencia de estilo) y de planes (`feature3_plan.md` de arrowmaze-game como referencia de estructura). El resumen del feature y el bloque de CONCEPTOS CLAVE se redactaron a partir de los puntos clave ya documentados en el borrador de pendientes (estado de flujo `PAUSED`, congelado de reloj, enlaces a G1/G2/C3). **No se redactaron los escenarios Gherkin** ni se detalló el plan de implementación — quedan explícitamente para una sesión posterior.

## Artefactos generados

- `features/C4-pantallas-soporte.feature` (este repo) — Background + bloque de CONCEPTOS CLAVE + un Scenario placeholder y 4 escenarios sugeridos comentados (inicio, pausa, acciones de pausa, ajustes, navegación reversible), pendientes de redactar en Gherkin.
- `features/C4-pantallas-soporte.feature` (espejo idéntico en `arrowmaze-game`, siguiendo la convención de duplicar specs en ambos repos) — commit y push directos a `dev`.
- `doc/C4-pantallas-soporte_plan.md` (en `arrowmaze-game`) — esqueleto de plan con las secciones estándar vacías (Decisiones de Diseño, Propuesta de Cambios por capa, Archivos que NO se tocan, Orden de Implementación, Riesgos, Criterios de Completitud). **No se commiteó** — el usuario indicó que el plan se detallará en una sesión posterior.

## Decisiones tomadas en esta sesión

| # | Decisión | Rationale |
|---|---|---|
| 1 | Solo se sube el `.feature` a ambos repos (`main` en project-core, `dev` en arrowmaze-game); el plan de implementación queda fuera de este commit | El usuario pidió explícitamente separar el andamiaje de la spec del diseño detallado, que se abordará después |
| 2 | El `.feature` se duplica en `arrowmaze-game/features/` como espejo exacto del de `project-core` | Sigue la convención observada en el resto de specs (C2, C3, etc., que están duplicadas byte-a-byte en ambos repos) |

## Pendientes que deja esta sesión

- Redactar los escenarios Gherkin reales de `C4-pantallas-soporte.feature` (Inicio, Pausa, Ajustes, navegación reversible).
- Detallar `doc/C4-pantallas-soporte_plan.md` (arrowmaze-game) en una sesión SDD dedicada, incluyendo cómo se introduce el estado de flujo `PAUSED` sobre la máquina de estados de C1.
- Actualizar la fila C4 en `docs/FEATURES.md` para enlazar el nuevo `.feature` (hoy sin link, a diferencia de C2/C3).
