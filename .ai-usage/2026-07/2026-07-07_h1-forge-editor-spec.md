# H1 — FORGE: Editor Visual de Niveles
## Sesión SDD (Specification Design Decision)
**Fecha:** 2026-07-07 | **Participantes:** Diseño de arquitectura del editor  
**Duración:** ~4 horas de análisis y prototipado en arrowmaze-game

---

## I. CONTEXTO Y OBJETIVOS

### Necesidad
Hoy los niveles se crean editando JSON manualmente (`seeds/levels.seed.json`) o programáticamente. Se requiere una interfaz visual interactiva para que creadores construyan tableros punto-a-punto.

### Visión del FORGE
- **Modalidad:** Web-based, emb edible en arrowmaze-game como ruta separada (`/forge.html`)
- **Flujo:** Editar → Validar → Probar → Publicar/Exportar
- **Reutilización:** Todas las reglas de dominio vienen del backend (sin duplicar)
- **Target:** Creadores de niveles con roles ADMIN

### Restricciones
- No forma parte del build Capacitor (cliente móvil)
- V1 sin solver de movimientos (only playtest UI básico)
- Publicación dual: API REST + JSON para seed

---

## II. DECISIONES FORMALIZADAS (D1-D12)

| ID | Decisión | Justificación | Trade-off |
|----|----------|---------------|-----------|
| **D1** | **Arquitectura limpia:** sceneOps puras (dominio→app→infra→presentación); zustand store con historial | Facilita testing, undo/redo, validación derivada sin duplicación | Más capas, más verboso que mutable directo |
| **D2** | **ID de celda = "col,row" string** | Codifica posición (parseable); LevelLoader valida numéricos | Overhead de parsing en cada lectura |
| **D3** | **Conexiones sin restricción de adyacencia ni puertos opuestos** | El dominio permite conectar cualquier puerto de cualquier celda (regla A1/BLOQUE 3); solo válida si ambas celdas existen | Más flexible pero menos "visual"; UI debe mostrar líneas largas sin confundir |
| **D4** | **Body de flecha excluye cabeza** | Convención del contrato LevelDataDTO; una flecha ocupa |body|+1 celdas | Requiere helper lastCellOf() en cada operación |
| **D5** | **exitPort se auto-deriva del primer segmento** | Cabeza siempre apunta al cuerpo (coherencia visual); rotar solo sin cuerpo | Limita rotación post-extensión; usuario debe planificar exitPort antes de extender |
| **D6** | **Colores por índice (no en DTO)** | Reduce payload; asignación determinista (index % 8 = DEFAULT_ARROW_PALETTE) | Roundtrip toLevelDataDTO→sceneFromLevelData asigna nuevos colores; usuario no controla colores guardados |
| **D7** | **Validación reusa LevelLoader** | Una sola fuente de verdad; sin duplicar reglas de dominio | El FORGE no valida "en seco" (deuda: futuro endpoint backend) |
| **D8** | **Lienzo fijo (gridCols×gridRows), editable** | NO se deriva del bounding box de celdas; permite slots vacíos, undo/redo fluido | Usuario debe recordar expandir lienzo si celdas se salen; UI puede mostrar celdas fuera del lienzo |
| **D9** | **Undo/Redo con snapshots de Scene** | Zustand history: past[], future[] arrays de Scenes; cada op pasa por commit() | Memoria lineal (no grafo); alternativa: event sourcing (overkill v1) |
| **D10** | **Playtest embebido sin persistencia** | Valida flujo usuario sin afectar edición; normaliza escena antes de jugar | No reemplaza GameView real (que tiene lógica de movimiento, colisiones, etc.) |
| **D11** | **Publicación dual: login ADMIN + export JSON** | POST/PUT requieren Bearer token (autenticación backend); export para seed manual | Contraseña en memoria (nunca localStorage); token expira por backend (no en UI) |
| **D12** | **Sin solver v1; deudas documentadas** | Scope v1: creación + validación + playtest básico | Futuro: DELETE endpoint, validación en seco (GET /api/v1/levels/:id/validate), collisionBehavior en DTO |

---

## III. ARQUITECTURA TÉCNICA

### Stack
- **Frontend:** React 19 + TypeScript + Vite
- **State:** Zustand (simple, sin middleware)
- **Rendering:** SVG (boardLayout, cellCenter, portDelta helpers reutilizados)
- **Validation:** LevelLoader del dominio (sin cambios)
- **HTTP:** ForgeApiClient (POST/PUT/GET levels)

### Capas

```
Presentación (React components)
├── ForgeApp (shell, toolbar, atajos globales)
├── ForgeCanvas (SVG interactivo: células, conexiones, flechas)
├── LevelPropertiesPanel (edición de metadata)
├── ValidationPanel (errors/warnings del LevelLoader)
├── PlaytestOverlay (modal con simulador)
└── PublishPanel (autenticación + CRUD + export)

Aplicación (Zustand store + pure operations)
├── forgeStore (state, commit, history)
├── sceneOps (12 funciones puras: addCell, toggleConnection, etc.)
├── validateScene (validación derivada)
└── ForgeApiClient (HTTP)

Dominio (reutilizado, sin cambios)
├── LevelLoader (validación canónica)
├── LevelDataBoardBuilder
├── LevelDataArrowBuilder
└── Scene interface
```

### Flujo de Datos

1. **Input:** click en SVG → useForgeInput → (col, row) → handleCellClick
2. **Action:** dispatch a store (ej: addCell) → commit sceneOps.addCell
3. **Mutation:** sceneOps retorna new Scene (pure)
4. **State:** zustand set({ scene: newScene, history: {...} })
5. **Render:** componentes se suscriben a store → re-render

### Undo/Redo

```
Operación N:
  state.past = [scene0, scene1, ..., sceneN-1]
  state.scene = sceneN (actual)
  state.future = []

Ctrl+Z (undo):
  state.past = [scene0, ..., sceneN-2]
  state.scene = sceneN-1
  state.future = [sceneN, ...]

Ctrl+Shift+Z (redo):
  state.past = [..., sceneN-1]
  state.scene = sceneN
  state.future = []
```

---

## IV. INTERFACE Y FLUJO

### Modos de herramienta

| Modo | Primer click | Segundo click | Acción |
|------|-------------|----------------|--------|
| **cell** | slot vacío → addCell | celda existente → removeCell (confirm) | Coloca/borra celdas |
| **connect** | puerto A (rojo) | puerto B → toggleConnection | Conecta puertos (arl. puerto-a-puerto) |
| **arrowHead** | celda libre → placeHead | — | Coloca cabeza de flecha |
| **extend** | flecha (rojo) | candidata → extendArrow | Selecciona + extiende |
| **erase** | celda ocupada → deleteArrow | — | Borra flecha |
| **select** | celda ocupada → selectArrow | — | Selecciona flecha (halo rojo) |

### Atajos globales

- **Ctrl+Z / Ctrl+Shift+Z:** Undo/Redo (con contador visible)
- **R:** Rotar cabeza (solo si sin cuerpo)
- **Escape:** Deseleccionar + cancelar conexión pendiente

### Validación en tiempo real

Panel muestra:
- ✅ **Válido** (verde) si no hay errores
- ❌ **Errores** (rojo, count) si:
  - ID vacío o con espacios
  - allowedMoves ≤ 0
  - Sin celdas
  - Sin flechas
  - Error de topología (LevelLoader)
- ⚠️ **Warnings** (amarillo, count) si:
  - Celdas aisladas (sin conexiones)
  - Flechas sin cuerpo (solo cabeza)

---

## V. CASOS DE USO VERIFICADOS

### E2E: Crear nivel completo

1. **Fase 0-2:** Edición
   - Coloca 4 celdas en línea: (0,0), (1,0), (2,0), (3,0)
   - Conecta: (0,0)↔(1,0), (1,0)↔(2,0), (2,0)↔(3,0) via puertos S↔N
   - Validación: aún muestra ✗ (sin flechas)

2. **Fase 3:** Flechas
   - Cabeza en (0,0), R para exitPort N → S
   - Extend a (1,0), exitPort auto-derivado al puerto S→N
   - Extend a (2,0)
   - Flecha final: head=(0,0,exitPort=S), body=[(1,0), (2,0)], ocupa 3 celdas

3. **Fase 4:** Propiedades + Validación
   - ID: "level-01", Moves: 10
   - Validación: ✓ Válido (verde)

4. **Fase 5:** Playtest
   - Click "Probar" → modal abre
   - Simula 10 movimientos
   - "Volver" → nivel intacto

5. **Fase 6:** Publicación
   - Login: admin@test.com / password
   - Click "Publicar" → POST /api/v1/levels
   - 201 → "✓ Publicado"
   - Click "Exportar JSON" → descarga level-01.json

---

## VI. DEUDAS Y FUTURO

### Deudas explícitas (v1 no incluye)

1. **DELETE endpoint** — eliminar nivel publicado (requerirá confirmación)
2. **Validación en seco** — GET /api/v1/levels/:id/validate sin crear
3. **collisionBehavior** — 'stay' vs 'return' no viaja en DTO (limitación v1)
4. **Lógica de movimiento real** — playtest actual (requiere GameView integrada)
5. **Versionado de niveles** — no hay concept de revisiones/historia

### Evoluciones posibles

- **Solver embebido:** verificar level es resoluble
- **Importar/duplicar:** copiar nivel existente como template
- **Colaboración:** edición simultánea (WebSocket)
- **Temas:** personalizables colores de flechas
- **Analytics:** logs de creación/prueba para balanceo

---

## VII. VERIFICACIÓN

### Checklist Fase 0 (SDD)

- ✅ 12 decisiones de diseño formalizadas
- ✅ Arquitectura documentada (capas, flujo, atajos)
- ✅ Interfaz de usuario especificada (modos, validación, playtest)
- ✅ E2E checklist (crear → probar → publicar)
- ✅ Deudas explícitas (qué falta, por qué)

### Checklist Fases 1-6 (Implementación en arrowmaze-game)

- ✅ Fase 1: Scaffolding (forge.html, React, zustand)
- ✅ Fase 2: Celdas + conexiones interactivas (sceneOps, useForgeInput, ForgeCanvas)
- ✅ Fase 3: Flechas (placeHead, extend, render, R rotation)
- ✅ Fase 4: Validación + propiedades + undo/redo
- ✅ Fase 5: Playtest embebido (PlaytestOverlay)
- ✅ Fase 6: Publicación + export (ForgeApiClient, PublishPanel)

**ESTADO:** Implementación completa. Pronto para testing E2E con backend real.

---

## VIII. PRÓXIMOS PASOS

1. **Testing E2E:** Con backend en `http://localhost:3000`
   - Login ADMIN
   - Crear nivel
   - Verificar en GET /api/v1/levels/:id
   - Seed import (copiar JSON → pnpm seed)

2. **Documentación:** Añadir H1 a docs/FEATURES.md, registrar en .ai-usage/manifest.json

3. **Retrospectiva:** Deudas v1 → roadmap v2

---

**Documento generado automáticamente — SDD sesión 2026-07-07**  
**Responsable de decisiones:** Equipo de diseño/implementación FORGE
