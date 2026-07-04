# Sesión SDD — Grupo G completo: G1 (Audio), G2 (i18n), G3 (Temporizador visual)

- **Fecha:** 2026-07-04
- **Modelo:** Claude Fable 5 (claude-code)
- **Metodología:** SDD con Q&A estructurada (elicitación → consolidación → `.feature`), una feature a la vez (G1 → G2 → G3)
- **Duración estimada:** ~45 minutos

## Contexto

El usuario pidió cerrar el diseño de las tres features de producto del cliente (grupo G) una por una. Se partió de los puntos clave del `docs/BORRADOR-features-pendientes.md` y se cerraron todas las decisiones bloqueantes del grupo (P22, P23, P24) más las decisiones secundarias de cada feature.

## Matriz de decisiones

### G1 — Audio (SFX y música)

| # | Decisión | Resultado | Rationale |
|---|---|---|---|
| P22 | Origen de assets | **Empaquetados en la app** | 100% offline, sin ruta de descarga; recomendación del borrador aceptada |
| D1 | Controles | **Mute global + volumen SFX y música separados** (en Ajustes/C4) | Recomendación del borrador aceptada |
| D2 | Eventos SFX | **Outcomes del motor (advanced/blocked/exited) + WON/LOST**; sonidos de UI fuera de v1 | El usuario descartó SFX de interfaz |
| D3 | Música | **Pool pequeño por dificultad** (~1 pista por easy/medium/hard), en loop, solo en gameplay | ⭐ Requisito del usuario: variedad "según el nivel" **sin sobrecargar** el bundle. Revisó la decisión inicial de pista única |
| D4 | Autoplay | El audio arranca tras la primera interacción | Restricción móvil/navegador |
| D5 | Licencia | **Todo asset royalty-free / libre de copyright (p. ej. NEFFEX, NCS)** + atribución visible en créditos de Ajustes | ⭐ Requisito del usuario (interrumpió la sesión para añadirlo); atribución elegida para cumplir licencias gratuitas |

### G2 — Internacionalización (ES/EN)

| # | Decisión | Resultado | Rationale |
|---|---|---|---|
| P24 | Alcance | **Solo UI**; contenido de `LevelData` sin variantes de idioma | Evita reabrir P15/C2/F2; recomendación aceptada |
| D1 | Default | Locale del dispositivo; ES → español, cualquier otro → inglés | Requisito previo del usuario (sesión 2026-06-28) |
| D2 | Preferencia | A nivel de usuario, persistida, prevalece sobre el locale | Requisito previo del usuario |
| D3 | Cambio | En caliente, sin reiniciar ni perder estado de partida | Requisito previo del usuario |
| D4 | Clave faltante | **Fallback al texto en inglés** (no clave literal) | Coherente con el fallback de locale |

### G3 — Temporizador por nivel (+ enmienda A5)

| # | Decisión | Resultado | Rationale |
|---|---|---|---|
| P23 | ¿Timer afecta score? | 🟡 **PARCIAL** — decidido que **SÍ debe afectar el score** (❗ revierte la recomendación del borrador "solo visual"); el **cómo** implementarlo queda como decisión abierta | Decisión explícita del usuario: "es una modificación de la fórmula, pero igual es necesario que el timer modifique". Al preparar el PR, el usuario acotó: la integración toca Dominio/Aplicación (A5 ya implementada), así que el mecanismo se cierra en su propia sesión SDD |
| D1 | Dirección | Cuenta hacia arriba, informativo, **sin límite de tiempo** (nunca causa derrota) | La derrota sigue siendo solo por movimientos (A4) |
| D2 | Formato | mm:ss | Legible; ticks descartados como display |
| D3 | Determinismo | **Puerto `IClock` inyectable**; reloj real en Infrastructure, falso en tests. Prerequisito técnico de la futura integración con el score | Preserva la invariante de reproducibilidad; el timer nunca lee el reloj del sistema |
| D4 | Pausa | Timer congelado en `PAUSED` (C4), detenido en WON/LOST, reiniciado con `restart` | Del borrador, confirmado |

## P23 — mecanismo de integración tiempo→score (decisión ABIERTA)

Candidatos evaluados en la sesión (documentados también en la cabecera de G3):

- **a) Término aditivo** `clockPenalty = segundosActivos × TIME_DECAY` — favorito preliminar (conserva el significado de los ticks); durante la sesión se llegó a redactar la enmienda de A5 con este mecanismo, pero **se retiró antes del PR** por decisión del usuario: toca Dominio/Aplicación y merece su propia sesión.
- b) Conversión segundos → ticks a tasa fija (reusa `DECAY`, pero redefine "tick").
- c) Bonus por rapidez bajo umbral (no penaliza; requiere umbrales por nivel).

**Estado:** `A5-game_session_scoring.feature` queda **sin modificar** en este PR. G3 v1 es solo visual (Presentation) e incluye un escenario marcado como "caduca al cerrar P23".

## Artefactos generados

- `features/G1-audio-sfx-musica.feature` — 6 Rules, 20 escenarios
- `features/G2-internacionalizacion.feature` — 4 Rules, 12 escenarios (+1 outline)
- `features/G3-temporizador-nivel.feature` — 5 Rules, ~13 escenarios (+1 outline) — solo Presentation
- `docs/FEATURES.md` — G1/G2/G3 → 📝 Spec lista; P22/P24 → ✅ resueltas; P23 → 🟡 parcial
- `docs/BORRADOR-features-pendientes.md` — grupo G marcado como spec lista (secciones quedan como histórico)
- `.ai-usage/manifest.json` — alta de esta sesión

> Nota: `features/A5-game_session_scoring.feature` NO se modifica en este PR (la enmienda
> redactada durante la sesión se retiró al dejar P23-mecanismo como decisión abierta).

## Contribución del equipo

- Cerró P22 y P24, y todas las decisiones secundarias del grupo G vía Q&A estructurada.
- **Revirtió la recomendación de P23** (el timer sí debe afectar el score), pero acotó su alcance al preparar el PR: el *cómo* toca Dominio/Aplicación y se decide en su propia sesión; G3 v1 queda solo visual.
- Añadió a mitad de sesión el requisito de licencia (royalty-free, NEFFEX/NCS) y la variación de música por nivel sin sobrecargar el bundle (resuelto como pool por dificultad).

## Pendientes que deja esta sesión

- **Cerrar P23-mecanismo** (cómo entra el tiempo en A5) en una sesión SDD dedicada → enmienda de A5 + actualización del cliente.
- Implementar G1/G2/G3 en `arrow-maze-client` (orden sugerido: D1 → C4 → C3 → G2 → G1 → G3 → D2).
