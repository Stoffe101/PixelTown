extends Node2D
## Prototype 00B: actual PNG atlas sprites and Godot TileMapLayer terrain.
## View/sprite animations are driven by the existing deterministic demo state.

const VILLAGE_LAYOUT = preload("res://scenes/levels/village_layout.tscn")
const CAVE_LAYOUT = preload("res://scenes/levels/cave_layout.tscn")
var village: Node2D
var cave: Node2D
var worker: Sprite2D
var guard: Sprite2D
var guard_gear: Sprite2D
var dungeon_guard: Sprite2D
var dungeon_gear: Sprite2D
var enemy: Sprite2D
var plot: Sprite2D
var completed_hut: Sprite2D
var carried_wood_icon: Sprite2D
var delivered_wood_icons: Array[Sprite2D] = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	village = VILLAGE_LAYOUT.instantiate() as Node2D
	cave = CAVE_LAYOUT.instantiate() as Node2D
	village.y_sort_enabled = true
	cave.y_sort_enabled = true
	add_child(village)
	add_child(cave)
	# Guide backdrops are only visible in Godot's 2D editor; live terrain
	# comes from the underlying generated TileMapLayer + painted tiles.
	(village.get_node("EditorBackdrop") as CanvasItem).hide()
	(cave.get_node("EditorBackdrop") as CanvasItem).hide()
	worker = village.get_node("Objects/Worker") as Sprite2D
	guard = village.get_node("Objects/Guard") as Sprite2D
	guard_gear = village.get_node("Objects/GuardEquipment") as Sprite2D
	dungeon_guard = cave.get_node("Objects/Guard") as Sprite2D
	dungeon_gear = cave.get_node("Objects/GuardEquipment") as Sprite2D
	enemy = cave.get_node("Objects/Slime") as Sprite2D
	plot = village.get_node("Objects/ConstructionSite") as Sprite2D
	completed_hut = village.get_node("Objects/CompletedHut") as Sprite2D
	carried_wood_icon = village.get_node("Objects/CarriedWood") as Sprite2D
	for i in range(3):
		delivered_wood_icons.append(village.get_node("Objects/DeliveredWood%d" % (i+1)) as Sprite2D)

func _point(parent: Node2D, id: String) -> Vector2:
	return (parent.get_node("Markers/" + id) as Marker2D).position

func configure_sim(sim) -> void:
	# Layout edits in the Godot editor now control real world actions.
	sim.configure_locations(_point(village,"Storage"),plot.position)

func get_cave_entrance_position() -> Vector2:
	return _point(village,"CaveEntranceSpot")

func _frame(body: Sprite2D, row: int, frame: int, size_choice: int) -> void:
	body.region_rect = Rect2(24 * (size_choice * 8 + frame),32 * row,24,32)

func update_art(sim, show_cave: bool, size_choice: int) -> void:
	if village == null:
		return
	village.visible = not show_cave
	cave.visible = show_cave
	var anim: int = int(sim.elapsed * 4.0) % 4
	var movement: bool = sim.worker_state == "deliver" or sim.worker_state == "return"
	var worker_frame: int = anim if movement else (4 + anim % 2 if sim.worker_state == "collect" else 0)
	worker.position = sim.worker_pos
	var facing: int = 3 if sim.worker_state == "deliver" else 2 if sim.worker_state == "return" else 0
	_frame(worker, facing, worker_frame, size_choice)
	_frame(guard,4,0,size_choice)
	_frame(guard_gear,0,0,size_choice)
	var attack_frame: int = 6 + (anim % 2) if sim.combat_elapsed < 0.4 else 0
	dungeon_guard.position = _point(cave,"GuardPost")
	dungeon_gear.position = dungeon_guard.position
	guard.position = _point(village,"GuardPost")
	guard_gear.position = guard.position
	_frame(dungeon_guard,4,attack_frame,size_choice)
	_frame(dungeon_gear,0,attack_frame,size_choice)
	enemy.modulate = Color("#f4b2ae") if sim.combat_elapsed < 0.22 else Color.WHITE
	enemy.position = _point(cave, "EnemySpawn") + Vector2(0.0, sin(sim.elapsed * 3.0) * 2.0)
	# The visual cargo is not a looping animation: it follows the actual
	# conserved material ledger in the demonstration simulation.
	carried_wood_icon.visible = sim.carried_wood > 0
	carried_wood_icon.position = sim.worker_pos + Vector2(0,-18)
	for i in range(delivered_wood_icons.size()):
		delivered_wood_icons[i].position = plot.position + Vector2(-29.0 + float(i)*19.0,5.0)
		delivered_wood_icons[i].visible = i < sim.delivered_wood and not sim.building_complete
	# Artwork is owned by the Godot scene, not preloaded/hard-coded here.
	plot.visible = not sim.building_complete
	completed_hut.visible = sim.building_complete
	completed_hut.position = plot.position
