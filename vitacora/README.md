# 📓 Bitácora de IA — Arrow Maze

Página web autocontenida que reconstruye **cómo se usó la inteligencia artificial** en todo
el proyecto Arrow Maze: especificación (SDD en `arrowmaze-project-core`), cliente
(`arrowmaze-game`) e implementación de API (`arrowmaze-backend`).

Unifica las sesiones de los tres repos en **una sola línea de tiempo** filtrable por
repositorio, fase, grupo de feature y modelo, con decisiones clave, entregables, autor y
aporte del equipo humano por sesión.

## Ver la página

- **Local:** abre `vitacora/index.html` directamente en el navegador (no necesita servidor;
  los datos van embebidos, funciona con `file://`).
- **GitHub Pages:** publica desde la carpeta `/vitacora`. El `.nojekyll` evita que Jekyll
  interfiera.

## ¿Cómo se genera?

`index.html` es **un solo archivo** compuesto por tres partes concatenadas:

1. cabecera + estilos,
2. un array unificado `sessions` embebido en un `<script id="manifest-data" type="application/json">`,
3. el renderizador (JS vanilla) que dibuja las tarjetas y filtros (incluye filtro por
   repositorio, además de fase y modelo).

Los datos van inline a propósito: así la página es portable y no depende de que Pages sirva
las carpetas ocultas `.ai-usage/` de cada repo.

### Fuente de los datos por repositorio

Cada sesión del array `sessions` trae un campo `repository` (`project-core`,
`arrowmaze-game` o `arrowmaze-backend`) y, cuando está documentado, `author`. La fuente
autoritativa de cada historial sigue viviendo en el repo correspondiente:

- `arrowmaze-project-core/.ai-usage/manifest.json` — sesiones SDD (specs), ya en el
  esquema nativo del renderer (duración, fase, decisiones detalladas, etc.).
- `arrowmaze-game/.ai-usage/manifest.json` — sesiones de implementación del cliente.
- `arrowmaze-backend/.ai-usage/manifest.json` — sesiones de implementación de la API.

### Regenerar tras actualizar cualquier manifest

Cuando cambie alguno de los tres `manifest.json`, hay que reconstruir el array `sessions`
unificado y reinyectarlo en el `<script id="manifest-data">` de `index.html`:

1. Tomar las entradas de `project-core` tal cual (ya están en el esquema del renderer).
2. Normalizar las entradas de `arrowmaze-game` y `arrowmaze-backend` al mismo esquema
   (`id, date, month, title, aiModel, tool, author, phase, feature, context, deliverables,
   keyDecisions, status, repository, keywords, validationNotes`), agregando
   `"repository": "arrowmaze-game"` / `"arrowmaze-backend"` a cada una.
3. Concatenar los tres arrays, ordenar por `date`, y reemplazar el contenido del bloque
   `<script id="manifest-data" type="application/json">…</script>`.

No hace falta mantener un bloque `linkedRepositories` aparte — las sesiones de los tres
repos conviven en el mismo array y se distinguen por `repository`.
