extends RefCounted
## Verify the actual scene's SpriteFrames and action state handoff.
func run() -> Array[String]:
    var problems: Array[String] = []
    var world: Node2D = load("res://scenes/world_art.gd").new()
    var host := Node2D.new()
    host.add_child(world)
    # Run the lifecycle manually: this standalone unit suite is not inside SceneTree.
    world._ready()
    var sim = load("res://scripts/demo_simulation.gd").new()
    world.configure_sim(sim)
    var worker := world.get_node("VillageLayout/Objects/Worker") as AnimatedSprite2D
    var guard := world.get_node("CaveLayout/Objects/Guard") as AnimatedSprite2D
    if worker == null or guard == null:
        problems.append("Live prefabs were not instantiated")
    else:
        var frames := guard.sprite_frames
        for name in ["attack_right","defend_right"]:
            if not frames.has_animation(name):
                problems.append("Guard lacks "+name)
        if frames.has_animation("attack_right") and (frames.get_frame_count("attack_right") != 4 or frames.get_animation_loop("attack_right")):
            problems.append("Guard attack must be a one-shot four-frame strike")
        world.update_art(sim, false, 1)
        if worker.get_meta("requested_action","") != "gather":
            problems.append("Initial worker must gather, not walk")
        sim.advance(0.7)
        world.update_art(sim, false, 1)
        if worker.get_meta("requested_action","") != "carry":
            problems.append("Delivering must request carrying")
        sim.combat_elapsed = 2.2
        world.update_art(sim, true, 1)
        if guard.animation != &"attack_right":
            problems.append("Cave guard is not playing attack art in hit window")
        sim.combat_elapsed = 0.6
        world.update_art(sim, true, 1)
        if guard.animation != &"defend_right":
            problems.append("Cave guard failed to return to defense")
    host.free()
    return problems
