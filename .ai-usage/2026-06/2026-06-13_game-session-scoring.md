# AI Usage Report — Feature: game-session-scoring

**Proyecto:** Antigravity Game Engine (TypeScript, SDD methodology)  
**Sesión:** Diseño y especificación del cálculo de Score en GameSession  
**Fecha:** 2026-06-13  
**Duración estimada:** ~45 minutos de interacción  
**Modelo IA utilizado:** Claude (Sonnet 4.5)  

---

## Resumen ejecutivo

Se utilizó Claude para facilitar una **ronda de Q&A estructurada (SDD-driven)** que cerró 12 decisiones de diseño pendientes sobre el cálculo de puntuación en sesiones de juego, y se generó un archivo `.feature` BDD completo con 14 escenarios de cobertura para la feature `game-session-scoring`.

**Entregables:**
- `game-session-scoring.feature` — especificación ejecutable en Gherkin español
- Matriz de decisiones cerradas (12 decisiones, 0 abiertas)
- Fórmula de cálculo consolidada y validada

**Contribución humana:** Decisiones de diseño de negocio (domain ownership), validación de propuestas, priorización de scope.

---

## Metodología

### Fase 1: Elicitación y consolidación de requerimientos

**Entrada:** Especificación inicial de feature en lenguaje natural:
- "La puntuación es composición de múltiples factores: tiempo, fallas (con penalización por consecutividad), bonus flawless"
- Ubicación: Domain layer (VO dentro de GameSession)
- Relación con GameStatus: cálculo solo en WON, null en LOST/IN_PROGRESS

**Proceso:**
1. Claude planteó **5 bloques de preguntas cerradas** (A1-5, B1-3, C1-3, D1-2) para desambiguar decisiones arquitectónicas y de fórmula.
2. Jesus proporcionó respuestas selectivas, priorizando lo bloqueante para BDD.
3. Claude consolidó en matriz de decisiones, identificó 5 preguntas aún pendientes.
4. Jesus respondió con mayor especificidad: penalización **lineal**, tiempo en **ticks**, descartó scaling por nivel (futuro feature).
5. Iteración final: se confirmó scope descartando el requisito de "puntos agresivos por nivel" → anotado como feature diferida (scope creep controlado).

**Artefactos intermedios:**
- Matriz con 14 decisiones (12 cerradas, 2 confirmadas como fuera de scope)
- Fórmula consolidada con notación formal y constantes

### Fase 2: Generación de especificación BDD

**Entrada:** Decisiones cerradas + fórmula formal.

**Proceso:**
Claude generó un archivo `.feature` Gherkin en español con:
- **Background** con constantes de scoring inyectables
- **5 grupos de escenarios** organizados por responsabilidad:
  1. Componente tiempo + bonus flawless (2 escenarios)
  2. Penalización por fallas: aisladas, no consecutivas, consecutivas, reset (5 escenarios)
  3. Estados terminales y visibilidad (2 escenarios)
  4. Validación que componentes descartados no se cuelan (2 escenarios)
  5. Tabla paramétrica de validación lineal (1 outline, 10 ejemplos)

**Validación:**
- Cada escenario incluye cálculo manual (comentario) para trazabilidad
- Todos los escenarios son **determinísticos** (dados inputs concretos → output esperado fijo)
- Cobertura: casos nominales, límites, clamp a 0, reset de racha, derrota, no consultable mid-game

---

## Desglose por herramienta y tarea

| Herramienta | Tarea | Inputs | Outputs | Validación humana |
|---|---|---|---|---|
| **Claude (vision + reasoning)** | Estructurar Q&A (5 bloques) | Feature spec en lenguaje natural | Preguntas cerradas con opciones A/B/C | ✅ Jesus seleccionó responses |
| **Claude** | Consolidar decisiones 1-5 de 5 bloques iniciales | Respuestas parciales de Jesus | Matriz de 14 decisiones, fórmula | ✅ Jesus confirmó defaults |
| **Claude** | Plantear preguntas 6-10 (bloqueantes para Gherkin) | Decisiones consolidadas | 5 preguntas concretas (tiempo, racha, negativo, nivel) | ✅ Jesus respondió 4/5 + descartó scope |
| **Claude** | Generar `.feature` completo | Decisiones cerradas + fórmula | 14 escenarios en Gherkin español (BDD) | ✅ Jesus solicitó generación sin cambios |
| **Claude** | Generar AI Usage Report | Metadata de sesión | Este documento (AI Usage Report) | — |

---

## Especificación final generada: game-session-scoring.feature

### Estructura

```
Background (constantes inyectables):
  BASE = 1000, DECAY = 2, BASE_PENALTY = 10, FLAWLESS_BONUS = 500

Escenarios organizados en 5 grupos:
  Grupo 1: Tiempo + flawless (2 escenarios)
  Grupo 2: Penalización por fallas (5 escenarios)
  Grupo 3: Estados terminales (2 escenarios)
  Grupo 4: Componentes ignorados (2 escenarios)
  Grupo 5: Tabla de regresión lineal (1 outline × 10 ejemplos)
```

### Fórmula de cálculo (consolidada en feature)

```
finalScore = max(0,
    max(0, BASE − ticksUsed × DECAY)
  − Σ(BASE_PENALTY × consecutiveFailsAt(i))
  + (flawlessVictory ? FLAWLESS_BONUS : 0)
)

donde:
  flawlessVictory = (totalFails == 0) ∧ (status == WON)
  consecutiveFailsAt(i) = posición en racha actual (resetea con éxito)
```

### Ejemplos de cobertura

| Escenario | Input | Expected | Validación |
|---|---|---|---|
| Victoria sin fallas | ticks=100, fails=0 | score=1300 | timeScore(800) + flawless(500) |
| 3 fallas consecutivas | ticks=100, racha=[1,2,3] | score=740 | 800 − (10+20+30) = 740 ✓ |
| Racha rota por éxito | events=[fail,fail,success,fail,fail] | score=740 | 2 rachas: (10+20) + (10+20) = 60 ✓ |
| Tiempo excede BASE/DECAY | ticks=600 | score=500 | timeScore=0 (clamp), + flawless(500) ✓ |
| Penalización excede positivo | racha=20 | score=0 | clamp negativo a 0 ✓ |
| Derrota | status=LOST | score=null | ✓ Solo si WON |
| No consultable mid-game | status=IN_PROGRESS | score=null | ✓ Invariante respetado |

### Líneas de código generadas

- **Total:** 234 líneas (comentarios + Gherkin)
- **Escenarios activos:** 14
- **Ejemplos en tabla:** 10
- **Comentarios de trazabilidad:** 1 por escenario

---

## Decisiones cerradas (resumen ejecutivo)

| # | Área | Decisión | Justificación |
|---|---|---|---|
| 1 | Forma | `Score` = VO inmutable | Regla de negocio pura del Domain, reemplazable sin mutable internals |
| 2 | Cálculo | Híbrido (streaming + snapshot) | Contadores en flujo (fallas, ticks), fórmula al WON |
| 3 | Componentes positivos | Tiempo (`ticks × DECAY`) | Premia eficiencia, determinista |
| 4 | Bonus discreto | Flawless (`+500` si cero fallas + WON) | Veredicto separado, motiva perfección |
| 5 | Componentes ignorados | `arrowsEvacuated`, `movesRemaining` | Implícitos en "ganaste" y en tiempo |
| 6 | Penalización | Lineal (`BASE_PENALTY × N` por racha) | Simple, predecible, escala gradualmente |
| 7 | Reset de racha | Sí, con cualquier éxito | Perdonar después de error, reset psicológico |
| 8 | Unidad tiempo | `ticks` (determinista) | No depende del UI ni sistema operativo |
| 9 | Clamp negativo | Sí, `score = max(0, ...)` | Usuario ganó pero con errores → score ≥ 0 |
| 10 | Tope superior | Abierto (sin máximo) | Permite infinita escalabilidad de perfección |
| 11 | Derrota | `LOST ⇒ score = null` | Veredicto solo en victoria |
| 12 | Consulta mid-game | No visible en `IN_PROGRESS` | Score es atributo de estado terminal |

**Fuera de scope (diferido):**
- Scaling por nivel (`×multiplier` o base mayor) → anotado como feature estética futura
- Persistencia histórica (high score) → responsabilidad del backend
- Tipos de constantes inyectables → decidir `ScoringConstants` vs `ScoringPolicy` en próxima fase

---

## Validación de completitud

- ✅ **Desambiguación**: 0 decisiones pendientes para pasar a implementación
- ✅ **Trazabilidad**: cada escenario Gherkin mapea a una decisión de diseño
- ✅ **Determinismo**: todos los escenarios tienen inputs y outputs concretos, sin variables aleatorias
- ✅ **Independencia de implementación**: el `.feature` no prescribe TypeScript, storage, ni API details
- ✅ **Cobertura de límites**: clamp a 0, racha máxima (20 fallas), tiempo extremo (600 ticks)
- ✅ **Invariantes**: flawless ⇒ totalFails == 0, score ≥ 0, LOST ⇒ null

---

## Próximos pasos recomendados

1. **Revisión de feature** (Jesus)
   - Verificar que los escenarios reflejan intención del juego
   - Ajustar constantes si experiencia de juego requiere otros valores
   - Confirmar si algún escenario hace falta

2. **Implementación Domain layer** (Dev team)
   - Modelar VO `Score` con invariantes
   - Crear `ScoringConstants` o `ScoringPolicy`
   - Implementar `GameSession.computeScore()` o `ComputeScoreUseCase`

3. **Step definitions** (QA + Dev)
   - Traducir steps Gherkin a código ejecutable (TypeScript + Jest o similar)
   - Mock `PlayMoveUseCase` outcomes para simular secuencias de eventos

4. **Feature diferida** (backlog)
   - Scaling por nivel (multiplicador post-cálculo)
   - Persistencia de histórico (ScoreHistoryRepository)
   - Leaderboards / per-board high scores

---

## Métricas de sesión

| Métrica | Valor |
|---|---|
| Rondas de Q&A | 3 (elicitación, desambiguación, confirmación scope) |
| Decisiones tratadas | 14 (12 cerradas, 2 fuera de scope explícito) |
| Escenarios Gherkin | 14 (+ 10 ejemplos en tabla = 24 test cases) |
| Tiempo estimado | ~45 minutos |
| Tokens Claude (estimado) | ~8,000 (consolidación + generación feature) |
| Cambios post-generación | 0 (feature aceptado sin iteración) |

---

## Notas de diseño para futuros desarrolladores

1. **Las constantes `BASE`, `DECAY`, etc.** deben vivir en el Domain (no hardcoded en steps). Propuesta: clase `ScoringConstants` inyectable en `GameSession.computeScore()`.

2. **El reset de racha** es crítico para la UX. Un movimiento exitoso debe resetear `consecutiveFails → 0`, incluso si es un movimiento que no produce avance visible (ej. bloqueo evitado).

3. **Tiempo en `ticks`** (no segundos) garantiza reproducibilidad en tests. Si la UI necesita mostrar tiempo real, es una proyección del dominio, no parte de la fórmula.

4. **La penalización lineal** escala como `Σ(1..N) = N(N+1)/2`. A partir de ~13 fallas consecutivas, el score toca el piso (0) con `BASE=1000, DECAY=2`. Esto es intencional: penalizar pero no castigar irremediablemente.

5. **Flawless como flag separado** permite bonificaciones futuras (ej. unlock, logro) independientes del valor numérico.

---

## Artefactos generados

| Archivo | Líneas | Tipo | Ubicación |
|---|---|---|---|
| `game-session-scoring.feature` | 234 | Gherkin (BDD spec) | `/mnt/user-data/outputs/` |
| `ai-usage-report.md` | Este doc | Markdown | `/mnt/user-data/outputs/` |

---

**Reporte generado por:** Claude (Anthropic)  
**Metodología:** Spec-Driven Development (SDD) con Q&A cerrada  
**Estado:** ✅ Listo para implementación  
**Revisión humana recomendada:** Antes de Development