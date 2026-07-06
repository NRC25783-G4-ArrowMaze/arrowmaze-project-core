# Sesión SDD H1 — FORGE Editor Visual de Niveles
**Fecha:** 2026-07-07  
**Modelo IA:** Claude Fable 5 + Claude Haiku 4.5  
**Duración:** ~120 minutos  
**Fase:** Tooling & Content Creation  
**Grupo:** H (Herramientas internas)  
**Estado:** Especificación completada + Plan ejecutable  

---

## Resumen Ejecutivo

Sesión SDD para el **FORGE** — editor visual interactivo de niveles donde creadores ADMIN construyen mapas colocando casillas, conectándolas, y armando flechas. La herramienta vive como entry point separada (`forge.html`) en `arrowmaze-game`, reutiliza 100% las reglas del dominio via `LevelLoader`, y publica niveles por dual channel: API ADMIN o export JSON para seed. Especificación completada con 10 decisiones cerradas, .feature canónica en Gherkin, y plan detallado de 6 fases con hitos ejecutables por modelos pequeños (Haiku 4.5).

### Tabla de Decisiones

| ID  | Decisión | Resolución | Rationale |
|-----|----------|-----------|-----------|
| D1  | Modelo de edición | Scene plana + validación derivada | Tolera estados intermedios; reutiliza LevelLoader sin duplicar reglas |
| D2  | Id de celda | Formato normativo "col,row" | Convención que parsea `sceneFromLevelData`; round-trip con paleta por índice |
| D3  | Puertos | portCount=4 fijo (N/E/S/O); opuestos (p+2)%4 derivado | Coherente con `portDelta`; derivación desde adyacencia |
| D4  | Schema arrows | {id, head:{cellId, exitPort}, body: string[] SIN cabeza}; color fuera del contrato | **Cierra divergencia C2–F2–código**; body ordenado; color por paleta (presentación) |
| D5  | Herramientas | 6 modos: select, cell, connect, arrowHead, extend, erase. Tecla R rotar | Cubre 100% del flujo; R es atajo común |
| D6  | Undo/redo | Snapshots de Scene en v1 (Ctrl+Z / Ctrl+Shift+Z) | Scene JSON-serializable; zustand trivial |
| D7  | Validación | Errors bloquean publicar/playtest; warnings informativos. Reutiliza LevelLoader + excepciones canónicas | Coherencia con dominio (C2/A1–A3); panel live |
| D8  | Playtest | Modal con GameView; SIN persistencia de progreso | Juega en edición; GameView acepta progressModule=null |
| D9  | Publicación | Dual: API ADMIN (POST/PUT) + export JSON | Flujo vivo (remoto) + seed versionado (local) |
| D10 | Scope v1 | Sin solver, sin DELETE backend, sin collisionBehavior en contrato | Valida estructura; playtest manual suficiente; deuda para v2 |

---

## Hechos Verificados del Código

### Contrato de Nivel (LevelDataDTO)
```ts
LevelDataDTO {
  id: string; name?: string; difficulty?: string; allowedMoves: number;
  cells: { id: string; portCount: number }[];
  connections?: { fromCell, fromPort, toCell, toPort }[];
  arrows: { id, head: { cellId, exitPort }, body: string[] }[]; // ← D4 resuelve aquí
}
```
- **body NO incluye la celda de la cabeza** (verificado en `LevelDataArrowBuilder.buildAll` del cliente)
- **Color NO viaja en el contrato** (asignado por paleta en `sceneFromLevelData`)

### Piezas Reutilizables (20 ítems)
1. `Scene`, `SceneCell`, `SceneArrow`, `toLevelDataDTO`, `sceneFromLevelData`, `DEFAULT_ARROW_PALETTE` (modelo)
2. `computeBoardLayout`, `cellCenter`, `screenToCell`, `portDelta` (geometría)
3. `CellComponent`, `ArrowComponent` (render)
4. `DOT_COLOR`, `BOARD_BACKGROUND`, `DOT_RADIUS_RATIO`, `BODY_STROKE_RATIO` (tema)
5. **`LevelLoader` + `LevelDataBoardBuilder` + `LevelDataArrowBuilder`** (validación canónica)
6. `GameView` (playtest embebido)
7. `FetchLevelApiClient` (plantilla de estilo API)

### Backend (sin cambios en v1)
- `GET /api/v1/levels/:id` público
- `POST /api/v1/levels` (201/400/409) + `PUT /levels/:id` (200/404/400): requieren `Authorization: Bearer <JWT>` rol ADMIN
- `POST /api/v1/auth/login` → token JWT
- Seed: pegar DTO en `seeds/levels.seed.json` + `pnpm seed` (LevelSeeder idempotente)

---

## Arquitectura

### Modelo de Edición (D1)
Se edita una **Scene plana** (JSON-serializable) `{ id, allowedMoves, cells, connections, arrows }`. NUNCA se manipulan entidades `Board`/`Arrow` en vivo; el editor tolera estados intermedios (cabeza sin body, celda aislada, 0 flechas). Validación es **derivada**:
```
validateScene(scene) → 
  try { new LevelLoader(...).load(toLevelDataDTO(scene)) } 
  catch (e) → ForgeIssue { severity, code, message }
```
Reutiliza 100% las reglas del dominio sin duplicarlas.

### Estado y Render (Zustand)
```ts
interface ForgeState {
  scene: Scene;
  gridCols: number; gridRows: number;
  tool: ToolMode; selectedArrowId?: string; pendingConnectFrom?: string;
  history: { past: Scene[]; future: Scene[] };
  session: { token?: string; email?: string };
  // acciones: addCell, removeCell, toggleConnection, placeHead, rotateHead,
  //           extendArrow, retractArrow, deleteArrow, setLevelProps, 
  //           setTool, selectArrow, undo, redo, loadScene, setSession
}
```
`commit(next: Scene)` → empuja a `past`, limpia `future`, asigna `next`.

### Layout del Lienzo
Lienzo fijo gridCols×gridRows (default 8×8). NO se deriva de las celdas colocadas (evita `cellSize=0` vac ío):
```ts
const maxCol = gridCols - 1, maxRow = gridRows - 1;
const cellSize = computeCellSize(maxCol, maxRow, W, H);
const offset = computeOffset(maxCol, maxRow, cellSize, W, H);
```
Todos los slots son clicables desde el primer click.

---

## Archivos Nuevos

```
arrowmaze-game/
  forge.html                                      # entry HTML
  src/forge/main.tsx                              # bootstrap
  src/presentation/forge/
    ForgeApp.tsx                                  # layout + atajos
    state/forgeStore.ts                           # zustand (Scene + tools + history + session)
    state/sceneOps.ts                             # 10 operaciones puras (Scene → Scene)
    state/validateScene.ts                        # validación derivada → ForgeIssue[]
    forgeViewModel.ts                             # Scene → BoardViewModel + extras
    input/useForgeInput.ts                        # pointer → {col,row} → acción
    components/ForgeCanvas.tsx                    # SVG: 6 capas (fondo, ghosts, conexiones, celdas, flechas, overlays)
    components/ForgeToolbar.tsx                   # selector herramienta + Rotar + Undo/Redo + Playtest
    components/LevelPropertiesPanel.tsx           # formulario de propiedades
    components/ValidationPanel.tsx                # panel de issues
    components/PlaytestOverlay.tsx                # modal con GameView
    components/PublishPanel.tsx                   # login + publicar + cargar + exportar
  src/infrastructure/api/ForgeApiClient.ts        # login, create, update, getLevel
  vite.config.ts                                  # +forge entry
```

**Cambios únicos a archivos existentes:**
- `vite.config.ts`: añadir `forge: 'forge.html'` a `build.rollupOptions.input`

---

## Fases de Implementación

| Fase | Contenido | Hito |
|------|-----------|------|
| **1** | Scaffolding: forge.html, main.tsx, ForgeApp esqueleto, store vacío, lienzo 8×8 read-only | `pnpm dev http://localhost:5173/forge.html` muestra grilla; `pnpm lint/build` verde |
| **2** | Celdas+conexiones: sceneOps + tests, useForgeInput, tools cell/connect, render líneas | Dibujar tablero 3×3 conectado desde cero; tests pasan |
| **3** | Flechas: placeHead/rotateHead/extendArrow/retractArrow/deleteArrow + tests; tools arrowHead/extend/erase/select; R rotar; paleta | Reconstruir nivel sample-level-2 visualmente idéntico |
| **4** | Validación+propiedades+undo: validateScene, ValidationPanel, LevelPropertiesPanel, history/undo/redo+atajos | Borrar celda pisada → error canónico; Ctrl+Z revierte; publicar deshabilitado |
| **5** | Playtest: PlaytestOverlay + GameView + nonce | Botón "Probar" permite ganar/perder; "Volver" restaura edición intacta |
| **6** | Publicación+export: ForgeApiClient, PublishPanel, JSON export/copiar | Checklist E2E: crear nivel, jugar, publicar, cargar, exportar, seed |

---

## Riesgos y Puntos Abiertos

- **ArrowComponent con animaciones**: tiene glide/recoil internos; sin `collideNonce` → render estático (aceptado; envolver si artefactos)
- **Sobrescritura 409**: confirm debe mostrar id para no pisar niveles por accidente
- **Exclusión del bundle móvil**: forge.html entra en `dist/` (precedente preview); si se quiere excluir → modo de build Vite (post-v1)
- **Backend aún acepta DTOs pobres**: validación backend superficial (aceptado v1; anotado como deuda)

---

## Notas de Arquitectura

- El forge **reutiliza 100%** las reglas del dominio. Cero duplicación de lógica de validación.
- **Clean Architecture respetada**: todo el código nuevo vive en presentación + infrastructure (cliente API).
- **Scene JSON-serializable** + **snapshots** = undo/redo trivial.
- **Validación derivada** (intenta cargar con LevelLoader; mapea excepciones a issues) = **single source of truth** = las reglas que rechaza el juego en A1–A3 son exactamente las que rechaza el editor.
- **Playtest embebido** sin persistencia: GameView ya acepta `progressModule=null`; reutiliza el mismo controlador que el juego real.
- **Publicación dual**: API viva + seed JSON para versionado local del backend (ambos endpoints ya existen; cero cambios al backend).

---

## Precedentes en el Proyecto

- **Preview.html**: entry point oculta para testing interactivo (modelo exacto a replicar para forge.html)
- **C3-seleccion-niveles-progreso.feature**: estructura de spec SDD a seguir (CONCEPTOS CLAVE, INVARIANTE, DECISIONES, Rules, Scenarios)
- **LevelLoader + builders**: patrón de validación a reutilizar en validación derivada
- **sceneFromLevelData**: conversión round-trip (DTO ↔ Scene con colores por paleta)

---

## Ejecución

El plan es ejecutable por Claude Haiku 4.5 sin ambigüedades:
- Todos los hechos del código están verificados (4 secciones: contrato, piezas reutilizables, backend, ESLint)
- Arquitectura está especificada (modelo Scene plana, zustand, geometría, validación derivada)
- Archivos nuevos están listados con rutas exactas
- Operaciones puras (sceneOps) están especificadas con contratos input/output claros
- Fases tienen hitos verificables (pnpm dev, tests, features visuales)

**Próximo paso:** Rama feature/h1-forge en arrowmaze-game. Fases 1–6 con commits en cada paso.

---

**Registro:** Entrada en `.ai-usage/manifest.json` sesión 20 de 20.
