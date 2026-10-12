extends RefCounted
## Technical checks for exported sprite sheets and drag-and-drop AnimatedSprite2D scenes.
const CHARACTERS = [
    ["res://scenes/characters/Villager.tscn", "walk_down", "idle_up", 4],
    ["res://scenes/characters/Guard.tscn", "walk_right", "idle_left", 4],
    ["res://scenes/enemies/Slime.tscn", "bounce", "idle", 4],
    ["res://scenes/enemies/Bat.tscn", "fly", "idle", 4],
    ["res://scenes/enemies/Spider.tscn", "walk", "idle", 4],
]
func run() -> Array[String]:
    var errors: Array[String] = []
    for entry in CHARACTERS:
        var packed := load(entry[0]) as PackedScene
        if packed == null:
            errors.append("Cannot load animated scene: " + entry[0])
            continue
        var character := packed.instantiate() as AnimatedSprite2D
        if character == null or character.sprite_frames == null:
            errors.append("Expected AnimatedSprite2D: " + entry[0])
            continue
        for animation in [entry[1], entry[2]]:
            if not character.sprite_frames.has_animation(animation):
                errors.append("Missing animation: " + str(animation))
        if character.sprite_frames.has_animation(entry[1]):
            if character.sprite_frames.get_frame_count(entry[1]) != entry[3]:
                errors.append("Wrong frame count: " + str(entry[1]))
            else:
                for index in range(entry[3]):
                    var texture := character.sprite_frames.get_frame_texture(entry[1], index)
                    if texture == null:
                        errors.append("Blank frame: " + str(entry[1]) + " " + str(index))
        character.free()
    var cave_tiles := load("res://assets/tilesets/cave/cave_terrain_32.tres") as TileSet
    var village_tiles := load("res://assets/tilesets/village/village_terrain_32.tres") as TileSet
    if cave_tiles == null or village_tiles == null:
        errors.append("Cave/village TileSet resource is unavailable")
    else:
        if cave_tiles.tile_size != Vector2i(32, 32) or village_tiles.tile_size != Vector2i(32, 32):
            errors.append("Incorrect 32px TileSet grid")
    for path in ["res://scenes/props/Crate.tscn", "res://scenes/props/Well.tscn", "res://scenes/caves/OreBlue.tscn", "res://scenes/caves/TorchStand.tscn"]:
        var packed := load(path) as PackedScene
        if packed == null:
            errors.append("Missing prefab " + path)
        else:
            var scene := packed.instantiate() as Sprite2D
            if scene == null or scene.texture == null:
                errors.append("Prefab missing sprite " + path)
            if scene != null:
                scene.free()
    return errors
