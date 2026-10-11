extends Node2D
## Prototype 00B: actual PNG atlas sprites and Godot TileMapLayer terrain.
## View/sprite animations are driven by the existing deterministic demo state.

const TERRAIN = preload("res://assets/terrain.png")
# CC0 art selected from Pixel-boy's Ninja Adventure; original art author separate
# from PixelTown's ARR source. See docs/10 and import_ninja_cc0.py.
const CC0_FLOOR = preload("res://assets/third_party/ninja_adventure/tileset_floor.png")
const CC0_INTERIOR = preload("res://assets/third_party/ninja_adventure/tileset_interior_floor.png")
const HERO_BUILD_SITE = preload("res://assets/original/hero/construction_site.png")
const HERO_WATCH_HUT = preload("res://assets/original/hero/watch_hut.png")
const VILLAGE_LAYOUT = preload("res://scenes/levels/village_layout.tscn")
const CAVE_LAYOUT = preload("res://scenes/levels/cave_layout.tscn")
const TILE := Vector2i(16, 16)
var village: Node2D
var cave: Node2D
var worker: Sprite2D
var guard: Sprite2D
var guard_gear: Sprite2D
var dungeon_guard: Sprite2D
var dungeon_gear: Sprite2D
var enemy: Sprite2D
var plot: Sprite2D
var carried_wood_icon: Sprite2D
var delivered_wood_icons: Array[Sprite2D] = []
var _last_completed: bool = false
var _world_seed: int = 1729

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	village = VILLAGE_LAYOUT.instantiate() as Node2D
	cave = CAVE_LAYOUT.instantiate() as Node2D
	village.y_sort_enabled = true
	cave.y_sort_enabled = true
	add_child(village)
	add_child(cave)
	_make_tiles(village, false)
	_make_tiles(cave, true)
	worker = village.get_node("Objects/Worker") as Sprite2D
	guard = village.get_node("Objects/Guard") as Sprite2D
	guard_gear = village.get_node("Objects/GuardEquipment") as Sprite2D
	dungeon_guard = cave.get_node("Objects/Guard") as Sprite2D
	dungeon_gear = cave.get_node("Objects/GuardEquipment") as Sprite2D
	enemy = cave.get_node("Objects/Slime") as Sprite2D
	plot = village.get_node("Objects/ConstructionSite") as Sprite2D
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

func _hash(x: int, y: int, salt: int = 0) -> int:
	var v: int = x * 769 + y * 2017 + salt * 89 + _world_seed
	v = v ^ (v << 13)
	v = v ^ (v >> 11)
	return absi(v) % 100

func _atlas_region(texture: Texture2D, r: Rect2) -> AtlasTexture:
	var out := AtlasTexture.new()
	out.atlas = texture
	out.region = r
	return out

func _make_tiles(parent: Node2D, underground: bool) -> void:
	var set := TileSet.new()
	set.tile_size = TILE

	# Both atlas sources are source-credited CC0 and authored at 16x16.
	# Do not create tiles for transparent/mismatched regions.
	var outdoors := TileSetAtlasSource.new()
	outdoors.texture = CC0_FLOOR
	outdoors.texture_region_size = TILE
	for y in range(7,14):
		for x in range(0,16):
			outdoors.create_tile(Vector2i(x,y))
	var grass_id: int = set.add_source(outdoors)
	var meadow := TileSetAtlasSource.new()
	meadow.texture = TERRAIN
	meadow.texture_region_size = TILE
	for x in range(16):
		meadow.create_tile(Vector2i(x,0))
	var meadow_id: int = set.add_source(meadow)

	var chamber := TileSetAtlasSource.new()
	chamber.texture = CC0_INTERIOR
	chamber.texture_region_size = TILE
	for y in range(6,16):
		for x in range(11,21):
			chamber.create_tile(Vector2i(x,y))
	var cave_id: int = set.add_source(chamber)

	var water := TileSetAtlasSource.new()
	water.texture = TERRAIN
	water.texture_region_size = TILE
	for x in range(8,16):
		water.create_tile(Vector2i(x,1))
	for x in range(8):
		water.create_tile(Vector2i(x,2))
	for x in range(8,16):
		water.create_tile(Vector2i(x,3))
	var water_id: int = set.add_source(water)

	var ground := TileMapLayer.new()
	ground.name = "CaveTiles" if underground else "VillageTiles"
	ground.tile_set = set
	ground.z_index = -10
	parent.add_child(ground)
	# Extend painted terrain beyond the authoring stage so ultrawide at a
	# finer two-pixel display scale never reveals a blank canvas edge.
	for y in range(-8,66):
		for x in range(-25,101):
			var variant: int = _hash(x,y,1 if underground else 0)
			var atlas_coord: Vector2i
			var source_id: int = grass_id
			if underground:
				# Dim slate stone, with an irregular cave-edge silhouette
				# instead of full-screen repeated blockwork.
				var side: bool = x < 8 or x > 63
				var top: bool = y < 11 + _hash(floori(float(x)/6.0),2,10)%3
				var bottom: bool = y > 33 - _hash(floori(float(x)/7.0),3,12)%3
				var wall: bool = side or top or bottom
				source_id = water_id
				atlas_coord = Vector2i(8+variant%8,3) if wall else Vector2i(variant%8,2)
				# Rare weathered architectural remains, not a decorative carpet.
				var fragment: bool = ((x >= 17 and x <= 19 and y >= 18 and y <= 21)
					or (x >= 54 and x <= 57 and y >= 28 and y <= 30))
				if fragment:
					source_id = cave_id
					atlas_coord = Vector2i(12+variant%3,13)
			else:
				# Calm original meadow cells replace dense repeating tufts.
				source_id = meadow_id
				atlas_coord = Vector2i(variant % 16,0)
				if _is_road(x,y):
					source_id = grass_id
					var top_open: bool = not _is_road(x,y-1)
					var bottom_open: bool = not _is_road(x,y+1)
					var left_open: bool = not _is_road(x-1,y)
					var right_open: bool = not _is_road(x+1,y)
					# Ninja Adventure's authored 3x3 dirt-edge/corner family.
					var atlas_x: int = 12 - int(left_open) + int(right_open)
					var atlas_y: int = 8 - int(top_open) + int(bottom_open)
					atlas_coord = Vector2i(atlas_x,atlas_y)
				var bank: int = 35 + int(round(sin(float(x) * 0.14)))
				if y >= bank:
					source_id = water_id
					atlas_coord = Vector2i(8 + variant % 8,1)
				# Raised timber bridge is a y-sorted object, but its actual
				# walkable underlying floor must remain land-colored.
				if x >= 32 and x <= 36 and y >= bank and y <= bank + 5:
					source_id = grass_id
					atlas_coord = Vector2i(12,8)
			ground.set_cell(Vector2i(x,y),source_id,atlas_coord)

func _is_road(x: int,y: int) -> bool:
	# Narrow routes approaching building fronts, not a flat three-tile-wide
	# band that continues *behind* the buildings.
	var main_y: int = 25 + roundi(sin(float(x)*0.17)*1.2)
	if x >= 8 and x <= 67 and y >= main_y and y <= main_y+1:
		return true
	for branch_x in [19,25,37,51]:
		var start_y: int = 21 if branch_x == 25 else 22
		if x == branch_x and y >= start_y and y <= main_y:
			return true
	# Connect the bridge without detached dead-end road rectangles.
	if x >= 33 and x <= 35 and y >= main_y and y <= 36:
		return true
	return false

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
	if sim.building_complete != _last_completed:
		plot.texture = HERO_WATCH_HUT if sim.building_complete else HERO_BUILD_SITE
		_last_completed = sim.building_complete
