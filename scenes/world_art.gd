extends Node2D
## Prototype 00B: actual PNG atlas sprites and Godot TileMapLayer terrain.
## View/sprite animations are driven by the existing deterministic demo state.

const TERRAIN = preload("res://assets/terrain.png")
const OBJECTS = preload("res://assets/objects.png")
const BODIES = preload("res://assets/characters.png")
const EQUIPMENT = preload("res://assets/equipment.png")

const OBJECT_FRAMES = {
	"cottage": Rect2(0, 0, 88, 80),
	"storage": Rect2(96, 0, 80, 80),
	"forge": Rect2(192, 0, 112, 80),
	"cave_mouth": Rect2(320, 0, 96, 80),
	"tree": Rect2(432, 0, 64, 80),
	"blueprint": Rect2(0, 96, 96, 64),
	"built_hut": Rect2(112, 96, 96, 64),
	"well": Rect2(224, 96, 48, 48),
	"bush": Rect2(280, 96, 32, 32),
	"crate": Rect2(320, 96, 32, 32),
	"torch": Rect2(360, 96, 24, 40),
	"mushrooms": Rect2(392, 96, 32, 32),
	"crystal": Rect2(432, 96, 48, 48),
	"slime": Rect2(0, 176, 40, 32),
	"farm": Rect2(80, 176, 96, 64),
	"wagon": Rect2(184, 176, 64, 48),
	"fence": Rect2(256, 176, 64, 32),
	"bridge": Rect2(328, 176, 80, 64),
	"rocks": Rect2(416, 176, 48, 40),
	"flowers": Rect2(472, 176, 32, 32),
}
const TILE := Vector2i(16, 16)
const WIDTH := 72
const HEIGHT := 42
var village: Node2D
var cave: Node2D
var worker: Sprite2D
var guard: Sprite2D
var guard_gear: Sprite2D
var dungeon_guard: Sprite2D
var dungeon_gear: Sprite2D
var enemy: Sprite2D
var plot: Sprite2D
var material_icon: Sprite2D
var _last_completed: bool = false
var _world_seed: int = 1729

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	village = Node2D.new()
	village.name = "Village"
	village.y_sort_enabled = true
	add_child(village)
	cave = Node2D.new()
	cave.name = "Cave"
	cave.y_sort_enabled = true
	add_child(cave)
	_make_tiles(village, false)
	_make_tiles(cave, true)
	_make_village_objects()
	_make_cave_objects()

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

func _object(parent: Node2D, kind: String, foot: Vector2) -> Sprite2D:
	var rect: Rect2 = OBJECT_FRAMES[kind]
	var s := Sprite2D.new()
	s.name = kind.capitalize()
	s.texture = _atlas_region(OBJECTS, rect)
	s.centered = false
	s.offset = Vector2(-rect.size.x / 2.0, -rect.size.y)
	s.position = foot
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(s)
	return s

func _make_tiles(parent: Node2D, underground: bool) -> void:
	var set := TileSet.new()
	set.tile_size = TILE
	var atlas := TileSetAtlasSource.new()
	atlas.texture = TERRAIN
	atlas.texture_region_size = TILE
	for y in range(4):
		for x in range(16):
			atlas.create_tile(Vector2i(x, y))
	var source_id: int = set.add_source(atlas)
	var ground := TileMapLayer.new()
	ground.name = "CaveTiles" if underground else "VillageTiles"
	ground.tile_set = set
	ground.y_sort_enabled = false
	ground.z_index = -10
	parent.add_child(ground)
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var seed: int = _hash(x,y,1 if underground else 0)
			var cell: Vector2i
			if underground:
				# Irregular exposed rock on both cavern sides, with a clear
				# central floor where the actual encounter happens.
				var north: int = 13 + _hash(x,3,45) % 3
				var south: int = 33 - _hash(x,9,51) % 3
				var wall: bool = (y < north or y > south or x < 3 or x > WIDTH-4)
				cell = Vector2i(seed % 8,3 if wall else 2)
				if not wall and x > 19 and x < 53 and abs(y-22) < 3:
					cell = Vector2i(8 + seed % 8,2)
			else:
				cell = Vector2i(seed % 8,0)
				if _is_road(x,y):
					var up: bool = _is_road(x,y-1)
					var down: bool = _is_road(x,y+1)
					var left: bool = _is_road(x-1,y)
					var right: bool = _is_road(x+1,y)
					if not up and not left:
						cell = Vector2i(13,0)
					elif not up and not right:
						cell = Vector2i(14,0)
					elif not down and not right:
						cell = Vector2i(15,0)
					elif not up:
						cell = Vector2i(9,0)
					elif not down:
						cell = Vector2i(10,0)
					elif not left:
						cell = Vector2i(11,0)
					elif not right:
						cell = Vector2i(12,0)
					else:
						cell = Vector2i(8,0)
				if y >= 30 and y <= 36:
					cell = Vector2i(8 + seed % 8,1)
				if y >= 30 and y <= 36 and x >= 32 and x <= 36:
					cell = Vector2i(seed % 8,1)
			ground.set_cell(Vector2i(x,y), source_id, cell)

func _is_road(x:int,y:int) -> bool:
	var lane: int = 22 + roundi(sin(float(x) * 0.16) * 0.8)
	if abs(y-lane) <= 1:
		return true
	for branch_x in [13,24,38,58]:
		if abs(x-branch_x) <= 1 and y >= 16 and y <= lane:
			return true
	return false

func _make_village_objects() -> void:
	# Props are actual reuse of a single sprite atlas, not rect commands.
	for point in [Vector2(73,309),Vector2(278,270),Vector2(499,271),Vector2(800,267),Vector2(1050,298),Vector2(124,443),Vector2(1033,451)]:
		_object(village,"tree",point)
	_object(village,"cottage",Vector2(207,335))
	_object(village,"storage",Vector2(386,334))
	_object(village,"forge",Vector2(613,336))
	_object(village,"cave_mouth",Vector2(935,343))
	_object(village,"well",Vector2(489,433))
	_object(village,"farm",Vector2(230,459))
	_object(village,"farm",Vector2(954,455))
	_object(village,"wagon",Vector2(529,377))
	_object(village,"bridge",Vector2(550,565))
	for p in [Vector2(302,463),Vector2(855,458)]:
		_object(village,"fence",p)
	for p in [Vector2(672,443),Vector2(1034,403)]:
		_object(village,"rocks",p)
	for p in [Vector2(162,430),Vector2(293,420),Vector2(777,443)]:
		_object(village,"flowers",p)
	for p in [Vector2(286,430),Vector2(309,451),Vector2(844,429),Vector2(866,440),Vector2(985,440)]:
		_object(village,"bush",p)
	for p in [Vector2(336,357),Vector2(348,359),Vector2(644,345)]:
		_object(village,"crate",p)
	for p in [Vector2(555,341),Vector2(829,348)]:
		_object(village,"torch",p)
	plot = _object(village,"blueprint",Vector2(730,371))
	material_icon = _object(village,"crate",Vector2(692,370))
	worker = _character(village, "Worker")
	guard = _character(village, "Guard")
	guard_gear = _gear(village, "GuardEquipment")
	guard.position = Vector2(825,374)
	guard_gear.position = guard.position

func _make_cave_objects() -> void:
	for p in [Vector2(219,330),Vector2(455,276),Vector2(902,340),Vector2(980,451)]:
		_object(cave,"crystal",p)
	for p in [Vector2(307,438),Vector2(392,289),Vector2(796,448),Vector2(871,366)]:
		_object(cave,"mushrooms",p)
	for p in [Vector2(312,289),Vector2(490,267),Vector2(860,271),Vector2(956,335)]:
		_object(cave,"torch",p)
	for p in [Vector2(291,322),Vector2(467,318),Vector2(823,331),Vector2(1012,445)]:
		_object(cave,"rocks",p)
	dungeon_guard = _character(cave, "ExpeditionGuard")
	dungeon_gear = _gear(cave, "ExpeditionEquipment")
	dungeon_guard.position = Vector2(606,371)
	dungeon_gear.position = dungeon_guard.position
	enemy = _object(cave,"slime",Vector2(697,371))

func _character(parent: Node2D, node_name: String) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = node_name
	s.texture = BODIES
	s.region_enabled = true
	s.region_rect = Rect2(0,0,24,32)
	s.centered = false
	s.offset = Vector2(-12,-31)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(s)
	return s

func _gear(parent: Node2D, node_name: String) -> Sprite2D:
	var s := _character(parent,node_name)
	s.texture = EQUIPMENT
	return s

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
	_frame(dungeon_guard,4,attack_frame,size_choice)
	_frame(dungeon_gear,0,attack_frame,size_choice)
	enemy.modulate = Color("#f4b2ae") if sim.combat_elapsed < 0.22 else Color.WHITE
	enemy.position.y = 371.0 + sin(sim.elapsed * 3.0) * 2.0
	material_icon.visible = sim.delivered_wood > 0 and not sim.building_complete
	if sim.building_complete != _last_completed:
		plot.texture = _atlas_region(OBJECTS,OBJECT_FRAMES["built_hut"] if sim.building_complete else OBJECT_FRAMES["blueprint"])
		_last_completed = sim.building_complete
