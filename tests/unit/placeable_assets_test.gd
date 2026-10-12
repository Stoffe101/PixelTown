extends RefCounted
## Confirm instancing, texture sharing, anchors and Inspector overrides.
const PATHS = [
	"res://scenes/buildings/HouseSmall.tscn",
	"res://scenes/buildings/Blacksmith.tscn",
	"res://scenes/buildings/StorageHut.tscn",
	"res://scenes/environment/OakTree.tscn",
	"res://scenes/environment/LargeRock.tscn",
	"res://scenes/props/Barrel.tscn",
	"res://scenes/caves/CaveEntrance.tscn"
]
func run() -> Array[String]:
	var errors: Array[String] = []
	for path in PATHS:
		var packed := load(path) as PackedScene
		if packed == null:
			errors.append("Prefab cannot load: " + path)
			continue
		var a := packed.instantiate() as Sprite2D
		var b := packed.instantiate() as Sprite2D
		if a == null or b == null:
			errors.append("Prefab is not a Sprite2D: " + path)
			continue
		if a.texture == null or a.texture != b.texture:
			errors.append("Source PNG texture is not shared: " + path)
		if a.centered or a.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
			errors.append("Wrong pivot or texture filter: " + path)
		a.position = Vector2(96, 80)
		b.position = Vector2(208, 160)
		b.modulate = Color(0.8, 0.9, 1.0)
		if a.position == b.position or a.modulate == b.modulate:
			errors.append("Instance overrides leaked: " + path)
		var shape := a.get_node_or_null("Obstacle/CollisionShape2D") as CollisionShape2D
		if shape == null or shape.shape == null:
			errors.append("Missing authored collision: " + path)
		a.free()
		b.free()
	var showcase := load("res://scenes/levels/artist_showcase.tscn") as PackedScene
	if showcase == null:
		errors.append("Artist showcase cannot load")
	else:
		var map := showcase.instantiate()
		if map.get_node_or_null("HouseTest03") == null or map.get_node_or_null("OakTree05") == null:
			errors.append("Artist showcase lost prefab instances")
		map.free()
	var tiles := load("res://assets/tilesets/village/village_ground_16.tres") as TileSet
	if tiles == null or tiles.tile_size != Vector2i(16, 16) or tiles.get_source_count() < 1:
		errors.append("16-pixel TileSet is missing or invalid")
	return errors
