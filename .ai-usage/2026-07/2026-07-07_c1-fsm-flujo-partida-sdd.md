# Sesión SDD — C1: Máquina de estados del flujo de una partida (autómata de pila)

- **Fecha:** 2026-07-07
- **Modelo:** Claude Sonnet 5 (claude-code)
- **Metodología:** SDD con Q&A estructurada (elicitación → consolidación → `.feature`)
- **Feature:** C1

## Contexto

C1 aparecía en `docs/FEATURES.md` como "✅ Implementado (falta flujo UI PAUSED/MENU, ver C4)", pero sin `.feature` propio — se implementó ad-hoc en `GameSession.ts` (commits `d7d1b5bf`, `a1b7e6eb`, arrow-maze-client) sin pasar por sesión SDD. Al revisar, se detectó que además del vacío de spec, el diseño mismo estaba incompleto: `GameStatus` solo tiene `IN_PROGRESS | WON | LOST`, sin ningún soporte de pausa/ajustes, y `GameAlreadyFinishedError` está tipado literalmente a `'WON' | 'LOST'` (no aceptaría un tercer valor sin romper).

## Matriz de decisiones

| # | Decisión | Resultado | Rationale |
|---|---|---|---|
| D1 | Ubicación de PAUSED | **Autómata de pila en Presentación/Aplicación**, NO en `GameStatus` de Dominio | Reconciliado con la spec ya cerrada de **G3** (2026-07-04), que asume "tiempo activo = IN_PROGRESS y la UI fuera de PAUSED" — PAUSED como concepto de Presentación. Agregarlo a `GameStatus` habría roto G3 retroactivamente |
| D2 | Alcance de MENU | **Fuera de esta feature** | "No hay partida" es ausencia de `GameSession`/`GameFlowController` (routing de C3), no un estado de esta pila. La pila de C1 solo existe mientras hay un nivel cargado |
| D3 | Reglas de pausa | Solo desde `ACTIVE` con `GameSession.status == IN_PROGRESS`; reloj se congela (consistente con G3 D4, que ya lo asumía) | El usuario confirmó esto explícitamente |
| D4 | Salidas de PAUSED | RESUME, RESTART (nueva `GameSession`, colapsa pila a `[ACTIVE]`), EXIT (descarta todo, sin estado propio) | El usuario pidió las tres explícitamente |
| D5 | Ajustes anidados | SETTINGS se apila solo sobre PAUSED; cerrar ajustes vuelve a PAUSED, no a ACTIVE | El usuario aportó la referencia de **autómatas de pila (Pushdown Automata)** de la industria de videojuegos ("desde Mario Bros"), que resuelve naturalmente el caso de ajustes anidados sobre pausa — algo que un enum plano no modela bien |

## Contribución del equipo

- Identificó que, al no existir `.feature` para C1, no correspondía marcarlo "✅ Implementado" bajo las reglas propias de trazabilidad SDD del proyecto (`CLAUDE.md`).
- Señaló que además del vacío de spec, el diseño de C1 estaba objetivamente incompleto (no era solo un problema retroactivo de documentación).
- Aportó la referencia arquitectónica de **autómatas de pila (Pushdown Automata)** — estado suspendido, no destruido, al pausar; ejecución exclusiva del tope de la pila — que resolvió D1 y D5.

## Hallazgo que reconcilió D1

`features/G3-temporizador-nivel.feature` (ya cerrada) dice textualmente: *"Tiempo activo: segundos transcurridos con la partida en IN_PROGRESS y la UI fuera de PAUSED"* y *"El temporizador vive íntegramente en la capa de Presentación... no escribe en el dominio"*. Esto obligó a mantener PAUSED fuera de `GameStatus` para no invalidar G3.

## Artefactos generados

- `features/C1-maquina_estados_partida.feature` — 7 Rules, 15 escenarios: tope de pila exclusivo, pausar (con guards de terminalidad y de tope), reanudar, ajustes anidados, reiniciar (reemplazo de `GameSession`), salir (descarte total), invariante de separación Dominio/Presentación.
- `arrow-maze-client/doc/C1-maquina-estados-flujo_plan.md` — plan de implementación TDD: `GameFlowController` (autómata de pila) + `GameFlowState` + `InvalidFlowTransitionError`, todo en capa de Aplicación, sin tocar Dominio.
- `docs/FEATURES.md` — pendiente de actualizar el estado de C1 (ver Pendientes).

## Pendientes que deja esta sesión

- Actualizar `docs/FEATURES.md`: C1 debería reflejar "📝 Spec lista (2026-07-07), implementación de flujo pendiente" en vez de "✅ Implementado", ya que el veredicto de Dominio (IN_PROGRESS/WON/LOST) sigue implementado pero el flujo de UI (objeto de este spec) es nuevo y aún no tiene código.
- Implementar `GameFlowController` en `arrow-maze-client` según el plan.
- Conectar `GameFlowController.current` a la capa de input (B3) — el plan deja esto como contrato explícito para la sesión de implementación de C4, que es quien construye las pantallas reales.
- C4 queda desbloqueada para diseñar las pantallas de pausa/ajustes sobre esta FSM ya definida.
