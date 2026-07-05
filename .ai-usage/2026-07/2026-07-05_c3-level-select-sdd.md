# Sesión SDD — C3: Selección de niveles (mapa de progreso con desbloqueo por grafo)

- **Fecha:** 2026-07-05
- **Modelo:** Claude Opus 4.8 (claude-code)
- **Metodología:** SDD con Q&A estructurada (elicitación → consolidación → `.feature`)
- **Duración estimada:** ~30 minutos
- **Feature:** C3

## Contexto

El usuario aportó una descripción de diseño detallada de la pantalla de selección de niveles: una **estructura de grafo** (nodos = niveles, aristas = caminos) que comunica de inmediato si la progresión es lineal o ramificada, con una **jerarquía de estado** por iconografía y escala (bloqueado con candado y menor escala; activo/actual como punto focal resaltado; completado con métricas anidadas: estrellas/check/score) y un **flujo espacial** no recto (curva/zigzag). Esa descripción resolvió de hecho la única decisión bloqueante que el borrador dejaba para C3 (la regla de desbloqueo): al hablar de nodos, aristas y "lineal o ramificado", el modelo natural es un **grafo de prerequisitos (DAG)**.

Se partió de los puntos clave de `docs/BORRADOR-features-pendientes.md` (C3) y del contrato `LevelMetadata` de F2/C2. La feature es de **Presentation** y solo **lee** el progreso local (puerto de D1); no toca Dominio ni Aplicación.

## Matriz de decisiones

| # | Decisión | Resultado | Rationale |
|---|---|---|---|
| D1 | Regla de desbloqueo | **Grafo de prerequisitos (DAG)**: un nodo pasa a `disponible` cuando TODOS sus prerequisitos están `completado` (AND); los nodos raíz (sin prerequisitos) están siempre disponibles, incluso offline | Formaliza la descripción del usuario (nodos + aristas, "lineal o ramificado"). Subsume la progresión secuencial (cadena) y soporta rutas ramificadas y uniones. El grafo es la fuente autoritativa del desbloqueo (derivado, no dato primario) |
| D2 | Criterio de completado | **Haber ganado (WON) el nivel una vez** (existe `bestScore`, A5). Sin umbral mínimo para desbloquear; `completado` es monótono (no revierte) | Coherente con A5 (score solo visible en WON) y D1 (conserva solo la mejor marca). Estándar de mapas de progresión |
| D3 | Nodo focal (`actual`) | **Primer nodo `disponible` sin completar** en el orden del `LevelMap`; único punto focal | La descripción pide un único punto focal ("siguiente acción lógica"). Regla determinista incluso con varias ramas disponibles |
| D4 | Métricas del nodo completado | `bestScore` + check siempre; **estrellas 1–3 opcionales** derivadas de `starThresholds` del catálogo (1 por superar, 2 en `[0]`, 3 en `[1]`) | El usuario listó estrellas/check/score como métricas típicas. A5 no tiene cota superior, así que las estrellas requieren umbrales autorados; si faltan, se muestra solo score numérico + check |
| D5 | Toque de nodo bloqueado | **No navega ni descarga `LevelData`**; muestra aviso breve (clave i18n) + candado | Evita gasto de red inútil; da feedback sin ser bloqueante (borrador: "ignorar vs mensaje" → mensaje breve) |
| D6 | Offline-first | La pantalla se arma del **catálogo local + progreso local**; el refresco remoto (F2) es complementario y nunca bloquea el render | Requisito del borrador: C3 debe funcionar sin red; F2 es un complemento oportunista |
| D7 | Presentación pura + i18n | C3 no muta Dominio ni progreso (solo lee proyecciones); textos de UI vía catálogo i18n (G2); el `name` del nivel se muestra tal cual (P24) | Mantiene la separación de capas y la coherencia con G2/P24 |

## Decisiones cerradas en la elicitación (2026-07-05)

Mini-sesión de Q&A que cerró las dos sub-decisiones que habían quedado abiertas. Las tres respuestas confirmaron los defaults ya presentes en la spec:

| Sub-decisión | Opciones ofrecidas | Elección | Efecto |
|---|---|---|---|
| Origen de `starThresholds` | Catálogo aditivo · Extender `LevelMetadata` · Calculadas (máx teórico) · Sin estrellas v1 | **Catálogo aditivo** | Umbrales autorados en el `LevelMap`; NO toca el contrato fijo `LevelData`/`LevelMetadata` (F2/C2) |
| Curva score→estrellas | Dos umbrales absolutos · Porcentajes de máx · 3★ = flawless (A5) | **Dos umbrales absolutos** `[twoStar, threeStar]` | 1★ por superar, 2★ ≥ umbral[0], 3★ ≥ umbral[1]. Coincide con el Scenario Outline ya escrito (`[2000, 3000]`) — sin cambios |
| Uniones (múltiples prerequisitos) | AND (todos) · OR (cualquiera) · Configurable por nodo | **AND (todos)** | Confirma el v1: un nodo se desbloquea solo con todos sus prerequisitos completados |

> Resultado: la spec de C3 queda **completamente cerrada**; el bloque `⚠️ DECISIONES ABIERTAS` de la cabecera se reemplazó por `SUB-DECISIONES CERRADAS`. OR en uniones queda como posible variante futura, fuera de alcance.

**Transporte del `LevelMap`** (prerequisitos + `pathHint` + `starThresholds`): extensión **aditiva** del catálogo que no altera los campos fijos por nivel de `LevelData`/`LevelMetadata` (id, name, difficulty, allowedMoves); la forma concreta del transporte se materializa al implementar el catálogo/F2.

## Relación con D1 (dependencia de implementación)

C3 lee el progreso mediante el puerto `IProgressRepository` (D1) como registros `PlayerProgress { levelId, status, bestScore }`. El desbloqueo es **derivado** (grafo + `completado`), no un flag primario: si D1 cachea un flag de desbloqueo, es una denormalización que debe coincidir con la derivación del grafo (autoritativo). La spec está lista, pero la **implementación sigue bloqueada por D1**: sin persistencia no hay progreso real que mostrar.

## Artefactos generados

- `features/C3-seleccion-niveles-progreso.feature` — 7 Rules, 24 escenarios (+1 outline): desbloqueo por grafo, nodo focal, métricas/estrellas, interacción por estado, offline-first + refresco F2 complementario, presentación pura/i18n/determinismo, representación visual del grafo.
- `docs/FEATURES.md` — C3 → 📝 Spec lista; nota de la regla de desbloqueo resuelta (grafo DAG) con sub-decisiones abiertas.
- `docs/BORRADOR-features-pendientes.md` — sección C3 marcada como spec lista (histórico) + tabla de decisiones actualizada.
- `.ai-usage/manifest.json` — alta de esta sesión.

> Nota: esta spec es **solo Presentation** y de solo lectura sobre el progreso; NO modifica Dominio (A1–A5), Aplicación ni el contrato `LevelData`/`LevelMetadata` (F2/C2).

## Contribución del equipo

- Aportó la descripción de diseño (grafo de nodos/aristas, jerarquía de estado por escala e iconografía, flujo espacial) que resolvió la regla de desbloqueo hacia un modelo de **grafo de prerequisitos** en lugar de secuencial simple o todo-abierto.
- Definió el énfasis en el punto focal (siguiente acción) y las métricas de rendimiento por nodo (estrellas/check/score).

## Pendientes que deja esta sesión

- **Implementar D1** (persistencia local) — desbloquea la implementación de C3.
- Implementar C3 en `arrow-maze-client` (orden sugerido: D1 → C4 → C3 → G2 → G1 → G3 → D2).
- Al implementar el catálogo/F2, materializar el transporte aditivo de `prerequisites`, `pathHint` y `starThresholds` del `LevelMap`.

> Spec de C3 **completamente cerrada** tras la elicitación 2026-07-05 (ya no quedan decisiones abiertas propias de C3).
