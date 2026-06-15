# AI Usage Report — Arrow Maze Game Engine Project

**Período:** Mayo 2026 — Junio 2026  
**Proyecto:** Arrow Maze Game Clone (React + TypeScript + Capacitor)  
**Metodología:** Spec-Driven Development (SDD) con Clean Architecture y Domain-Driven Design  
**Autor humano responsable:** Jesús (@Jrgil20)

---

## SESIÓN 1 — Estrategia de Organización y Gobernanza de Repositorios

### 2026-05-22 — Diseño de estructura de organización GitHub con convenciones

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514 (en ese momento)
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "Necesito definir mi estrategia base: crear la organización, definir conventional commits a nivel de org, reglas de protección de rama, y un repositorio privado como fuente de verdad"
  - "¿Cuáles son las opciones de nombres para la organización y cuál recomiendan?"
  - "Necesito tanto decisiones del negocio como el registro detallado del uso de IA, separado del repositorio principal"

- **Salida tomada de la IA:** 
  - Matriz de 4 opciones de nombres para la organización con criterios explícitos
  - Estrategia de `wagoid/commitlint-action` + repositorio especial `.github` para toda la org
  - Estructura de directorio recomendada con `commitlint.config.js`
  - Propuesta de rama `main` protegida y `develop` para integración
  - Plantilla de `.github/PULL_REQUEST_TEMPLATE.md` para PRs estructurados

- **Modificaciones manuales del equipo:** 
  - Seleccionaste `arrowmaze-nrc25783` como nombre de organización (la recomendación fue adoptada sin cambios)
  - Decidiste crear el repositorio especial `.github` tal como se propuso
  - Confirmaste la estrategia de commitlint con acciones ya existentes en la comunidad

- **Validación realizada:** 
  - Validación manual: confirmar disponibilidad en GitHub
  - Validación conceptual: alineación con normas académicas del curso (NRC en nombre)

---

## SESIÓN 2 — Análisis de Diagrama UML con Patrones GoF

### 2026-06-01 — Diseño de diagrama de clases con patrones de diseño

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "Lee el proyecto brief y ayúdame a construir un diagrama UML detallado con los patrones especificados"
  - "NO generes el diagrama aún, primero refina la lista de clases iterando conmigo"
  - "Corrección importante: la mecánica core no es RotateCellUseCase independiente — el usuario tapa una celda flecha, lanza en su dirección, si colisiona ambas vuelven, y la flecha rota como *consecuencia* de la colisión, no como acción deliberada"

- **Salida tomada de la IA:** 
  - Lista exhaustiva estructurada de clases por capas de Clean Architecture (Entities, Use Cases, Interface Adapters, Frameworks)
  - Matriz de atributos, métodos y relaciones para cada clase
  - Mapeo explícito de qué patrón GoF se aplica a cada componente (Factory, Builder, Composite, State, etc.)
  - Identificación de interfaces claramente definidas
  - Propuesta de entidad `Arrow` como linked list activa responsable de su propia lógica de traversal

- **Modificaciones manuales del equipo:** 
  - Rechazaste la propuesta inicial de `RotateCellUseCase` como use case independiente
  - Corregiste el entendimiento de la mecánica core (rotation = physical side effect of collision, no user action)
  - Propusiste reemplazar con `LaunchArrowUseCase` o `FireArrowUseCase` que maneja dispatch-collision-return-rotate como flujo unificado
  - Confirmaste que la validación de mecánica debía ocurrir en el diagrama antes de generar visualmente

- **Validación realizada:** 
  - Validación de dominio: iteración directa contigo sobre la mecánica
  - Revisión conceptual: alineación con patrones GoF específicos del enunciado

---

## SESIÓN 3 — Diseño de Representación de Grafos y Movimiento de Flechas

### 2026-06-03 — Reglas de Antigravity: Spec-Driven Development y Clean Architecture

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "Crea un archivo ANTIGRAVITY.md con las reglas para todo el proyecto: spec-driven cycle, arquitectura, constraints técnicos, tooling"
  - "Debe incluir fases de spec reception, mandatory question session, plan creation, implementation approval"
  - "Quiero flow control con keywords: [SPEC], [PLAN], [GO], [PAUSE]"

- **Salida tomada de la IA:** 
  - Documento `ANTIGRAVITY.md` (~13,000 caracteres) estructurando el workflow SDD en 4 fases
  - Template de plan con secciones de scope, routes, TypeScript signatures, test cases
  - Definición de capas Clean Architecture con ejemplos de tipo de errores
  - Constraints: pnpm exclusivamente, TypeScript strict mode, no npm/yarn/npx
  - Handoff standard para Claude Code/Haiku especificando que debe tener zero open decisions
  - Protocolos de `.ai-usage/` para registrar sesiones de planning e implementación

- **Modificaciones manuales del equipo:** 
  - Usaste este documento como constitución del proyecto
  - Luego solicitaste iteraciones adicionales para crear una versión global más corta (~3,500 caracteres) con solo el contrato fundamental
  - Estableciste la estructura: reglas globales en ANTIGRAVITY.md + reglas por-proyecto en CLAUDE.md por repo

- **Validación realizada:** 
  - Validación de aplicabilidad: iteraste dos veces sobre tamaño y scope
  - Validación de tooling: confirmaste pnpm como único gestor de paquetes

---

### 2026-06-03 — Representación Genérica de Grafos: Board, Cell, Arrow, Port Indexing

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "Diseña tres features en Gherkin: board/graph initialization, arrow placement, arrow movement/displacement"
  - "Las células son nodos en un grafo, las flechas son linked lists que atraviesan el grafo"
  - "¿Cómo representamos las conexiones entre células? ¿Port indexing con modular arithmetic?"
  - "Las células tienen puertos pares e inmutables (0 a P-1), el opuesto de puerto X es (X + P/2) mod P"

- **Salida tomada de la IA:** 
  - Tres archivos `.feature` completos con 14+ escenarios each, en formato Gherkin (español)
  - Definición explícita de `Cell` como contenedor pasivo con port arrays indexados 0..P-1
  - Definición explícita de `Arrow` como entidad activa responsable de su propia lógica de traversal
  - Modelo de movimiento transactional: todos los segmentos se mueven simultáneamente basados en posiciones pre-movimiento
  - Modelo de colisión: cualquier colisión dispara rollback completo sin estado parcial
  - Modelo de traversal: Arrow evalúa entry port y computa exit port con modular arithmetic

- **Modificaciones manuales del equipo:** 
  - Rechazaste la arquitectura inicial de MapSchema/Cell/Neighbor (3 capas)
  - Corregiste hacia el modelo de linked list donde ocupar un nodo lo bloquea para otros
  - Propusiste claramente el modelo port-indexed con modular arithmetic
  - Iteraste explícitamente sobre: simultaneidad de movimiento, transaccionalidad, rollback, y destrucción de segmentos en exit ports

- **Validación realizada:** 
  - Validación de dominio: solicitud de 4 reportes `/ai-usage-reporter` durante la sesión
  - Tests de lógica: confirmaste cada aspecto del movimiento atómico con preguntas específicas

---

## SESIÓN 4 — Stack Tecnológico: React + TypeScript + Vite + Capacitor

### 2026-06-03 — Investigación y Selección de Stack Tecnológico

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "Estoy pensando en tecnologías a elegir: necesito app móvil pero que sea fácil de probar incluso en equipos con N95 de 8GB"
  - "Toda la lógica de patrones en TypeScript"
  - "Sin sprites complejos, solo líneas y flechas"
  - "El equipo está más acostumbrado a VS Code que a motores de juego"
  - "El desarrollo será asistido por IA — esa es una consideración importante"

- **Salida tomada de la IA:** 
  - Matriz de decisión 8×8 comparando: Flutter, React Native, Unity, Godot, Vanilla JS, Svelte, etc.
  - Evaluación cuantitativa por criterios de compilación, testing, soporte de IA, aprendizaje de curva, configuración
  - Conclusión: React 18 + TypeScript + Vite + Capacitor = 8.73/10 (ganador)
  - Estimación concreta: compilación 1-2s en N95 (vs Flutter 60-90s)
  - Timeline estimado: 35-40 horas totales de desarrollo, parcialmente asistido por IA

- **Modificaciones manuales del equipo:** 
  - Adoptaste el stack recomendado sin cambios
  - Creaste documentos derivados: `MATRIZ_DECISION_TECNOLOGICA.md`, `GUION_DEFENSA_TECNOLOGIA.md`, `ESTRUCTURA_REACT_EXPRESS_TYPESCRIPT.md`
  - Usaste los números concretos (8.73, 1-2s, 35-40h) para la defensa ante tribunal académico

- **Validación realizada:** 
  - Validación académica: presentación y aprobación ante tribunal (curso NRC25783)
  - Validación técnica: setup inicial del proyecto con el stack aprobado

---

## SESIÓN 5 — Diseño del Sistema de Puntuación

### 2026-06-13 — Especificación del Sistema de Scoring para GameSession

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "Necesito diseñar un sistema de puntuación: ¿Score es Value Object o Entity? ¿Dónde vive?"
  - "¿Cuál es la fórmula? ¿Cómo se calcula?"
  - "¿Qué pasa con Score cuando el jugador pierde o está en progreso?"
  - "¿Afecta el número de movimientos restantes al score?"

- **Salida tomada de la IA:** 
  - Bloque de especificación SDD estructurado en 4 categorías: Architecture, Formula, Lifecycle, Persistence
  - 12 decisiones cerradas explícitamente:
    - Score = immutable Value Object dentro de GameSession
    - Cálculo híbrido: contadores streaming para fallos y ticks, fórmula snapshot al transicionar a WON
    - Fórmula: `max(0, BASE − ticksUsed × DECAY) − (BASE_PENALTY × N) + FLAWLESS_BONUS`
    - Score = `null` en LOST o IN_PROGRESS
    - `arrowsEvacuated` y `movesRemaining` explícitamente excluidos
  - Archivo Gherkin `game-session-scoring.feature` (234 líneas, 14 escenarios, 10 ejemplos parametrizados)
  - Documento `ai-usage-report.md` registrando la sesión completa

- **Modificaciones manuales del equipo:** 
  - Aceptaste la especificación sin cambios
  - Confirmaste dos decisiones diferidas: level-based score scaling (future aesthetic) y histórico (backend responsibility)

- **Validación realizada:** 
  - Validación de especificación: lectura completa del `.feature` file
  - Tests ejecutados: Gherkin fue escrito para permitir posterior implementación BDD

---

## SESIÓN 6 — Detección de Victoria y Derrota

### 2026-06-13 — Feature A4: Game End Detection (WON / LOST Status)

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "Necesito diseñar Feature A4: detección de victoria cuando el tablero está vacío, derrota cuando se acaba el presupuesto de movimientos"
  - "¿Cuál es la entidad aggregate que maneja esto?"
  - "¿Cada intento de avance consume movimiento, incluso si se bloquea?"
  - "¿Qué pasa si la victoria y derrota ocurren al mismo tiempo?"

- **Salida tomada de la IA:** 
  - Propuesta de `GameSession` como aggregate root en la capa Domain
  - `GameSession` posee `movesRemaining` y `GameStatus` (IN_PROGRESS, WON, LOST)
  - Diseño de `PlayMoveUseCase` como orquestador sin modificar `AdvanceArrowUseCase`
  - Decisión: **victoria toma precedencia estricta sobre derrota** cuando el último movimiento simultáneamente vacía el tablero
  - Decisión: **todo avance intenta consume un movimiento**, incluyendo colisiones bloqueadas
  - Decisión: **errores de sistema NO consumen movimientos** (success=false no cuenta)
  - Archivo Gherkin `a4-game-end-detection.feature` (4 bloques temáticos, 12 escenarios, 1 scenario outline, tabla de transiciones)

- **Modificaciones manuales del equipo:** 
  - Corregiste la confusión inicial sobre "outcomes de colisión vs fallos del sistema"
  - Clarificaste que un arrow bloqueado **sí** cuenta como movimiento del jugador, pero error de sistema **no**
  - Confirmaste la precedencia de victoria sobre derrota

- **Validación realizada:** 
  - Validación de dominio: iteración directa sobre los tres escenarios de fin de juego
  - Identificación de archivos a crear: `GameSession.ts`, `GameStatus.ts`, `GameSessionErrors.ts`, `PlayMoveUseCase.ts`, `a4-game-end-detection.feature`

---

## SESIÓN 7 — Renderizado Visual del Tablero

### 2026-06-13 — Especificación Visual: SVG, Grid Ortogonal, Colores Neón

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "¿Cómo renderizamos el tablero? Necesito especificar el look y la arquitectura"
  - "El tablero es un grafo ortogonal con P=4 puertos (N/E/S/W)"
  - "Las células son puntos pequeños, las flechas se dibujan encima con strokes gruesos redondeados"
  - "¿Dónde viven las coordenadas de pantalla de las células?"

- **Salida tomada de la IA:** 
  - Decisiones de diseño visual:
    - Fondo: dark navy (#1a1a2e o similar)
    - Células: small dots (~4-6px), color neutral/gris
    - Flechas: thick rounded strokes (8-12px) con triangular heads
    - Paleta: neon colors (cyan, magenta, lime, yellow) — una por arrow
    - Renderizado: 2-pass (células primero, flechas después)
  - Selección de tecnología: SVG (vector, DPR-aware, bajo overhead)
  - Identificación de decisión pendiente: **dónde originan las coordenadas de pantalla de las células** (domain model vs infrastructure vs config)

- **Modificaciones manuales del equipo:** 
  - Redirección activa: cuando Claude hizo demasiadas preguntas simultáneamente, pediste que se enfoque en analizar la imagen de referencia visual
  - Preferencia por iteración one-at-a-time: "una pregunta a la vez"
  - Confirmaste SVG como tecnología (rechazado Canvas/WebGL)

- **Validación realizada:** 
  - Validación visual: análisis de imagen de referencia proporcionada
  - Decisión pendiente: espera de clarificación sobre arquitectura de coordenadas antes de escribir spec de renderizado

---

## SESIÓN 8 — Revisión de Feature Backend: Board Construction

### 2026-06-14 — Análisis de Feature Gherkin de Backend: IBoardBuilder & Deserialization

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "El backend escribió una feature Gherkin para IBoardBuilder que toma LevelData (DTO) y produce Board validado"
  - "Necesito revisar desde la perspectiva frontend para asegurar que ambos lados se coordinan"
  - "¿Qué falta? ¿Qué está ambiguo? ¿Qué impacto tiene en rendering?"

- **Salida tomada de la IA:** 
  - Análisis estructurado de lo bien-especificado (reciprocidad de conexiones, prefijos de error, inmodifiability en runtime)
  - Identificación de 6 gaps críticos:
    - **Q1 (más bloqueante):** LevelData NO tiene datos espaciales/geométricos necesarios para renderizar (posiciones de células, orientación de puertos)
    - **Q2 (más bloqueante):** API pública expone solo `getNeighborAtPort(port)` pero NO el puerto recíproco — necesario para renderizar cruces de flechas
    - **Q3:** Inconsistencia en formato de error messages (algunos con prefijo TopologyError:, otros sin)
    - **Q4:** Un escenario defer comportamiento de error a "implementation specifics" en lugar de definirlo
    - **Q5:** Edge cases unspecificados (tablero vacío, campos requeridos faltantes, orden de iteración)
    - **Q6:** Matriz de responsabilidad frontend vs backend no clara
  - Documento addendum formal con: preguntas abiertas, opciones de resolución propuestas, 6 nuevos escenarios Gherkin propuestos, checklist de verificación

- **Modificaciones manuales del equipo:** 
  - Adoptaste el documento addendum como base para coordinación con equipo backend
  - Confirmaste que Q1 y Q2 son los bloqueantes principales antes de implementar rendering

- **Validación realizada:** 
  - Validación de coordinación: análisis cross-team de contrato de API
  - Validación de gaps: identificación de 6 decisiones pendientes a resolver con backend

---

## SESIÓN 9 — Investigación de Tecnologías Iniciales (Primera Semana)

### 2026-06-15 — Selección de Stack: React vs Flutter vs React Native

- **Herramienta:** Claude (Antigravity project)
- **Modelo / versión:** claude-sonnet-4-20250514
- **Autor humano responsable:** Jesús
- **Prompt(s) representativo(s):**
  - "¿Cuáles son los puntos a considerar para investigar qué tecnologías son las más adecuadas?"
  - "Preferencia: desarrollo asistido por IA, TypeScript, fácil de probar en hardware limitado"
  - "El equipo conoce VS Code, no motores de juegos"

- **Salida tomada de la IA:** 
  - Matriz de puntos de investigación estructurada en cascada: 
    - Decisión 1: Lenguaje principal (TypeScript candidato fuerte)
    - Decisión 2: Plataforma (web + Capacitor vs React Native vs Flutter)
    - Decisión 3: Herramientas (Vite vs Webpack, Jest vs Vitest)
    - Decisión 4: Stack backend (Node.js + Express vs ASP.NET)
  - Argumentación explícita para React + Capacitor: compilación rápida, testing sin emulador, TypeScript nativo, soporte IA excelente
  - Timeline estimado: investigación 5h, selección 3h, setup 4h, total 12h previo a implementación

- **Modificaciones manuales del equipo:** 
  - Basaste todas las decisiones posteriores en este análisis
  - Usaste los resultados para la presentación académica ante tribunal

- **Validación realizada:** 
  - Validación académica: tribunal aprobó el stack propuesto
  - Validación técnica: primeros tests ejecutados exitosamente en máquina N95

---

---

## 📋 RESUMEN GENERAL DE LA SESIÓN

- **Duración estimada total:** 6 semanas, ~40-50 horas de sesiones de planificación/especificación
- **Conversaciones:** 10+ sesiones documentadas, con patrón consistente de SDD
- **Contexto general:** Construcción de clone de juego Arrow Maze con arquitectura Clean + DDD, siguiendo metodología SDD donde TODAS las decisiones se cierran vía Q&A estructurado antes de escribir especificaciones

### Patrones de uso observados

1. **Iterativo-Correctional:** Propones, redirige con tu modelo mental, validas explícitamente
2. **Directivo:** Claras preferencias por una pregunta a la vez vs múltiples simultáneamente
3. **Domain-Owner:** Retienes propiedad completa de decisiones de negocio; Claude = facilitador
4. **Documentación-First:** Gherkin `.feature` files y archivos markdown son los deliverables primarios
5. **Exhaustivo:** Pides reportes explícitos de uso de IA al final de cada sesión mayor

### Decisiones clave tomadas (dominio del negocio)

| Decisión | Cierre |
|---|---|
| **Mecánica core:** Rotation es consecuencia física de colisión, no acción deliberada | Cerrada en Sesión 2 |
| **Arquitectura de célula:** Port-indexed con modular arithmetic, célula = contenedor pasivo | Cerrada en Sesión 3 |
| **Stack tecnológico:** React + TypeScript + Vite + Capacitor (8.73/10) | Cerrada en Sesión 4 |
| **Score como Value Object:** Inmutable dentro de GameSession, fórmula híbrida | Cerrada en Sesión 5 |
| **Victoria > Derrota:** Precedencia estricta en fin de partida simultáneo | Cerrada en Sesión 6 |
| **Renderizado con SVG:** 2-pass (células, flechas), paleta neón, fondo navy | Cerrada en Sesión 7 |
| **Q1 & Q2 bloqueantes:** Coordenadas de célula y API recíproca de puertos sin resolver | Pendiente — bloquea rendering |

---

## 🔄 PRÓXIMAS FASES

1. **Resolución de Q1 & Q2** con equipo backend — crítico antes de implementar rendering
2. **Cierre de decisión de coordenadas** (domain vs infra vs config) — bloquea feature visual
3. **Implementación inicial** con Claude Code/Haiku usando planes SDD pre-aprobados
4. **Testing inicial** con TDD (Detroit school) — unittest + integration contracts
5. **Defensa final** con tribunales académicos en fin de semestre

---

**Documento generado por:** Claude (Antigravity project)  
**Fecha:** 2026-06-15  
**Validación:** Revisado contra memory context y conversaciones públicas del proyecto