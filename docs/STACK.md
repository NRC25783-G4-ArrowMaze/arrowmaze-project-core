# Stack Ganador: React Web + Capacitor + Express.js
## Estructura de Carpetas y Configuración

---

## 1. RECORDATORIO: STACK ELEGIDO

| Aspecto | Tecnología |
|---------|-----------|
| **Frontend** | React 18 + TypeScript + Vite |
| **Empaquetado móvil** | Capacitor (convierte web app a Android/iOS) |
| **Backend** | Express.js + TypeScript + Node.js |
| **Base de datos** | PostgreSQL (remota) + SQLite (local, testing) |
| **Testing** | Jest + React Testing Library + Supertest |
| **Build & Deploy** | GitHub Actions (CI/CD) |

**Por qué ganó:** 8.73/10
- ⚡ Compilación 1-2s en N95 (vs Flutter 60-90s)
- 🧪 Testing en terminal sin emulador
- 📝 TypeScript en ambos lados (coherencia)
- 🤖 IA genera código excelente
- 🏛️ Clean Architecture natural

---

## 2. ESTRUCTURA DE CARPETAS (FRONTEND)

### Repositorio: `arrow-maze-client`

```
arrow-maze-client/
├── src/
│   ├── domain/                        ← CAPA 1: Lógica pura
│   │   ├── entities/
│   │   │   ├── Board.ts               (grid de celdas)
│   │   │   ├── Cell.ts                (celda con flecha)
│   │   │   ├── Player.ts              (posición jugador)
│   │   │   ├── Direction.ts           (UP, DOWN, LEFT, RIGHT)
│   │   │   ├── Level.ts               (definición nivel)
│   │   │   └── Score.ts               (puntuación)
│   │   │
│   │   ├── value-objects/
│   │   │   ├── Position.ts            (x, y)
│   │   │   ├── Difficulty.ts          (EASY, MEDIUM, HARD)
│   │   │   └── GameResult.ts          (VICTORY, DEFEAT)
│   │   │
│   │   ├── events/
│   │   │   ├── PlayerMoved.ts
│   │   │   ├── LevelCompleted.ts
│   │   │   └── GameOver.ts
│   │   │
│   │   └── services/
│   │       └── PathChecker.ts         (validar si flecha puede llegar a salida)
│   │
│   ├── application/                   ← CAPA 2: Casos de uso
│   │   ├── ports/                     (interfaces/contratos)
│   │   │   ├── IBoardRepository.ts
│   │   │   ├── ILevelRepository.ts
│   │   │   ├── IScoreRepository.ts
│   │   │   └── IAuthService.ts
│   │   │
│   │   ├── use-cases/
│   │   │   ├── MovePlayerUseCase.ts         (rotar flecha + mover)
│   │   │   ├── CompleteLevelUseCase.ts      (validar victoria)
│   │   │   ├── LoadLevelUseCase.ts          (cargar nivel)
│   │   │   ├── SaveProgressUseCase.ts       (guardar progreso local)
│   │   │   └── SyncProgressUseCase.ts       (sincronizar con servidor)
│   │   │
│   │   ├── dtos/
│   │   │   ├── MovePlayerResult.ts
│   │   │   ├── CompleteLevelResult.ts
│   │   │   └── LoadLevelResult.ts
│   │   │
│   │   └── managers/
│   │       ├── GameStateManager.ts    (orquesta el flujo)
│   │       └── CommandHistory.ts      (undo/redo)
│   │
│   ├── data/                          ← CAPA 3: Adaptadores (implementaciones concretas)
│   │   ├── repositories/
│   │   │   ├── LocalLevelRepository.ts    (lee de JSON local)
│   │   │   ├── LocalScoreRepository.ts    (localStorage)
│   │   │   ├── ApiLevelRepository.ts      (GET /api/levels)
│   │   │   └── ApiScoreRepository.ts      (POST /api/scores)
│   │   │
│   │   ├── datasources/
│   │   │   ├── LocalStorageDS.ts          (acceso a localStorage)
│   │   │   ├── ApiDS.ts                   (cliente HTTP)
│   │   │   └── JsonDS.ts                  (cargar JSON local)
│   │   │
│   │   ├── mappers/
│   │   │   ├── BoardMapper.ts             (Entity → ViewModel)
│   │   │   ├── LevelMapper.ts
│   │   │   └── ScoreMapper.ts
│   │   │
│   │   └── models/
│   │       ├── LevelModel.ts              (DTO del API)
│   │       ├── ScoreModel.ts
│   │       └── UserModel.ts
│   │
│   ├── presentation/                  ← CAPA 4: React (UI)
│   │   ├── screens/
│   │   │   ├── HomeScreen.tsx             (inicio)
│   │   │   ├── LevelSelectionScreen.tsx   (elige nivel)
│   │   │   ├── GameScreen.tsx             (juega)
│   │   │   ├── VictoryScreen.tsx          (ganó)
│   │   │   ├── DefeatScreen.tsx           (perdió)
│   │   │   └── LeaderboardScreen.tsx      (ranking)
│   │   │
│   │   ├── components/
│   │   │   ├── BoardComponent.tsx         (renderiza tablero)
│   │   │   ├── CellComponent.tsx          (renderiza celda + flecha)
│   │   │   ├── ScoreDisplay.tsx
│   │   │   └── Timer.tsx
│   │   │
│   │   ├── hooks/
│   │   │   ├── useGame.ts                 (conecta UI con casos de uso)
│   │   │   ├── useLocalStorage.ts
│   │   │   └── useApi.ts
│   │   │
│   │   ├── context/
│   │   │   └── GameContext.ts             (estado global)
│   │   │
│   │   └── utils/
│   │       ├── canvas-utils.ts            (dibujar en canvas)
│   │       └── format-utils.ts
│   │
│   ├── infrastructure/                ← CAPA 4: Detalles técnicos
│   │   ├── config/
│   │   │   └── api-config.ts              (URLs, timeouts)
│   │   │
│   │   ├── services/
│   │   │   ├── AudioService.ts            (música, sonidos)
│   │   │   └── NotificationService.ts
│   │   │
│   │   ├── aop/                           (cross-cutting concerns)
│   │   │   ├── LoggingAspect.ts          (registrar acciones)
│   │   │   ├── AuthorizationAspect.ts    (verificar token)
│   │   │   └── CacheAspect.ts            (cachear resultados)
│   │   │
│   │   └── di/                            (inyección de dependencias)
│   │       └── DIContainer.ts             (resolver dependencias)
│   │
│   ├── App.tsx                        (punto de entrada)
│   └── index.tsx
│
├── __tests__/                         (tests paralelos a src/)
│   ├── domain/
│   │   ├── Board.test.ts
│   │   └── PathChecker.test.ts
│   ├── application/
│   │   ├── MovePlayerUseCase.test.ts
│   │   └── CompleteLevelUseCase.test.ts
│   ├── data/
│   │   └── Repositories.test.ts
│   └── presentation/
│       └── GameScreen.test.tsx
│
├── assets/
│   ├── levels/                        (definición de niveles en JSON)
│   │   ├── level-1.json
│   │   ├── level-2.json
│   │   └── ...
│   ├── sounds/
│   ├── images/
│   └── i18n/                          (traducciones)
│       ├── es.json
│       └── en.json
│
├── public/
│   ├── index.html
│   └── icon.png
│
├── capacitor.config.json              (configuración Capacitor)
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

---

## 3. ESTRUCTURA DE CARPETAS (BACKEND)

### Repositorio: `arrow-maze-backend`

```
arrow-maze-backend/
├── src/
│   ├── domain/                        ← CAPA 1: Entidades
│   │   ├── entities/
│   │   │   ├── User.ts
│   │   │   ├── Level.ts
│   │   │   ├── Score.ts
│   │   │   └── GameSession.ts
│   │   │
│   │   ├── value-objects/
│   │   │   ├── UserId.ts
│   │   │   ├── Email.ts
│   │   │   └── Difficulty.ts
│   │   │
│   │   └── events/
│   │       ├── UserRegistered.ts
│   │       ├── ScoreSaved.ts
│   │       └── LeaderboardUpdated.ts
│   │
│   ├── application/                  ← CAPA 2: Casos de uso
│   │   ├── ports/                    (interfaces)
│   │   │   ├── IUserRepository.ts
│   │   │   ├── IScoreRepository.ts
│   │   │   ├── ILevelRepository.ts
│   │   │   └── IAuthService.ts
│   │   │
│   │   ├── use-cases/
│   │   │   ├── RegisterUserUseCase.ts
│   │   │   ├── AuthenticateUserUseCase.ts    (login)
│   │   │   ├── SaveScoreUseCase.ts
│   │   │   ├── GetLeaderboardUseCase.ts
│   │   │   ├── GetLevelsUseCase.ts
│   │   │   └── SyncProgressUseCase.ts
│   │   │
│   │   └── dtos/
│   │       ├── RegisterUserDTO.ts
│   │       ├── AuthResultDTO.ts
│   │       ├── ScoreDTO.ts
│   │       └── LeaderboardDTO.ts
│   │
│   ├── adapters/                     ← CAPA 3: Adaptadores
│   │   ├── controllers/
│   │   │   ├── AuthController.ts
│   │   │   ├── GameController.ts
│   │   │   ├── ScoreController.ts
│   │   │   └── LeaderboardController.ts
│   │   │
│   │   ├── repositories/
│   │   │   ├── UserRepositoryImpl.ts       (PostgreSQL)
│   │   │   ├── ScoreRepositoryImpl.ts
│   │   │   └── LevelRepositoryImpl.ts
│   │   │
│   │   ├── mappers/
│   │   │   ├── UserMapper.ts              (Entity ↔ DB)
│   │   │   ├── ScoreMapper.ts
│   │   │   └── LevelMapper.ts
│   │   │
│   │   └── validators/
│   │       ├── UserValidator.ts
│   │       └── ScoreValidator.ts
│   │
│   ├── infrastructure/               ← CAPA 4: Frameworks
│   │   ├── database/
│   │   │   ├── postgres-adapter.ts         (conexión PostgreSQL)
│   │   │   ├── migrations/
│   │   │   │   ├── 001-create-users.sql
│   │   │   │   ├── 002-create-scores.sql
│   │   │   │   └── 003-create-levels.sql
│   │   │   └── seeds/
│   │   │       └── levels.seed.ts
│   │   │
│   │   ├── auth/
│   │   │   └── jwt-strategy.ts             (autenticación JWT)
│   │   │
│   │   ├── aop/
│   │   │   ├── LoggingAspect.ts
│   │   │   ├── AuthorizationAspect.ts
│   │   │   └── ValidationAspect.ts
│   │   │
│   │   ├── middleware/
│   │   │   ├── authMiddleware.ts
│   │   │   ├── errorHandler.ts
│   │   │   └── corsMiddleware.ts
│   │   │
│   │   ├── routes/
│   │   │   ├── auth.routes.ts
│   │   │   ├── game.routes.ts
│   │   │   └── leaderboard.routes.ts
│   │   │
│   │   └── swagger/
│   │       └── swagger.ts                 (documentación Swagger)
│   │
│   ├── config/
│   │   ├── env.ts                         (variables de entorno)
│   │   └── database.ts
│   │
│   └── main.ts                        (punto de entrada)
│
├── __tests__/
│   ├── unit/
│   │   ├── use-cases/
│   │   └── repositories/
│   ├── integration/
│   │   ├── auth.integration.test.ts
│   │   └── scores.integration.test.ts
│   └── e2e/
│       └── game-flow.e2e.test.ts
│
├── docs/
│   ├── API.md                         (documentación de endpoints)
│   ├── ARCHITECTURE.md
│   └── DATABASE-SCHEMA.md
│
├── package.json
├── tsconfig.json
├── jest.config.js
├── .env.example
└── README.md
```

---

## 4. CÓMO IMPLEMENTAR CLEAN ARCHITECTURE

### 4.1 Flujo de una acción del usuario

**Ejemplo: Usuario clickea flecha para rotar**

```typescript
// 1. PRESENTACIÓN (React Component)
// presentation/components/CellComponent.tsx
export const CellComponent = ({ cell, onCellClick }) => {
  const handleClick = () => {
    onCellClick(cell.position);  // ← Delega a hook
  };
  return <button onClick={handleClick}>{cell.arrow}</button>;
};

// 2. HOOK (conecta UI con casos de uso)
// presentation/hooks/useGame.ts
export const useGame = () => {
  const [board, setBoard] = useState<Board>();
  
  const movePlayer = async (position: Position) => {
    // Instancia caso de uso (o inyecta)
    const useCase = new MovePlayerUseCase(boardRepository);
    
    // Ejecuta lógica pura
    const result = useCase.execute({ board, position });
    
    // Actualiza estado React
    setBoard(result.newBoard);
    
    // Si hay cambios, sincroniza con servidor
    if (result.changed) {
      await syncProgressUseCase.execute(result);
    }
  };
  
  return { board, movePlayer };
};

// 3. CASO DE USO (Lógica de aplicación)
// application/use-cases/MovePlayerUseCase.ts
export class MovePlayerUseCase {
  constructor(
    private boardRepository: IBoardRepository,
    private pathChecker: PathChecker
  ) {}
  
  execute(input: MovePlayerInput): MovePlayerOutput {
    const { board, position } = input;
    
    // Obtiene celda
    const cell = board.getCell(position);
    
    // Rota flecha
    const rotatedCell = cell.rotate();
    
    // Actualiza board
    const newBoard = board.updateCell(position, rotatedCell);
    
    // Valida si hay victoria
    const isVictory = this.pathChecker.canReachExit(newBoard);
    
    return {
      newBoard,
      isVictory,
      changed: true
    };
  }
}

// 4. ENTIDADES (Lógica pura, sin dependencias externas)
// domain/entities/Board.ts
export class Board {
  constructor(
    private cells: Cell[][],
    private width: number,
    private height: number
  ) {}
  
  getCell(position: Position): Cell {
    return this.cells[position.y][position.x];
  }
  
  updateCell(position: Position, cell: Cell): Board {
    const newCells = [...this.cells];
    newCells[position.y][position.x] = cell;
    return new Board(newCells, this.width, this.height);
  }
}

// domain/entities/Cell.ts
export class Cell {
  constructor(
    private arrow: Direction,
    private position: Position
  ) {}
  
  rotate(): Cell {
    const nextDirection = this.arrow.rotateClockwise();
    return new Cell(nextDirection, this.position);
  }
}
```

### 4.2 Regla de dependencia

```
        ┌─────────────────────────┐
        │   Presentación (React)  │
        │    ↓ depende de ↓       │
        ├─────────────────────────┤
        │   Application           │
        │   (Use Cases)           │
        │    ↓ depende de ↓       │
        ├─────────────────────────┤
        │   Adapters              │
        │   (Repositories)        │
        │    ↓ depende de ↓       │
        ├─────────────────────────┤
        │   Domain                │
        │   (Entities - puras)    │
        │   ✓ NUNCA DEPENDE      │
        │     DE NADA             │
        └─────────────────────────┘

SIEMPRE apunta hacia adentro ↓
NUNCA hacia afuera ↑
```

---

## 5. INYECCIÓN DE DEPENDENCIAS (TypeScript)

### Opción A: Manual (simple, sin librerías)

```typescript
// infrastructure/di/DIContainer.ts
export class DIContainer {
  private dependencies: Map<string, any> = new Map();
  
  register(key: string, factory: () => any) {
    this.dependencies.set(key, factory);
  }
  
  resolve(key: string) {
    const factory = this.dependencies.get(key);
    if (!factory) throw new Error(`Dependency ${key} not found`);
    return factory();
  }
}

// App.tsx
const container = new DIContainer();

// Registra repos
container.register('levelRepository', () => 
  new LocalLevelRepository()
);
container.register('scoreRepository', () =>
  new ApiScoreRepository()
);

// Registra casos de uso
container.register('movePlayerUseCase', () =>
  new MovePlayerUseCase(
    container.resolve('boardRepository'),
    new PathChecker()
  )
);

// En componente
const GameScreen = () => {
  const movePlayerUseCase = container.resolve('movePlayerUseCase');
  // ...
};
```

### Opción B: Con librería (inversify)

```typescript
// Para equipos más avanzados, pero no necesaria
import { Container, inject, injectable } from 'inversify';

@injectable()
export class MovePlayerUseCase {
  constructor(
    @inject('BoardRepository') private repo: IBoardRepository
  ) {}
}
```

---

## 6. TESTING (Jest + TypeScript)

### Unit test: Entidad pura

```typescript
// __tests__/domain/Board.test.ts
describe('Board', () => {
  it('should update cell when getCell called', () => {
    // Arrange
    const board = new Board(3, 3);
    const newCell = new Cell(Direction.RIGHT);
    
    // Act
    const updatedBoard = board.updateCell(new Position(0, 0), newCell);
    
    // Assert
    expect(updatedBoard.getCell(new Position(0, 0))).toBe(newCell);
  });
});

// ✓ Rápido (<10ms)
// ✓ Sin dependencias externas
// ✓ Sin emulador
```

### Test: Caso de uso (con mock)

```typescript
// __tests__/application/MovePlayerUseCase.test.ts
describe('MovePlayerUseCase', () => {
  it('should detect victory when player reaches exit', () => {
    // Arrange
    const mockPathChecker = {
      canReachExit: jest.fn().mockReturnValue(true)
    };
    const useCase = new MovePlayerUseCase(
      null,  // no necesita repo en este test
      mockPathChecker
    );
    
    // Act
    const result = useCase.execute({ board, position });
    
    // Assert
    expect(result.isVictory).toBe(true);
  });
});

// ✓ Prueba lógica sin UI
// ✓ Sin servidor
// ✓ Sin BD
```

### Test: React Component

```typescript
// __tests__/presentation/GameScreen.test.tsx
describe('GameScreen', () => {
  it('should render board after loading level', async () => {
    // Arrange
    const mockUseCase = {
      execute: jest.fn().mockResolvedValue({
        board: new Board(3, 3)
      })
    };
    
    // Act
    render(
      <GameScreen loadLevelUseCase={mockUseCase} />
    );
    
    // Assert
    await waitFor(() => {
      expect(screen.getByTestId('board')).toBeInTheDocument();
    });
  });
});
```

---

## 7. CONFIGURACIÓN INICIAL (Paso a paso)

### Frontend

```bash
# 1. Crear proyecto Vite + React
npm create vite@latest arrow-maze-client -- --template react-ts
cd arrow-maze-client

# 2. Instalar dependencias
npm install
npm install axios                    # HTTP client
npm install zustand                 # State management (alternativa a Context)

# 3. Instalar Capacitor
npm install @capacitor/core @capacitor/cli
npx cap init

# 4. Agregar plataformas
npx cap add android
npx cap add ios

# 5. Instalar dev dependencies
npm install -D jest @testing-library/react @testing-library/jest-dom
npm install -D ts-jest

# 6. Crear estructura de carpetas
mkdir -p src/domain/{entities,value-objects,events,services}
mkdir -p src/application/{ports,use-cases,dtos,managers}
mkdir -p src/data/{repositories,datasources,mappers,models}
mkdir -p src/presentation/{screens,components,hooks,context}
mkdir -p src/infrastructure/{config,services,aop,di}

# 7. Iniciar desarrollo
npm run dev
```

### Backend

```bash
# 1. Crear proyecto Node + Express
mkdir arrow-maze-backend
cd arrow-maze-backend
npm init -y

# 2. Instalar dependencias
npm install express typescript ts-node cors dotenv
npm install jsonwebtoken bcryptjs pg         # Autenticación + BD

# 3. Dev dependencies
npm install -D @types/express @types/node
npm install -D jest ts-jest supertest

# 4. Crear estructura
mkdir -p src/domain/{entities,value-objects,events}
mkdir -p src/application/{ports,use-cases,dtos}
mkdir -p src/adapters/{controllers,repositories,mappers}
mkdir -p src/infrastructure/{database,auth,aop,middleware,routes}

# 5. Iniciar desarrollo
npx ts-node src/main.ts
```

---

## 8. PRIMER SPRINT (Semana 1-2)

### Tareas frontend

```typescript
// 1. Crear entidad Board
// src/domain/entities/Board.ts
export class Board {
  // minimalista: solo what's needed
}

// 2. Test unitario
// __tests__/domain/Board.test.ts
describe('Board', () => {
  // tests aquí
});

// 3. Caso de uso básico
// src/application/use-cases/MovePlayerUseCase.ts

// 4. Componente React mínimo
// src/presentation/screens/GameScreen.tsx

// 5. Hook que lo une
// src/presentation/hooks/useGame.ts
```

### Tareas backend

```typescript
// 1. Entidad User
// src/domain/entities/User.ts

// 2. Caso de uso autenticación
// src/application/use-cases/AuthenticateUserUseCase.ts

// 3. Controlador
// src/adapters/controllers/AuthController.ts

// 4. Ruta
// src/infrastructure/routes/auth.routes.ts

// 5. Test
// __tests__/auth.integration.test.ts
```
