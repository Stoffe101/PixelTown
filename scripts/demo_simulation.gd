extends RefCounted
## Deterministic tiny demonstration simulation for visual prototype 00.
## This is intentionally NOT the final construction, economy, or combat model.

const WALK_SPEED := 68.0
const STORAGE := Vector2(362, 352)
const PLOT := Vector2(731, 370)
const START_WOOD := 3

var worker_pos: Vector2 = STORAGE
var worker_state: String = "collect"
var storage_wood: int = START_WOOD
var carried_wood: int = 0
var delivered_wood: int = 0
var building_complete: bool = false
var elapsed: float = 0.0
var combat_elapsed: float = 0.0
var enemy_hp: int = 5
var enemy_hits: int = 0
var expedition_loot: int = 0

func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	elapsed += delta
	# In this proof the village and cave logic update irrespective of active view.
	if not building_complete:
		if worker_state == "collect":
			if storage_wood > 0:
				storage_wood -= 1
				carried_wood = 1
				worker_state = "deliver"
			else:
				worker_state = "idle"
		elif worker_state == "deliver":
			worker_pos = worker_pos.move_toward(PLOT, WALK_SPEED * delta)
			if worker_pos.distance_to(PLOT) < 0.05:
				delivered_wood += carried_wood
				carried_wood = 0
				if delivered_wood >= START_WOOD:
					building_complete = true
					worker_state = "idle"
				else:
					worker_state = "return"
		elif worker_state == "return":
			worker_pos = worker_pos.move_toward(STORAGE, WALK_SPEED * delta)
			if worker_pos.distance_to(STORAGE) < 0.05:
				worker_state = "collect"
	# Cave simulation continues while village is being displayed.
	combat_elapsed += delta
	if combat_elapsed >= 2.4:
		combat_elapsed -= 2.4
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
	if worker_state == "deliver":
		return "Hauling wood to blueprint"
	if worker_state == "return":
		return "Returning to storage"
	if worker_state == "collect":
		return "Collecting wood"
	return "Standing by"
