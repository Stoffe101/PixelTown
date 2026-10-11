extends SceneTree
## ONE-TIME asset authoring/migration tool, not an in-game generator.
## Populate blank PaintedTerrain TileMapLayer nodes, then SAVE real .tscn
## scene resources. Refuse to overwrite artists' existing painted maps.

const TILESET_FILE := "res://assets/terrain_paint_tileset.tres"
const VILLAGE_FILE := "res://scenes/levels/village_layout.tscn"
const CAVE_FILE := "res://scenes/levels/cave_layout.tscn"

func _initialize() -> void:
	var result := _bake()
	quit(result)

func _bake() -> int:
	var tileset := load(TILESET_FILE) as TileSet
	if tileset == null:
		push_error("Cannot load committed terrain TileSet")
		return 1
	if tileset.get_source_count() != 1:
		push_error("Starter tileset has already been initialized; refusing to overwrite")
		return 1

	var exterior := TileSetAtlasSource.new()
	exterior.texture = load("res://assets/third_party/ninja_adventure/tileset_floor.png")
	exterior.texture_region_size = Vector2i(16,16)
	for y in range(7,14):
		for x in range(16):
			exterior.create_tile(Vector2i(x,y))
	tileset.add_source(exterior,1)

	var interior := TileSetAtlasSource.new()
	interior.texture = load("res://assets/third_party/ninja_adventure/tileset_interior_floor.png")
	interior.texture_region_size = Vector2i(16,16)
	for y in range(6,16):
		for x in range(11,21):
			interior.create_tile(Vector2i(x,y))
	tileset.add_source(interior,2)
	if ResourceSaver.save(tileset,TILESET_FILE) != OK:
		push_error("Cannot persist authored TileSet")
		return 1
	for entry in [{"path":VILLAGE_FILE,"cave":false},{"path":CAVE_FILE,"cave":true}]:
		var path: String = entry.path
		var packed := load(path) as PackedScene
		if packed == null:
			push_error("Cannot load scene " + path)
			return 1
		var scene := packed.instantiate() as Node2D
		if scene == null:
			return 1
		var layer := scene.get_node("PaintedTerrain") as TileMapLayer
		if not layer.get_used_cells().is_empty():
			push_error("Existing authored cells found in " + path + " - not overwriting!")
			scene.free()
			return 1
		for y in range(-8,66):
			for x in range(-25,101):
				var seed: int = _hash_cell(x,y,1 if entry.cave else 0)
				var source := 0
				var coord := Vector2i(seed % 16,0)
				if entry.cave:
					var wall: bool = (x < 8 or x > 63 or
							y < 11 + _hash_cell(floori(float(x)/6.0),2,10)%3 or
							y > 33 - _hash_cell(floori(float(x)/7.0),3,12)%3)
					coord = Vector2i(8 + seed%8,3) if wall else Vector2i(seed%8,2)
					var fragment: bool = ((x>=17 and x<=19 and y>=18 and y<=21)
							or (x>=54 and x<=57 and y>=28 and y<=30))
					if fragment:
						source = 2
						coord = Vector2i(12+seed%3,13)
				else:
					if _road(x,y):
						source = 1
						var top_open := not _road(x,y-1)
						var bottom_open := not _road(x,y+1)
						var left_open := not _road(x-1,y)
						var right_open := not _road(x+1,y)
						coord = Vector2i(12 - int(left_open) + int(right_open),
								8 - int(top_open) + int(bottom_open))
					var bank := 35 + roundi(sin(float(x)*0.14))
					if y>=bank:
						source = 0
						coord = Vector2i(8+seed%8,1)
					if x>=32 and x<=36 and y>=bank and y<=bank+5:
						source = 1
						coord = Vector2i(12,8)
				layer.set_cell(Vector2i(x,y),source,coord)
		var output := PackedScene.new()
		var error := output.pack(scene)
		if error != OK:
			push_error("Could not pack authored cells for "+path)
			scene.free()
			return 1
		error = ResourceSaver.save(output,path)
		if error != OK:
			push_error("Could not save authored level "+path)
			scene.free()
			return 1
		print("BAKED EDITABLE TERRAIN: ",path," cells=",layer.get_used_cells().size())
		scene.free()
	print("SUCCESS: All terrain now persists inside actual Godot scene files.")
	return 0

func _hash_cell(x: int,y: int,salt: int=0) -> int:
	var n: int = x*769+y*2017+salt*89+1729
	n = n ^ (n<<13)
	n = n ^ (n>>11)
	return absi(n)%100

func _road(x: int,y: int) -> bool:
	var main_y := 25 + roundi(sin(float(x)*0.17)*1.2)
	if x>=8 and x<=67 and y>=main_y and y<=main_y+1:
		return true
	for branch_x in [19,25,37,51]:
		var start_y := 21 if branch_x==25 else 22
		if x==branch_x and y>=start_y and y<=main_y:
			return true
	if x>=33 and x<=35 and y>=main_y and y<=36:
		return true
	return false
