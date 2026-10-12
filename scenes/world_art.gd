extends Node2D
## Serialized scenes own art and coordinates; simulation only chooses animation/state.
const VILLAGE_LAYOUT = preload("res://scenes/levels/village_layout.tscn")
const CAVE_LAYOUT = preload("res://scenes/levels/cave_layout.tscn")
var village: Node2D
var cave: Node2D
var worker: AnimatedSprite2D
var guard: AnimatedSprite2D
var dungeon_guard: AnimatedSprite2D
var enemy: AnimatedSprite2D
var plot: Sprite2D
var completed_hut: Sprite2D
var carried_wood_icon: Sprite2D
var delivered_wood_icons: Array[Sprite2D] = []
var _last_worker_pos := Vector2.INF
var _worker_direction := "down"

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    village = VILLAGE_LAYOUT.instantiate() as Node2D
    cave = CAVE_LAYOUT.instantiate() as Node2D
    village.y_sort_enabled = true
    cave.y_sort_enabled = true
    add_child(village)
    add_child(cave)
    (village.get_node("EditorBackdrop") as CanvasItem).hide()
    (cave.get_node("EditorBackdrop") as CanvasItem).hide()
    worker = village.get_node("Objects/Worker") as AnimatedSprite2D
    guard = village.get_node("Objects/Guard") as AnimatedSprite2D
    dungeon_guard = cave.get_node("Objects/Guard") as AnimatedSprite2D
    enemy = cave.get_node("Objects/Slime") as AnimatedSprite2D
    plot = village.get_node("Objects/ConstructionSite") as Sprite2D
    completed_hut = village.get_node("Objects/CompletedHut") as Sprite2D
    carried_wood_icon = village.get_node("Objects/CarriedWood") as Sprite2D
    for index in range(3):
        delivered_wood_icons.append(village.get_node("Objects/DeliveredWood%d" % (index+1)) as Sprite2D)

func _point(parent: Node2D, id: String) -> Vector2:
    return (parent.get_node("Markers/" + id) as Marker2D).position

func configure_sim(sim) -> void:
    sim.configure_locations(_point(village,"Storage"),plot.position)
    _last_worker_pos = Vector2.INF

func get_cave_entrance_position() -> Vector2:
    return _point(village,"CaveEntranceSpot")

func _play(actor: AnimatedSprite2D, action: String, direction: String) -> void:
    actor.set_meta("requested_action", action)
    var wanted := action + "_" + direction
    if not actor.sprite_frames.has_animation(wanted):
        # Do not animate a stationary actor with a walking cycle.
        wanted = ("walk_" if action == "carry" or action == "retreat" or action == "walk" else "idle_") + direction
    if not actor.sprite_frames.has_animation(wanted):
        wanted = "idle_down"
    if actor.animation != wanted:
        actor.play(wanted)
    elif not actor.is_playing() and actor.sprite_frames.get_animation_loop(wanted):
        actor.play(wanted)

func update_art(sim, show_cave: bool, _size_choice: int) -> void:
    if village == null:
        return
    village.visible = not show_cave
    cave.visible = show_cave
    var target: Vector2 = sim.worker_pos
    if _last_worker_pos != Vector2.INF:
        var delta_pos := target - _last_worker_pos
        if delta_pos.length_squared() > 0.02:
            _worker_direction = "right" if delta_pos.x > 0 else "left"
    _last_worker_pos = target
    worker.position = target
    var action := "idle"
    match sim.worker_state:
        "deliver": action = "carry" if sim.carried_wood > 0 else "walk"
        "return": action = "walk"
        "gather", "collect": action = "gather"
        "build": action = "work"
        _: action = "idle"
    _play(worker, action, _worker_direction if action == "walk" or action == "carry" else "down")
    guard.position = _point(village,"GuardPost")
    _play(guard,"idle","down")
    dungeon_guard.position = _point(cave,"GuardPost")
    var attack_window: bool = sim.combat_elapsed >= 2.15
    _play(dungeon_guard, "attack" if attack_window else "defend", "right")
    # Stable ground anchor: spear movement is authored in the right-facing attack PNG.
    dungeon_guard.offset = Vector2(-32,-70)
    dungeon_guard.rotation_degrees = 0.0
    enemy.position = _point(cave,"EnemySpawn")
    if enemy.animation != &"bounce" or not enemy.is_playing():
        enemy.play(&"bounce")
    enemy.modulate = Color("#f4b2ae") if sim.combat_elapsed < 0.22 else Color.WHITE
    carried_wood_icon.visible = sim.carried_wood > 0
    carried_wood_icon.position = target + Vector2(0,-26)
    for index in range(delivered_wood_icons.size()):
        delivered_wood_icons[index].position = plot.position + Vector2(-29.0 + float(index)*19.0,5.0)
        delivered_wood_icons[index].visible = index < sim.delivered_wood and not sim.building_complete
    plot.visible = not sim.building_complete
    completed_hut.visible = sim.building_complete
    completed_hut.position = plot.position
