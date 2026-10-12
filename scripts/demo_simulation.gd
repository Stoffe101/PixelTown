extends RefCounted
## Deterministic, state-driven delivery and encounter for the playable art prototype.
const WALK_SPEED := 68.0
const DEFAULT_STORAGE := Vector2(362, 352)
const DEFAULT_PLOT := Vector2(731, 370)
const START_WOOD := 3
const GATHER_TIME := 0.50
const BUILD_TIME := 0.70
const HIT_PERIOD := 2.4

var storage_point: Vector2 = DEFAULT_STORAGE
var plot_point: Vector2 = DEFAULT_PLOT
var worker_pos: Vector2 = DEFAULT_STORAGE
var worker_state: String = "gather"
var task_seconds: float = GATHER_TIME
var storage_wood: int = START_WOOD
var carried_wood: int = 0
var delivered_wood: int = 0
var building_complete: bool = false
var elapsed: float = 0.0
var combat_elapsed: float = 0.0
var enemy_hp: int = 5
var enemy_hits: int = 0
var expedition_loot: int = 0

func configure_locations(new_storage: Vector2, new_plot: Vector2) -> void:
    storage_point = new_storage
    plot_point = new_plot
    worker_pos = storage_point
    worker_state = "gather"
    task_seconds = GATHER_TIME

func advance(delta: float) -> void:
    if delta <= 0.0:
        return
    var remaining: float = delta
    while remaining > 0.00001:
        var step: float = minf(0.05, remaining)
        _advance_fixed(step)
        remaining -= step

func _advance_fixed(delta: float) -> void:
    elapsed += delta
    if not building_complete:
        match worker_state:
            "gather":
                task_seconds = maxf(0.0, task_seconds - delta)
                if task_seconds <= 0.0:
                    if storage_wood > 0:
                        storage_wood -= 1
                        carried_wood = 1
                        worker_state = "deliver"
                    else:
                        worker_state = "idle"
            "deliver":
                worker_pos = worker_pos.move_toward(plot_point, WALK_SPEED * delta)
                if worker_pos.distance_to(plot_point) < 0.05:
                    worker_state = "build"
                    task_seconds = BUILD_TIME
            "build":
                task_seconds = maxf(0.0, task_seconds - delta)
                if task_seconds <= 0.0:
                    delivered_wood += carried_wood
                    carried_wood = 0
                    if delivered_wood >= START_WOOD:
                        building_complete = true
                        worker_state = "idle"
                    else:
                        worker_state = "return"
            "return":
                worker_pos = worker_pos.move_toward(storage_point, WALK_SPEED * delta)
                if worker_pos.distance_to(storage_point) < 0.05:
                    worker_state = "gather"
                    task_seconds = GATHER_TIME
    var previous: float = combat_elapsed
    combat_elapsed = fmod(combat_elapsed + delta, HIT_PERIOD)
    if combat_elapsed < previous:
        enemy_hp -= 1
        enemy_hits += 1
        if enemy_hp <= 0:
            expedition_loot += 1
            enemy_hp = 5

func resources_conserved() -> bool:
    return storage_wood + carried_wood + delivered_wood == START_WOOD

func status() -> String:
    if building_complete:
        return "Completed: watch hut"
    match worker_state:
        "gather": return "Gathering wood"
        "deliver": return "Carrying wood to construction"
        "build": return "Working at construction"
        "return": return "Returning to storage"
    return "Standing by"
