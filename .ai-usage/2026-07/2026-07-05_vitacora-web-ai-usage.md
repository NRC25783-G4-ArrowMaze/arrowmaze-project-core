# Sesión — Bitácora web de uso de IA (vitácora)

- **Fecha:** 2026-07-05
- **Modelo:** Claude Opus 4.8 (claude-code)
- **Metodología:** Síntesis de documentación + construcción de artefacto web (page-as-deliverable) a partir del registro estructurado existente
- **Duración estimada:** ~40 minutos
- **Fase:** Documentation & Communication
- **Feature:** — (meta; no toca specs ni dominio)

## Contexto

Con el motor y buena parte del cliente ya implementados, el usuario decidió **aprovechar
`arrowmaze-project-core` como escaparate del proceso**: una página web que sirva de bitácora
de cómo se usó la IA a lo largo del proyecto. Esta primera entrega cubre únicamente el
material de **este** repo (`.ai-usage/manifest.json` + reportes), dejando para una fase
posterior la consolidación de los registros de `arrowmaze-game` (cliente) y `arrowmaze-backend`.

## Decisión de alcance

| # | Decisión | Resultado | Rationale |
|---|---|---|---|
| 1 | Fuente de datos | **`.ai-usage/manifest.json` como única fuente** | Ya es el índice estructurado de las 17 sesiones; evita duplicar contenido |
| 2 | Formato del entregable | **Un solo `index.html` autocontenido** con el JSON embebido y renderizador JS vanilla | Portable (`file://`), sin build ni dependencias; sobrevive a que GitHub Pages ignore la carpeta oculta `.ai-usage/` |
| 3 | Ubicación | Carpeta nueva `vitacora/` en el core | Separa la "vista" del "dato"; listo para publicar desde `/vitacora` |
| 4 | Alcance de esta entrega | **Solo el repo core**; cliente/backend quedan para fase siguiente | Petición explícita del usuario ("déjalo en la primera entrega") |
| 5 | Lenguaje visual | Bitácora técnica: línea de tiempo como recorrido de flecha, acentos ámbar/teal sobre tinta, tipografía mono para datos/decisiones | Aterrizado en el mundo del propio juego (flechas, puertos, ticks, Gherkin) |

## Artefactos generados

- `vitacora/index.html` — página autocontenida: dashboard de métricas (sesiones, horas,
  features, decisiones, modelos, todo calculado en vivo), línea de tiempo por mes con nodos
  coloreados por fase, filtros por fase y modelo, tarjetas desplegables con contexto,
  entregables, decisiones + rationale, notas arquitectónicas, decisiones abiertas, aporte del
  equipo y render especial de fórmulas (p. ej. scoring A5). Tema claro/oscuro persistente,
  responsive, `prefers-reduced-motion` respetado.
- `vitacora/README.md` — cómo verla, cómo se ensambla (head + manifest + tail) y cómo
  regenerarla; nota de la fase pendiente (consolidar cliente/backend).
- `vitacora/.nojekyll` — publicación limpia en GitHub Pages.
- `.ai-usage/manifest.json` — alta de esta sesión (metadata a 18 sesiones).

## Naturaleza del cambio

- **No es una sesión SDD.** No hay `.feature`, no se tocan Dominio/Aplicación ni decisiones de
  producto (P-series). Es un artefacto de **comunicación** que consume el registro existente.
- La página lee un **snapshot embebido** del manifest; al actualizar `manifest.json` hay que
  reinyectar el bloque JSON en `index.html` (documentado en el README).

## Contribución del equipo

- Definió la idea (repo core como vitácora pública), el alcance (solo core en la primera
  entrega) y la petición de auto-documentar esta misma entrega.

## Pendientes que deja esta sesión

- **Fase siguiente:** consolidar en la misma vista los registros de `arrowmaze-game`
  (tiene `.ai-usage/` + `doc/ai-usage-report.md`) y `arrowmaze-backend`, para cubrir los tres
  repos (core + cliente + backend).
- Al modificar `manifest.json` en el futuro, reinyectar el JSON embebido de `index.html`.
