extends RefCounted
## Live-gameloop integration contracts, not subjective visual approval.
const World = preload("res://scenes/world_art.gd")
const Demo = preload("res://scripts/demo_simulation.gd")
func run() -> Array[String]:
    var problems: Array[String] = []
    var world := World.new()
    (Engine.get_main_loop() as SceneTree).root.add_child(world)
    var sim = Demo.new()
    world.configure_sim(sim)
    var villager: AnimatedSprite2D = world.village.get_node("Objects/Worker")
    var guard: AnimatedSprite2D = world.cave.get_node("Objects/Guard")
    var slime: AnimatedSprite2D = world.cave.get_node("Objects/Slime")
    if villager == null or guard == null or slime == null:
        problems.append("Live actors do not use AnimatedSprite2D")
    else:
        var vf = load("res://assets/animations/villager_frames.tres")
        var gf = load("res://assets/animations/guard_frames.tres")
        var sf = load("res://assets/animations/slime_frames.tres")
        if villager.sprite_frames != vf or guard.sprite_frames != gf or slime.sprite_frames != sf:
            problems.append("Live actors do not inherit canonical shared SpriteFrames")
        world.update_art(sim,false,1)
        if villager.animation.begins_with("walk_"):
            problems.append("Gathering agent plays walking animation while standing")
        sim.advance(0.7)
        world.update_art(sim,false,1)
        if sim.worker_state != "deliver" or not villager.animation.begins_with("walk_"):
            problems.append("Carrying agent is not moving with walking frames")
        sim.advance(0.1)
        world.update_art(sim,false,1)
        if villager.animation != &"walk_right":
            problems.append("Worker does not turn toward actual movement direction")
        sim.combat_elapsed = 2.2
        world.update_art(sim,true,1)
        if guard.get_meta("requested_action","") != "attack":
            problems.append("Cave combat window does not select attack state")
        if slime.animation != &"bounce":
            problems.append("Live slime is not using bounce animation")
        sim.combat_elapsed = 0.5
        world.update_art(sim,true,1)
        if guard.get_meta("requested_action","") != "defend":
            problems.append("Guard doesn't leave attack state after hit")
    var wall_layer: TileMapLayer = world.cave.get_node("ChamberWalls")
    if wall_layer == null or wall_layer.tile_set == null:
        problems.append("Paintable cave wall layer lost its TileSet")
    if world.cave.get_node_or_null("RockBoundary/RimNW") == null:
        problems.append("Saved rock boundary lost its authored placement")
    world.queue_free()
    return problems
