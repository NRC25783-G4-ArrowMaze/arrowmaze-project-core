# 🌐 Sitio de Arrow Maze — Project Core

Página web autocontenida (GitHub Pages) del proyecto Arrow Maze. Consta de tres páginas que
comparten el mismo sistema de diseño y un único conmutador de tema (clave `am-theme`):

| Archivo | Página | Contenido |
|---|---|---|
| `index.html` | **Inicio** (portada) | Hero, métricas del proyecto, accesos a las otras dos páginas y a los tres repos. |
| `proyecto.html` | **Cómo se hizo** | Arquitectura (Clean Architecture + DDD), stack, metodología SDD/BDD, features A–H, timeline y equipo. Contenido derivado de `README.md`, `CLAUDE.md` y `docs/`. |
| `bitacora.html` | **Bitácora de IA** | Cómo se usó la IA en todo el proyecto, sesión por sesión, filtrable por repo, fase, grupo de feature y modelo. |

## Ver la página

- **Local:** abre `vitacora/index.html` en el navegador (no necesita servidor; los datos van
  embebidos, funciona con `file://`). Desde ahí se navega a las otras páginas.
- **GitHub Pages:** publica desde la carpeta `/vitacora`; `index.html` es la raíz del sitio. El
  `.nojekyll` evita que Jekyll interfiera. El workflow `.github/workflows/pages.yml` despliega ante
  cualquier cambio en `vitacora/**`.

> **Nota:** la bitácora vivía antes en `index.html`; ahora está en `bitacora.html` y `index.html`
> pasó a ser la portada. Si tienes enlaces externos a la antigua raíz, apúntalos a `bitacora.html`.

## `proyecto.html` — "Cómo se hizo"

Página estática (contenido escrito a mano, sin datos embebidos). Resume el diseño del proyecto a
partir de las fuentes autoritativas del repo: `README.md`, `CLAUDE.md`, `docs/STACK.md` y
`docs/FEATURES.md`. Al cambiar esas fuentes, actualiza a mano las secciones correspondientes
(estados de features, stack, hitos, equipo).

## `bitacora.html` — Bitácora de IA

Un solo archivo compuesto por tres partes concatenadas:

1. cabecera + estilos,
2. un array unificado `sessions` embebido en un `<script id="manifest-data" type="application/json">`,
3. el renderizador (JS vanilla) que dibuja las tarjetas y filtros (por repositorio, fase y modelo).

Los datos van inline a propósito: así la página es portable y no depende de que Pages sirva las
carpetas ocultas `.ai-usage/` de cada repo.

### Fuente de los datos por repositorio

Cada sesión del array `sessions` trae un campo `repository` (`project-core`, `arrowmaze-game` o
`arrowmaze-backend`) y, cuando está documentado, `author`. La fuente autoritativa de cada historial
sigue viviendo en el repo correspondiente:

- `arrowmaze-project-core/.ai-usage/manifest.json` — sesiones SDD (specs), ya en el esquema nativo
  del renderer (duración, fase, decisiones detalladas, etc.).
- `arrowmaze-game/.ai-usage/manifest.json` — sesiones de implementación del cliente.
- `arrowmaze-backend/.ai-usage/manifest.json` — sesiones de implementación de la API.

### Regenerar tras actualizar cualquier manifest

Cuando cambie alguno de los tres `manifest.json`, hay que reconstruir el array `sessions` unificado
y reinyectarlo en el `<script id="manifest-data">` de `bitacora.html`:

1. Tomar las entradas de `project-core` tal cual (ya están en el esquema del renderer).
2. Normalizar las entradas de `arrowmaze-game` y `arrowmaze-backend` al mismo esquema
   (`id, date, month, title, aiModel, tool, author, phase, feature, context, deliverables,
   keyDecisions, status, repository, keywords, validationNotes`), agregando
   `"repository": "arrowmaze-game"` / `"arrowmaze-backend"` a cada una.
3. Concatenar los tres arrays, ordenar por `date`, y reemplazar el contenido del bloque
   `<script id="manifest-data" type="application/json">…</script>`.

No hace falta mantener un bloque `linkedRepositories` aparte — las sesiones de los tres repos
conviven en el mismo array y se distinguen por `repository`.
