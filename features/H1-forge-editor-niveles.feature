# H1-forge-editor-niveles.feature

Feature: FORGE — Editor visual de niveles
  Como creador de contenido con rol ADMIN
  Quiero un editor visual interactivo para construir niveles (celdas, conexiones, flechas)
  Para publicarlos en la API o exportarlos al seed sin tocar JSON a mano

  # ─────────────────────────────────────────────
  # CONCEPTOS CLAVE
  #
  # Celda (Cell)       : Nodo del tablero identificado por su posición grid "col,row"
  #                      (convención normativa). Siempre portCount=4 (N/E/S/O).
  # Conexión           : Unión bidireccional entre dos celdas adyacentes ortogonales,
  #                      vinculando puertos opuestos (ej: puerto 1/Este de A con
  #                      puerto 3/Oeste de B).
  # Flecha (Arrow)     : Entidad cinética con head (cabeza trasera) y body (segmentos).
  #                      La cabeza ocupa una celda; el body extiende hacia adelante
  #                      celdas por celda. Ocupan celdas; no hay solapamiento.
  # Lienzo             : Grid fijo de 8×8 (editable) donde se construye el mapa.
  #                      Cada slot es clicable independientemente de si contiene celda.
  # Validación         : Chequeo estructural (celdas únicas, conexiones a celdas
  #                      existentes, puertos opuestos, adyacencia de flechas).
  #                      Reutiliza reglas de dominio (C2, A1–A3).
  # ─────────────────────────────────────────────
  #
  # INVARIANTE CENTRAL
  #
  # El editor edita un modelo `Scene` plano (JSON-serializable) con estructura
  # { id, allowedMoves, cells, connections, arrows }. NUNCA manipula las
  # entidades ricas del Dominio (Board, Arrow) en vivo: el editor tolera estados
  # intermedios (cabeza sin body, celda aislada, 0 flechas inicialmente) que las
  # entidades rechazarían. La validación es DERIVADA: cada cambio se valida
  # intentando cargar la Scene con LevelLoader (dominio); excepciones se traducen
  # a issues (error/warning) que se muestran en panel de validación.
  #
  # Publicación requiere validación en verde (errores bloqueados). Playtest
  # embebido ejecuta la Scene SIN persistencia (GameView con `progressModule=null`).
  #
  # DECISIONES DE DISEÑO (sesión SDD 2026-07-07)
  #   D1  Modelo de edición : Scene plana + validación derivada (vs. manipular
  #                           entidades Board en vivo). Tolera estados intermedios
  #                           inevitables al editar.
  #   D2  Id de celda       : Formato normativo "col,row" (enteros base 0).
  #                           Convención que parsea `sceneFromLevelData`.
  #   D3  Puertos           : portCount=4 fijo. Numeración: 0=N, 1=E, 2=S, 3=O.
  #                           Puertos opuestos: (p+2)%4. Derivación automática
  #                           desde adyacencia (inverso de portDelta).
  #   D4  Schema de arrows  : `{id, head:{cellId, exitPort}, body: string[]}`
  #                           donde body es lista ordenada de cellIds SIN la
  #                           cabeza. Cierra divergencia C2–F2–código.
  #                           Color NO viaja en contrato (presentación, por paleta).
  #   D5  Herramientas      : Modos: select, cell, connect, arrowHead, extend, erase.
  #                           Tecla R/botón: rotar cabeza cíclica.
  #   D6  Undo/redo         : Sí en v1 (Ctrl+Z / Ctrl+Shift+Z). Snapshots de Scene.
  #   D7  Validación        : Errors bloquean publicar/playtest. Warnings informativos.
  #                           Reutiliza excepciones de LevelLoader (A1, A2, C2).
  #   D8  Playtest embebido : Modal con GameView, ejecuta sin persistencia.
  #                           Al cerrar se restaura la edición intacta.
  #   D9  Publicación dual  : API ADMIN (POST/PUT) + export JSON (para seed).
  #   D10 Scope v1          : Sin solver/verificación de resolubilidad.
  #                           Sin DELETE de nivel en API. Sin collisionBehavior
  #                           en contrato (limitación documentada).
  #
  # ─────────────────────────────────────────────

  Background: Editor en blanco
    Given el editor se abre sin nivel cargado
    And el lienzo es 8×8 con slots vacíos
    And el nivel inicial es { id: "nuevo-nivel", allowedMoves: 10, cells: [], connections: [], arrows: [] }
    And no hay sesión autenticada

  # ══════════════════════════════════════════════
  # BLOQUE 1 — Lienzo y celdas
  # ══════════════════════════════════════════════

  Rule: Las celdas se colocan y se conectan en el lienzo 8×8

    Scenario: Colocar una celda en un slot vacío
      When el creador usa la herramienta "cell" y hace clic en el slot "2,3"
      Then una celda "2,3" aparece en el lienzo
      And la celda tiene portCount=4
      And no hay conexiones aún

    Scenario: No se puede colocar dos celdas en el mismo slot
      Given una celda "2,3" ya existe
      When el creador intenta colocar otra celda en "2,3"
      Then no cambia nada (operación sin efecto)

    Scenario: Eliminar una celda quita sus conexiones
      Given celdas "0,0" y "1,0" conectadas
      When el creador usa "cell" y hace clic en "0,0" existente (con confirm)
      Then la celda "0,0" se elimina
      And la conexión entre "0,0" y "1,0" se elimina
      And la panel de validación no reporta errores por referencias rotas

    Scenario: Eliminar una celda pisada por una flecha invalida la flecha
      Given una flecha "arrow-1" con cabeza en "0,0" y body ["1,0"]
      When el creador elimina la celda "1,0"
      Then el body de "arrow-1" se queda vacío (la flecha es solo su cabeza)
      And el panel de validación reporta "cuerpo de flecha vacío" (warning)

  # ══════════════════════════════════════════════
  # BLOQUE 2 — Conexiones
  # ══════════════════════════════════════════════

  Rule: Las conexiones unen celdas adyacentes ortogonales con puertos opuestos (D3)

    Scenario: Conectar dos celdas ortogonalmente adyacentes
      Given celdas "0,0" y "1,0" existen
      When el creador usa "connect": click en "0,0", click en "1,0"
      Then la conexión { fromCell:"0,0", fromPort:1, toCell:"1,0", toPort:3 } se crea
      And la conexión es bidireccional (se puede atravesar en ambos sentidos)

    Scenario: No se puede conectar celdas no adyacentes
      Given celdas "0,0" y "2,2" existen
      When el creador intenta modo "connect": click en "0,0", click en "2,2"
      Then la operación se rechaza (segundo click no hace efecto)

    Scenario: Borrar una conexión existente con toggle
      Given celdas "0,0" y "1,0" conectadas (puerto 1↔3)
      When el creador usa "connect" dos veces sobre las mismas celdas
      Then la conexión desaparece (toggle)

    Scenario: Las flechas no pueden extenderse por celdas no conectadas
      Given celdas "0,0" y "1,0" SIN conexión
      And una flecha "arrow-1" con cabeza en "0,0" (exitPort 1)
      When el creador usa "extend" y hace clic en "1,0"
      Then la operación se rechaza (celda no es adyacente-conectada)

  # ══════════════════════════════════════════════
  # BLOQUE 3 — Construcción de flechas
  # ══════════════════════════════════════════════

  Rule: Las flechas crecen celda a celda hacia celdas conectadas y libres (A2, A3)

    Scenario: Colocar cabeza de flecha
      Given una celda "0,0" existe y está libre
      When el creador usa "arrowHead" y hace clic en "0,0"
      Then una flecha nueva {id:"arrow-1", head:{cellId:"0,0", exitPort:0}, body:[]} se crea
      And la celda "0,0" queda ocupada por "arrow-1"
      And la flecha se selecciona automáticamente

    Scenario: No se puede colocar cabeza en celda ocupada
      Given una flecha "arrow-1" ocupa la celda "0,0"
      When el creador intenta "arrowHead" en "0,0"
      Then la operación se rechaza

    Scenario: Rotar la cabeza seleccionada (tecla R o botón)
      Given una flecha "arrow-1" con head {cellId:"0,0", exitPort:0} seleccionada
      When el creador presiona "R"
      Then exitPort cambia a 1 (siguiente módulo 4)
      And otro "R" lo cambia a 2, etc. (cíclica)

    Scenario: Extender flecha hacia celda adyacente-conectada y libre
      Given una flecha "arrow-1" con head {cellId:"0,0", exitPort:1} y body:[]
      And la celda "1,0" está conectada a "0,0" (puerto 1↔3) y libre
      When el creador usa "extend" y hace clic en "1,0"
      Then el body de "arrow-1" pasa a ["1,0"]
      And "1,0" queda ocupada por "arrow-1"

    Scenario: Retraer el body de una flecha (pop)
      Given una flecha "arrow-1" con body ["1,0", "2,0"]
      When el creador usa "extend" y hace clic en "2,0" (última celda) nuevamente
      Then el body se retrae a ["1,0"]
      And "2,0" vuelve a estar libre

    Scenario: Eliminar una flecha
      Given una flecha "arrow-1" ocupa "0,0", "1,0", "2,0"
      When el creador usa "erase" y hace clic en cualquier celda de la flecha
      Then la flecha se elimina
      And todas sus celdas vuelven a estar libres

  # ══════════════════════════════════════════════
  # BLOQUE 4 — Validación estructural
  # ══════════════════════════════════════════════

  Rule: El panel de validación reporta errores y warnings (D7)

    Scenario: Errores bloquean publicar y playtest
      Given un nivel con flechas de 1 celda sin body (inválido)
      When el creador abre el panel de validación
      Then aparece un error "flecha sin body" (o equivalente)
      And los botones "Publicar" y "Probar" están deshabilitados
      And aparece check verde cuando se corrige

    Scenario: Warnings son informativos
      Given un nivel con una celda sin conexión a nada
      When el creador abre el panel de validación
      Then aparece un warning "celda aislada" (información, no bloquea)
      And se puede publicar/playtest

    Scenario: Validación reutiliza reglas del dominio (C2, A1–A3)
      Given un nivel con una flecha referenciando celda inexistente
      When el creador carga/intenta guardar
      Then el error es el mismo del LevelLoader (ej. "BoardRegistryError: cell not found")

  # ══════════════════════════════════════════════
  # BLOQUE 5 — Playtest embebido
  # ══════════════════════════════════════════════

  Rule: Probar el nivel en edición sin persistir (D8)

    Scenario: Abrir playtest del nivel actual
      Given un nivel válido en edición
      When el creador hace clic en "Probar"
      Then se abre un modal con el juego cargando el nivel
      And se puede jugar (mover flechas) normalmente

    Scenario: Ganar en playtest no afecta la edición
      Given está abierto el playtest
      When el creador resuelve el nivel (WON)
      Then el progreso local NO se modifica
      And se puede hacer clic en "Volver al editor"

    Scenario: Al cerrar playtest se restaura el estado de edición
      Given se abrió playtest, se modificó el nivel en el juego
      When el creador hace clic en "Volver al editor"
      Then la Scene de edición está intacta (sin cambios)
      And se puede seguir editando

  # ══════════════════════════════════════════════
  # BLOQUE 6 — Propiedades del nivel
  # ══════════════════════════════════════════════

  Rule: Se editan los metadatos del nivel en el panel de propiedades

    Scenario: Cambiar id del nivel
      Given el nivel tiene id "nuevo-nivel"
      When el creador escribe "mi-nivel-1" en el campo "id"
      Then el id del nivel cambia
      And se puede deshacer (Ctrl+Z)

    Scenario: Cambiar allowedMoves
      Given allowedMoves es 10
      When el creador escribe 25 en el campo "allowedMoves"
      Then allowedMoves cambia a 25

    Scenario: Validar id no vacío
      When el creador intenta dejar el id vacío
      Then el campo rechaza el cambio (o muestra error)

  # ══════════════════════════════════════════════
  # BLOQUE 7 — Export JSON y seed
  # ══════════════════════════════════════════════

  Rule: Exportar el nivel como JSON apto para el seed (D9)

    Scenario: Exportar JSON descarga el archivo
      Given un nivel válido "mi-nivel" en edición
      When el creador hace clic en "Exportar JSON"
      Then descarga un archivo `mi-nivel.json`
      And el contenido es el LevelDataDTO serializado (sin color, sin collisionBehavior)

    Scenario: Copiar JSON para seed al portapapeles
      Given un nivel válido
      When el creador hace clic en "Copiar para seed"
      Then el JSON se copia al portapapeles
      And muestra un toast "Copiado a portapapeles"
      And es apto para pegar directo en `seeds/levels.seed.json` (array)

  # ══════════════════════════════════════════════
  # BLOQUE 8 — Publicación autenticada
  # ══════════════════════════════════════════════

  Rule: Publicar niveles en la API (coherente con F2) (D9)

    Scenario: Login ADMIN dentro del editor
      When el creador ingresa email/password en el panel de publicación
      And hace clic en "Conectar"
      Then se autentica contra POST /api/v1/auth/login
      And el token JWT se guarda en memoria (no localStorage, solo sesión del editor)

    Scenario: Crear nivel nuevo en la API
      Given está autenticado como ADMIN
      And un nivel válido "nuevo-nivel" en edición
      When hace clic en "Publicar"
      Then POST /api/v1/levels con el LevelDataDTO
      And si 201 → aparece toast "Publicado"
      And el nivel remoto puede recargarse con "Cargar nivel…"

    Scenario: Conflicto de id → ofrecer sobrescribir
      Given está autenticado
      And el nivel "sample-level-2" ya existe en el servidor
      When intenta crear un nivel con ese id
      Then POST devuelve 409 (conflict)
      And aparece diálogo "¿Sobrescribir 'sample-level-2'?"
      And si acepta → PUT /api/v1/levels/sample-level-2
      And el nivel se actualiza

    Scenario: Cargar nivel remoto para editar
      Given está autenticado
      When ingresa id "sample-level-2" en el campo "Cargar nivel…"
      And hace clic en "Cargar"
      Then GET /api/v1/levels/sample-level-2
      And la Scene se carga con sceneFromLevelData (colores por paleta)
      And puede editarlo y re-publicar (PUT)

    Scenario: Sesión expira → re-login
      Given el token expiró
      When el creador intenta publicar
      Then la API devuelve 401
      Y aparece "Sesión expirada — ingresa de nuevo"
      Y el panel de login se re-abre
