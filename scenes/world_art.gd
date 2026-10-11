extends Node2D
## Prototype 00B: actual PNG atlas sprites and Godot TileMapLayer terrain.
## View/sprite animations are driven by the existing deterministic demo state.

const TERRAIN = preload("res://assets/terrain.png")
# CC0 art selected from Pixel-boy's Ninja Adventure; original art author separate
# from PixelTown's ARR source. See docs/10 and import_ninja_cc0.py.
const CC0_FLOOR = preload("res://assets/third_party/ninja_adventure/tileset_floor.png")
const CC0_INTERIOR = preload("res://assets/third_party/ninja_adventure/tileset_interior_floor.png")
const CC0_VILLAGE = preload("res://assets/third_party/ninja_adventure/tileset_village_abandoned.png")
const CURATED_HOUSES = preload("res://assets/third_party/ninja_adventure/curated_houses.png")
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
# Authored compositions use two material atlases from one CC0 source family.
# Avoid mixing the less-detailed rectangle-drawn cottage/store/forge into the
# village while Art Gate A is under review.
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

	# Both atlas sources are source-credited CC0 and authored at 16x16.
	# Do not create tiles for transparent/mismatched regions.
	var outdoors := TileSetAtlasSource.new()
	outdoors.texture = CC0_FLOOR
	outdoors.texture_region_size = TILE
	for y in range(7,14):
		for x in range(0,16):
			outdoors.create_tile(Vector2i(x,y))
	var grass_id: int = set.add_source(outdoors)

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
	var water_id: int = set.add_source(water)

	var ground := TileMapLayer.new()
	ground.name = "CaveTiles" if underground else "VillageTiles"
	ground.tile_set = set
	ground.z_index = -10
	parent.add_child(ground)
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var variant: int = _hash(x,y,1 if underground else 0)
			var atlas_coord: Vector2i
			var source_id: int = grass_id
			if underground:
				source_id = cave_id
				# Chamber boundaries are spatially intentional: a low maze of
				# shadowed stone alcoves surrounds one uncluttered central room.
				var side: bool = x < 9 or x > 61
				var top: bool = y < 10 + _hash(int(x/5),2,10) % 3
				var bottom: bool = y > 34 - _hash(int(x/7),3,12) % 3
				var wall: bool = side or top or bottom
				if wall:
					atlas_coord = Vector2i(12 + variant % 3,12)
				else:
					atlas_coord = Vector2i(12 + (variant % 4), 13)
				# A deliberately paved encounter island, not a random room-wide
				# stripe; darker bounds and a simple middle medallion.
				var center: bool = x >= 29 and x <= 45 and y >= 18 and y <= 27
				if center:
					atlas_coord = Vector2i(14 + variant % 3, 8)
				if x >= 35 and x <= 38 and y >= 21 and y <= 24:
					atlas_coord = Vector2i(16 + variant % 2, 8)
			else:
				# Quiet foliage tones; avoid full-screen chartreuse noise.
				atlas_coord = Vector2i(11 + (variant % 3 if variant < 20 else 1),12)
				if _is_road(x,y):
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
	# A winding path with three short building-spur connections and a lower
	# garden walk. No straight full-width 48px brick strip.
	var main_y: int = 24 + roundi(sin(float(x)*0.17)*1.2)
	if x >= 8 and x <= 67 and abs(y-main_y) <= 1:
		return true
	for branch_x in [14,24,39,58]:
		if abs(x-branch_x) <= 1 and y >= 18 and y <= main_y:
			return true
	var south_walk: int = 30 + roundi(sin(float(x)*0.15)*0.9)
	if x >= 9 and x <= 51 and abs(y-south_walk) <= 0:
		return true
	if x >= 33 and x <= 36 and y >= main_y and y <= 35:
		return true
	return false

func _cc0_object(parent: Node2D, name: String, region: Rect2, foot: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = name
	s.texture = _atlas_region(CC0_VILLAGE,region)
	s.centered = false
	s.offset = Vector2(-region.size.x/2.0,-region.size.y)
	s.position = foot
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(s)
	return s

func _curated_house(parent: Node2D, kind: String, region: Rect2, foot: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = kind
	sprite.texture = _atlas_region(CURATED_HOUSES,region)
	sprite.centered = false
	sprite.offset = Vector2(-region.size.x/2.0,-region.size.y)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = foot
	parent.add_child(sprite)
	return sprite

func _make_village_objects() -> void:
	# Keep the eye on three human-scale landmark buildings and their work.
	# All landmark facades are cropped from one cleared, attribution-tracked
	# CC0 environment atlas. Source coordinates are not enlarged or traced.
	# Use distinct ground positions so this reads as a settlement rather than
	# identically sized items on one display shelf.
	_curated_house(village,"Timber Cottage",Rect2(0, 0, 67, 76),Vector2(250,365))
	_curated_house(village,"Village Storehouse",Rect2(80, 12, 64, 57),Vector2(409,331))
	_curated_house(village,"Village Smithy",Rect2(160, 12, 64, 57),Vector2(621,357))
	_cc0_object(village,"Cave Gate",Rect2(0,0,64,52),Vector2(949,342))

	# A quiet canopy frame creates scale/depth without crowding the paths.
	# The 64x48 crop contains a complete canopy, unlike the old cropped tree.
	var tree_a: Rect2 = Rect2(0,96,64,48)
	var tree_b: Rect2 = Rect2(64,96,63,42)
	for p in [Vector2(87,325),Vector2(132,284),Vector2(183,276),
			Vector2(299,269),Vector2(348,250),Vector2(497,287),
			Vector2(758,278),Vector2(805,249),Vector2(1063,318),
			Vector2(77,504),Vector2(170,509),Vector2(1071,485)]:
		var tree_region: Rect2 = tree_a if _hash(int(p.x),int(p.y),3)%2==0 else tree_b
		_cc0_object(village,"Canopy",tree_region,p)

	# Profession-specific readable objects share one deliberately restricted
	# color/material family. These are NOT complete management systems yet.
	_object(village,"well",Vector2(492,450))
	_object(village,"farm",Vector2(225,499))
	_object(village,"farm",Vector2(957,505))
	_object(village,"wagon",Vector2(512,408))
	_object(village,"bridge",Vector2(546,637))
	for p in [Vector2(306,512),Vector2(844,516)]:
		_object(village,"fence",p)
	for p in [Vector2(684,500),Vector2(1014,466),Vector2(176,461)]:
		_object(village,"rocks",p)
	for p in [Vector2(142,417),Vector2(298,480),Vector2(780,477),
			Vector2(871,414),Vector2(1005,426)]:
		_object(village,"flowers",p)
	for p in [Vector2(270,483),Vector2(320,496),Vector2(817,469),
			Vector2(906,481),Vector2(1038,486)]:
		_object(village,"bush",p)
	for p in [Vector2(354,369),Vector2(382,375),Vector2(595,368)]:
		_object(village,"crate",p)
	for p in [Vector2(546,373),Vector2(858,386)]:
		_object(village,"torch",p)

	plot = _object(village,"blueprint",Vector2(730,397))
	material_icon = _object(village,"crate",Vector2(692,388))
	worker = _character(village, "Worker")
	guard = _character(village, "Guard")
	guard_gear = _gear(village, "GuardEquipment")
	guard.position = Vector2(825,392)
	guard_gear.position = guard.position

func _make_cave_objects() -> void:
	# A protected encounter floor surrounded by connected rockwork. Subtle
	# environmental clusters on the perimeter preserve enemy readability.
	for p in [Vector2(182,305),Vector2(287,360),Vector2(875,330),
			Vector2(1019,415)]:
		_object(cave,"rocks",p)
	for p in [Vector2(265,421),Vector2(391,289),Vector2(821,454)]:
		_object(cave,"mushrooms",p)
	for p in [Vector2(264,283),Vector2(468,284),Vector2(845,293),
			Vector2(985,356)]:
		_object(cave,"torch",p)
	for p in [Vector2(187,446),Vector2(340,463),Vector2(901,474),
			Vector2(957,345)]:
		_object(cave,"crystal",p)
	dungeon_guard = _character(cave, "ExpeditionGuard")
	dungeon_gear = _gear(cave, "ExpeditionEquipment")
	dungeon_guard.position = Vector2(607,395)
	dungeon_gear.position = dungeon_guard.position
	enemy = _object(cave,"slime",Vector2(695,395))

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
	enemy.position.y = 395.0 + sin(sim.elapsed * 3.0) * 2.0
	material_icon.visible = sim.delivered_wood > 0 and not sim.building_complete
	if sim.building_complete != _last_completed:
		plot.texture = _atlas_region(OBJECTS,OBJECT_FRAMES["built_hut"] if sim.building_complete else OBJECT_FRAMES["blueprint"])
		_last_completed = sim.building_complete
