---
name: game-dev-master
description: Build games using proven architecture patterns and optimization techniques. Covers game loops, ECS, physics, AI, asset management, rendering, and game design patterns.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: game-dev
  category: game-dev
---

# Game Dev Master

## What I Do

I help build well-architected games using proven patterns and optimization techniques. I ensure smooth performance, clean code organization, and scalable game systems.

## Game Loop

### Fixed Timestep
```typescript
// Consistent physics, variable rendering
const FIXED_DT = 1 / 60; // 60 Hz physics
let accumulator = 0;
let lastTime = performance.now();

function gameLoop(currentTime: number) {
  const frameTime = Math.min((currentTime - lastTime) / 1000, 0.25); // Cap at 250ms
  lastTime = currentTime;
  accumulator += frameTime;

  // Fixed timestep updates (physics, game logic)
  while (accumulator >= FIXED_DT) {
    update(FIXED_DT);
    accumulator -= FIXED_DT;
  }

  // Render with interpolation
  const alpha = accumulator / FIXED_DT;
  render(alpha);

  requestAnimationFrame(gameLoop);
}

requestAnimationFrame(gameLoop);
```

### Variable Timestep
```typescript
let lastTime = performance.now();

function gameLoop(currentTime: number) {
  const dt = Math.min((currentTime - lastTime) / 1000, 0.1);
  lastTime = currentTime;

  update(dt);
  render(1);

  requestAnimationFrame(gameLoop);
}
```

### When to Use Which
| Pattern | Pros | Cons | Use For |
|---------|------|------|---------|
| Fixed Timestep | Deterministic, stable physics | Can spiral of death, input lag | Physics-heavy games |
| Variable Timestep | Simple, no lag | Non-deterministic, physics issues | Simple games, UI-heavy |
| Semi-Fixed | Compromise, capped dt | Still some variability | Most games |

## Entity Component System (ECS)

### Architecture
```
Entities:    Just IDs (no data, no behavior)
Components:  Pure data (no behavior)
Systems:     Pure behavior (no data)

┌─────────────────────────────────────────────────┐
│                    World                        │
├──────────┬──────────────────┬───────────────────┤
│ Entities │   Components     │     Systems       │
│          │                  │                   │
│ #1       │ Position: {x,y}  │ MovementSystem    │
│ #2       │ Velocity: {x,y}  │   → queries:      │
│ #3       │ Health: {hp}     │     Position +    │
│ #4       │ Sprite: {img}    │     Velocity      │
│          │                  │                   │
│          │                  │ RenderSystem      │
│          │                  │   → queries:      │
│          │                  │     Position +    │
│          │                  │     Sprite        │
└──────────┴──────────────────┴───────────────────┘
```

### Implementation
```typescript
class World {
  private entities = new Map<number, Map<string, any>>();
  private systems: System[] = [];
  private nextId = 1;

  createEntity(components: Record<string, any>): number {
    const id = this.nextId++;
    this.entities.set(id, new Map(Object.entries(components)));
    return id;
  }

  query(...componentTypes: string[]): number[] {
    const results: number[] = [];
    for (const [id, components] of this.entities) {
      if (componentTypes.every(type => components.has(type))) {
        results.push(id);
      }
    }
    return results;
  }

  update(dt: number) {
    for (const system of this.systems) {
      system.update(this, dt);
    }
  }
}

abstract class System {
  abstract update(world: World, dt: number): void;
}

class MovementSystem extends System {
  update(world: World, dt: number) {
    const entities = world.query('position', 'velocity');
    for (const id of entities) {
      const pos = world.getComponent(id, 'position');
      const vel = world.getComponent(id, 'velocity');
      pos.x += vel.x * dt;
      pos.y += vel.y * dt;
    }
  }
}

class RenderSystem extends System {
  update(world: World, dt: number) {
    const entities = world.query('position', 'sprite');
    for (const id of entities) {
      const pos = world.getComponent(id, 'position');
      const sprite = world.getComponent(id, 'sprite');
      ctx.drawImage(sprite.image, pos.x, pos.y);
    }
  }
}
```

### ECS Benefits
- Cache-friendly (data-oriented, contiguous memory)
- Easy to add/remove behavior
- No deep inheritance hierarchies
- Parallel system execution
- Serialization is trivial

## Physics

### Collision Detection
```typescript
// AABB (Axis-Aligned Bounding Box)
function aabbCollision(a: AABB, b: AABB): boolean {
  return (
    a.min.x <= b.max.x && a.max.x >= b.min.x &&
    a.min.y <= b.max.y && a.max.y >= b.min.y
  );
}

// Circle collision
function circleCollision(a: Circle, b: Circle): boolean {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  const distSq = dx * dx + dy * dy;
  const radiusSum = a.radius + b.radius;
  return distSq <= radiusSum * radiusSum;
}

// SAT (Separating Axis Theorem) for convex polygons
function satCollision(polyA: Polygon, polyB: Polygon): boolean {
  const axes = [...polyA.getAxes(), ...polyB.getAxes()];
  
  for (const axis of axes) {
    const projA = polyA.project(axis);
    const projB = polyB.project(axis);
    
    if (projA.max < projB.min || projB.max < projA.min) {
      return false; // Found separating axis
    }
  }
  return true;
}
```

### Collision Response
```typescript
function resolveCollision(a: RigidBody, b: RigidBody, collision: Collision) {
  const { normal, depth } = collision;
  
  // Positional correction (prevent sinking)
  const percent = 0.8; // Penetration percentage to correct
  const slop = 0.01;   // Penetration allowance
  const correctionMag = Math.max(depth - slop, 0) / (1/a.mass + 1/b.mass) * percent;
  const correction = normal.scale(correctionMag);
  
  a.position = a.position.subtract(correction.scale(1 / a.mass));
  b.position = b.position.add(correction.scale(1 / b.mass));
  
  // Relative velocity
  const relVel = a.velocity.subtract(b.velocity);
  const velAlongNormal = relVel.dot(normal);
  
  if (velAlongNormal > 0) return; // Moving apart
  
  // Impulse scalar
  const e = Math.min(a.restitution, b.restitution);
  let j = -(1 + e) * velAlongNormal;
  j /= 1/a.mass + 1/b.mass;
  
  // Apply impulse
  const impulse = normal.scale(j);
  a.velocity = a.velocity.add(impulse.scale(1 / a.mass));
  b.velocity = b.velocity.subtract(impulse.scale(1 / b.mass));
}
```

### Spatial Partitioning
```typescript
// Grid-based spatial hash
class SpatialGrid {
  private cells = new Map<string, Set<Entity>>();
  private cellSize: number;

  constructor(cellSize: number) {
    this.cellSize = cellSize;
  }

  insert(entity: Entity, x: number, y: number) {
    const key = this.getKey(x, y);
    if (!this.cells.has(key)) this.cells.set(key, new Set());
    this.cells.get(key)!.add(entity);
  }

  query(x: number, y: number, radius: number): Entity[] {
    const results = new Set<Entity>();
    const minCell = this.getKey(x - radius, y - radius);
    const maxCell = this.getKey(x + radius, y + radius);
    
    for (const [key, entities] of this.cells) {
      if (key >= minCell && key <= maxCell) {
        for (const entity of entities) results.add(entity);
      }
    }
    return Array.from(results);
  }

  private getKey(x: number, y: number): string {
    const cx = Math.floor(x / this.cellSize);
    const cy = Math.floor(y / this.cellSize);
    return `${cx},${cy}`;
  }
}

// Quadtree for 2D space
class Quadtree {
  private MAX_OBJECTS = 10;
  private MAX_LEVELS = 5;
  
  constructor(private level: number, private bounds: Rect, private objects: Entity[] = []) {}
  
  split() {
    const subWidth = this.bounds.width / 2;
    const subHeight = this.bounds.height / 2;
    const x = this.bounds.x;
    const y = this.bounds.y;
    
    this.nodes = [
      new Quadtree(this.level + 1, { x: x + subWidth, y, width: subWidth, height: subHeight }),
      new Quadtree(this.level + 1, { x, y, width: subWidth, height: subHeight }),
      new Quadtree(this.level + 1, { x, y: y + subHeight, width: subWidth, height: subHeight }),
      new Quadtree(this.level + 1, { x: x + subWidth, y: y + subHeight, width: subWidth, height: subHeight }),
    ];
  }
  
  retrieve(entity: Entity): Entity[] {
    const results = [...this.objects];
    if (this.nodes) {
      for (const node of this.nodes) {
        if (intersects(node.bounds, entity.bounds)) {
          results.push(...node.retrieve(entity));
        }
      }
    }
    return results;
  }
}
```

## Asset Management

### Asset Loader
```typescript
class AssetManager {
  private assets = new Map<string, any>();
  private loadingQueue = new Map<string, Promise<any>>();

  async loadTexture(id: string, src: string): Promise<Texture> {
    if (this.assets.has(id)) return this.assets.get(id);
    if (this.loadingQueue.has(id)) return this.loadingQueue.get(id);

    const promise = new Promise<Texture>((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        const texture = new Texture(img);
        this.assets.set(id, texture);
        this.loadingQueue.delete(id);
        resolve(texture);
      };
      img.onerror = reject;
      img.src = src;
    });

    this.loadingQueue.set(id, promise);
    return promise;
  }

  async loadAll(assets: { id: string; src: string }[]): Promise<void> {
    await Promise.all(assets.map(a => this.loadTexture(a.id, a.src)));
  }

  get<T>(id: string): T {
    const asset = this.assets.get(id);
    if (!asset) throw new Error(`Asset not loaded: ${id}`);
    return asset;
  }
}
```

### Object Pooling
```typescript
class ObjectPool<T> {
  private pool: T[] = [];
  private createFn: () => T;
  private resetFn: (obj: T) => void;

  constructor(size: number, createFn: () => T, resetFn: (obj: T) => void) {
    this.createFn = createFn;
    this.resetFn = resetFn;
    for (let i = 0; i < size; i++) {
      this.pool.push(createFn());
    }
  }

  acquire(): T {
    if (this.pool.length > 0) {
      return this.pool.pop()!;
    }
    return this.createFn();
  }

  release(obj: T) {
    this.resetFn(obj);
    this.pool.push(obj);
  }
}

// Usage: Bullet pooling
const bulletPool = new ObjectPool<Bullet>(
  100,
  () => new Bullet(),
  (b) => { b.active = false; b.x = 0; b.y = 0; b.vx = 0; b.vy = 0; }
);

function shoot(x: number, y: number, vx: number, vy: number) {
  const bullet = bulletPool.acquire();
  bullet.active = true;
  bullet.x = x;
  bullet.y = y;
  bullet.vx = vx;
  bullet.vy = vy;
}

function updateBullets(dt: number) {
  for (const bullet of activeBullets) {
    if (!bullet.active) continue;
    bullet.update(dt);
    if (bullet.outOfBounds()) {
      bulletPool.release(bullet);
    }
  }
}
```

## AI

### State Machine
```typescript
interface State {
  enter(entity: Entity): void;
  update(entity: Entity, dt: number): void;
  exit(entity: Entity): void;
}

class StateMachine {
  private states = new Map<string, State>();
  private currentState: State | null = null;
  private currentStateName: string | null = null;

  addState(name: string, state: State) {
    this.states.set(name, state);
  }

  setState(name: string) {
    if (this.currentState) this.currentState.exit(entity);
    this.currentStateName = name;
    this.currentState = this.states.get(name) || null;
    if (this.currentState) this.currentState.enter(entity);
  }

  update(entity: Entity, dt: number) {
    if (this.currentState) this.currentState.update(entity, dt);
  }
}

// Enemy AI states
const enemyStates = {
  patrol: {
    enter: (e) => { e.targetWaypoint = getNextWaypoint(e); },
    update: (e, dt) => {
      moveTo(e, e.targetWaypoint, dt);
      if (distanceTo(e, e.targetWaypoint) < 5) {
        e.targetWaypoint = getNextWaypoint(e);
      }
      if (canSeePlayer(e)) e.stateMachine.setState('chase');
    },
    exit: (e) => {},
  },
  chase: {
    enter: (e) => {},
    update: (e, dt) => {
      moveTo(e, player.position, dt);
      if (distanceTo(e, player.position) < attackRange) {
        e.stateMachine.setState('attack');
      }
      if (!canSeePlayer(e)) {
        e.stateMachine.setState('patrol');
      }
    },
    exit: (e) => {},
  },
  attack: {
    enter: (e) => { e.attackCooldown = 0; },
    update: (e, dt) => {
      e.attackCooldown -= dt;
      if (e.attackCooldown <= 0) {
        attack(e, player);
        e.attackCooldown = e.attackSpeed;
      }
      if (distanceTo(e, player.position) > attackRange * 1.5) {
        e.stateMachine.setState('chase');
      }
    },
    exit: (e) => {},
  },
};
```

### Behavior Trees
```typescript
type NodeStatus = 'success' | 'failure' | 'running';

interface BTNode {
  tick(context: BTContext): NodeStatus;
}

class Sequence implements BTNode {
  constructor(private children: BTNode[]) {}
  
  tick(context: BTContext): NodeStatus {
    for (const child of this.children) {
      const status = child.tick(context);
      if (status !== 'success') return status;
    }
    return 'success';
  }
}

class Selector implements BTNode {
  constructor(private children: BTNode[]) {}
  
  tick(context: BTContext): NodeStatus {
    for (const child of this.children) {
      const status = child.tick(context);
      if (status !== 'failure') return status;
    }
    return 'failure';
  }
}

// Enemy behavior tree
const enemyBT = new Selector([
  // Attack if in range
  new Sequence([
    new IsInAttackRange(),
    new AttackAction(),
  ]),
  // Chase if can see player
  new Sequence([
    new CanSeePlayer(),
    new MoveToTarget(player),
  ]),
  // Otherwise patrol
  new PatrolWaypoints(),
]);
```

### Pathfinding (A*)
```typescript
function aStar(grid: Grid, start: Point, end: Point): Point[] {
  const openSet = new PriorityQueue<Point, number>();
  const cameFrom = new Map<string, Point>();
  const gScore = new Map<string, number>();
  const fScore = new Map<string, number>();

  const startKey = `${start.x},${start.y}`;
  gScore.set(startKey, 0);
  fScore.set(startKey, heuristic(start, end));
  openSet.enqueue(start, 0);

  while (!openSet.isEmpty()) {
    const current = openSet.dequeue()!;
    const currentKey = `${current.x},${current.y}`;

    if (current.x === end.x && current.y === end.y) {
      return reconstructPath(cameFrom, current);
    }

    for (const neighbor of getNeighbors(grid, current)) {
      const neighborKey = `${neighbor.x},${neighbor.y}`;
      const tentativeG = (gScore.get(currentKey) || 0) + distance(current, neighbor);

      if (tentativeG < (gScore.get(neighborKey) ?? Infinity)) {
        cameFrom.set(neighborKey, current);
        gScore.set(neighborKey, tentativeG);
        fScore.set(neighborKey, tentativeG + heuristic(neighbor, end));
        openSet.enqueue(neighbor, fScore.get(neighborKey)!);
      }
    }
  }

  return []; // No path found
}

function heuristic(a: Point, b: Point): number {
  return Math.abs(a.x - b.x) + Math.abs(a.y - b.y); // Manhattan
}
```

## Audio

### Audio Manager
```typescript
class AudioManager {
  private sounds = new Map<string, AudioBuffer>();
  private masterGain: GainNode;
  private sfxGain: GainNode;
  private musicGain: GainNode;

  async load(id: string, src: string) {
    const response = await fetch(src);
    const arrayBuffer = await response.arrayBuffer();
    const audioBuffer = await this.ctx.decodeAudioData(arrayBuffer);
    this.sounds.set(id, audioBuffer);
  }

  playSFX(id: string, volume: number = 1) {
    const buffer = this.sounds.get(id);
    if (!buffer) return;
    
    const source = this.ctx.createBufferSource();
    source.buffer = buffer;
    source.connect(this.sfxGain);
    this.sfxGain.gain.value = volume;
    source.start();
  }

  playMusic(id: string, loop: boolean = true) {
    const buffer = this.sounds.get(id);
    if (!buffer) return;
    
    const source = this.ctx.createBufferSource();
    source.buffer = buffer;
    source.loop = loop;
    source.connect(this.musicGain);
    source.start();
    return source;
  }
}
```

## Optimization

### Profiling
```typescript
class Profiler {
  private marks = new Map<string, number>();

  begin(name: string) {
    this.marks.set(name, performance.now());
  }

  end(name: string): number {
    const start = this.marks.get(name);
    if (!start) return 0;
    const elapsed = performance.now() - start;
    console.log(`${name}: ${elapsed.toFixed(2)}ms`);
    return elapsed;
  }
}

// Frame budget: 16.67ms at 60fps
// Update:  < 5ms
// Physics: < 3ms
// Render:  < 8ms
// Audio:   < 1ms
// Buffer:  < 0.67ms
```

### Optimization Techniques
```
1. Object Pooling — Avoid GC spikes from allocation/deallocation
2. Spatial Partitioning — Reduce collision checks from O(n²) to O(n)
3. Dirty Flag — Only update changed systems
4. Level of Detail (LOD) — Reduce complexity at distance
5. Culling — Don't render off-screen objects
6. Texture Atlasing — Reduce draw calls
7. Batch Rendering — Combine draw calls
8. Fixed Time Step — Consistent physics, avoid spiral of death
9. Memory Pre-allocation — Allocate pools at load time
10. Profiling — Measure before optimizing
```

## Game Patterns

### Command Pattern
```typescript
interface Command {
  execute(): void;
  undo(): void;
}

class MoveCommand implements Command {
  constructor(
    private entity: Entity,
    private dx: number,
    private dy: number,
    private oldX: number = 0,
    private oldY: number = 0
  ) {}

  execute() {
    this.oldX = this.entity.x;
    this.oldY = this.entity.y;
    this.entity.x += this.dx;
    this.entity.y += this.dy;
  }

  undo() {
    this.entity.x = this.oldX;
    this.entity.y = this.oldY;
  }
}

// Input mapping
const inputMap = {
  'ArrowUp': () => new MoveCommand(player, 0, -1),
  'ArrowDown': () => new MoveCommand(player, 0, 1),
  'ArrowLeft': () => new MoveCommand(player, -1, 0),
  'ArrowRight': () => new MoveCommand(player, 1, 0),
};

// Command queue for replay/undo
const commandHistory: Command[] = [];

function executeCommand(command: Command) {
  command.execute();
  commandHistory.push(command);
}

function undo() {
  const last = commandHistory.pop();
  if (last) last.undo();
}
```

### Observer Pattern
```typescript
class EventEmitter {
  private listeners = new Map<string, Set<Function>>();

  on(event: string, callback: Function) {
    if (!this.listeners.has(event)) this.listeners.set(event, new Set());
    this.listeners.get(event)!.add(callback);
  }

  off(event: string, callback: Function) {
    this.listeners.get(event)?.delete(callback);
  }

  emit(event: string, ...args: any[]) {
    this.listeners.get(event)?.forEach(cb => cb(...args));
  }
}

// Usage
const events = new EventEmitter();

events.on('enemy.defeated', (enemy, score) => {
  ui.updateScore(score);
  achievements.check(enemy.type);
  particles.spawnExplosion(enemy.x, enemy.y);
});

events.emit('enemy.defeated', enemy, 100);
```

## When to Use Me

Use this skill when:
- Building game architecture and systems
- Implementing physics and collision
- Setting up AI behaviors
- Managing game assets
- Optimizing game performance
- Implementing game patterns
- Building rendering pipelines
- Designing input systems

## Quality Checklist

- [ ] Fixed timestep for physics
- [ ] Object pooling for frequently created/destroyed objects
- [ ] Spatial partitioning for collision detection
- [ ] Asset manager with loading states
- [ ] Frame rate profiling and optimization
- [ ] Input buffering for responsive controls
- [ ] Game state properly separated from rendering
- [ ] Audio manager with volume controls
- [ ] Save/load system implemented
- [ ] Debug rendering and tools available
