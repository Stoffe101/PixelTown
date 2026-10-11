extends RefCounted
## Layouts must be real, editable PackedScenes. Runtime logic reads markers.

const Village = preload("res://scenes/levels/village_layout.tscn")
const Cave = preload("res://scenes/levels/cave_layout.tscn")
const DemoState = preload("res://scripts/demo_simulation.gd")

func run() -> Array[String]:
	var issues: Array[String] = []
	var village := Village.instantiate()
	var cave := Cave.instantiate()
	if village == null or cave == null:
		return ["Editable scenes failed to instantiate"]
	for path in ["Objects/Cottage", "Objects/Storehouse", "Objects/Smithy",
			"Objects/CaveEntrance", "Objects/ConstructionSite", "Markers/Storage",
			"Markers/CaveEntranceSpot", "Markers/GuardPost"]:
		if village.get_node_or_null(path) == null:
			issues.append("Village is missing editable node: " + path)
	for path in ["Objects/MineralShrine", "Objects/Guard", "Objects/Slime",
			"Markers/GuardPost", "Markers/EnemySpawn"]:
		if cave.get_node_or_null(path) == null:
			issues.append("Cave is missing editable node: " + path)
	var site: Sprite2D = village.get_node_or_null("Objects/ConstructionSite")
	var storage: Marker2D = village.get_node_or_null("Markers/Storage")
	if site != null and storage != null:
		var original_pos: Vector2 = site.position
		site.position = original_pos + Vector2(48,16)
		var state := DemoState.new()
		state.configure_locations(storage.position,site.position)
		if state.plot_point != site.position:
			issues.append("Moved build site did not update actual simulation destination")
		if state.worker_pos != storage.position:
			issues.append("Worker did not start at the scene's storage marker")
		for i in range(700):
			state.advance(0.1)
		if not state.building_complete or not state.resources_conserved():
			issues.append("Moving a site broke resource conservation or construction completion")
	village.free()
	cave.free()
	return issues
