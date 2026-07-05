# 📓 Bitácora de IA — Arrow Maze

Página web autocontenida que reconstruye **cómo se usó la inteligencia artificial** en el
desarrollo de Arrow Maze mediante *Desarrollo Dirigido por Especificación* (SDD).

Toma cada sesión registrada en [`.ai-usage/manifest.json`](../.ai-usage/manifest.json) y la
presenta como una línea de tiempo filtrable: fase, grupo de feature y modelo, con sus
decisiones clave, entregables y el aporte del equipo humano.

## Ver la página

- **Local:** abre `vitacora/index.html` directamente en el navegador (no necesita servidor;
  los datos van embebidos, funciona con `file://`).
- **GitHub Pages:** publica desde la carpeta `/vitacora`. El `.nojekyll` evita que Jekyll
  interfiera.

## ¿Cómo se genera?

`index.html` es **un solo archivo** compuesto por tres partes concatenadas:

1. cabecera + estilos,
2. el contenido de `.ai-usage/manifest.json` embebido en un `<script type="application/json">`,
3. el renderizador (JS vanilla) que dibuja las tarjetas.

Los datos van inline a propósito: así la página es portable y no depende de que Pages sirva
la carpeta oculta `.ai-usage/`.

### Regenerar tras actualizar el manifest

Cuando cambie `manifest.json`, vuelve a inyectar el bloque JSON entre las etiquetas
`<script id="manifest-data" type="application/json">` … `</script>` de `index.html`.

## Fase siguiente (pendiente)

El repo `arrowmaze-game` (cliente) tiene su propio `.ai-usage/` y `doc/ai-usage-report.md`,
y `arrowmaze-backend` sumará el suyo. La idea es **consolidar esos registros aquí** para que
la bitácora cubra los tres repos (core + cliente + backend) en una sola vista.
