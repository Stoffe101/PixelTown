extends RefCounted
## Deterministic tiny demonstration simulation for visual prototype 00.
## This is intentionally NOT the final construction, economy, or combat model.

const WALK_SPEED := 68.0
const DEFAULT_STORAGE := Vector2(362, 352)
const DEFAULT_PLOT := Vector2(731, 370)
var storage_point: Vector2 = DEFAULT_STORAGE
var plot_point: Vector2 = DEFAULT_PLOT
const START_WOOD := 3

var worker_pos: Vector2 = DEFAULT_STORAGE
var worker_state: String = "gather"
var activity_time: float = 0.0
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

func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	elapsed += delta
	# In this proof the village and cave logic update irrespective of active view.
	if not building_complete:
		if worker_state == "collect":
			worker_state = "gather"
			activity_time = 0.0
		elif worker_state == "gather":
			activity_time += delta
			if activity_time >= 0.55:
				if storage_wood > 0:
					storage_wood -= 1
					carried_wood = 1
					worker_state = "deliver"
				else:
					worker_state = "idle"
		elif worker_state == "deliver":
			worker_pos = worker_pos.move_toward(plot_point, WALK_SPEED * delta)
			if worker_pos.distance_to(plot_point) < 0.05:
				activity_time = 0.0
				worker_state = "build"
		elif worker_state == "build":
			activity_time += delta
			if activity_time >= 0.5:
				delivered_wood += carried_wood
				carried_wood = 0
				if delivered_wood >= START_WOOD:
					building_complete = true
					worker_state = "idle"
				else:
					worker_state = "return"
		elif worker_state == "return":
			worker_pos = worker_pos.move_toward(storage_point, WALK_SPEED * delta)
			if worker_pos.distance_to(storage_point) < 0.05:
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
	if worker_state == "gather" or worker_state == "collect":
		return "Gathering wood"
	if worker_state == "build":
		return "Working on the watch hut"
	return "Standing by"
