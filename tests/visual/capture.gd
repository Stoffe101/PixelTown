extends SceneTree
## Captures actual Godot village/cave art using the same integer-pixel display path
## as normal play. These are review candidates, not approved final-game baselines.

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3 or args.size() > 6:
		printerr("Usage: capture.gd -- WIDTH HEIGHT OUTPUT_PNG [village|cave] [0|1 art scale] [sim seconds]")
		quit(2)
		return
	var expected_size := Vector2i(int(args[0]), int(args[1]))
	if expected_size.x <= 0 or expected_size.y <= 0:
		printerr("Invalid capture dimensions")
		quit(2)
		return
	var mode := args[3] if args.size() > 3 else "village"
	var scale_choice := int(args[4]) if args.size() > 4 else 0
	var seconds := float(args[5]) if args.size() > 5 else 0.0
	if mode != "village" and mode != "cave":
		printerr("Unknown capture mode ",mode)
		quit(2)
		return

	DisplayServer.window_set_size(expected_size)
	var source := load("res://scenes/main.tscn") as PackedScene
	if source == null:
		printerr("Unable to load main scene")
		quit(1)
		return
	var scene: Node = source.instantiate()
	get_root().add_child(scene)
	if not scene.has_method("configure_capture"):
		printerr("Scene missing capture configuration")
		quit(1)
		return
	scene.call("configure_capture",mode,scale_choice,seconds)
	for i in range(6):
		await process_frame
	await RenderingServer.frame_post_draw
	var result_image := get_root().get_texture().get_image()
	if result_image == null or result_image.is_empty():
		printerr("No rendered frame available")
		quit(1)
		return
	var base_size := Vector2i(640,360)
	var pixel_scale := mini(expected_size.x / base_size.x, expected_size.y / base_size.y)
	if pixel_scale < 1:
		printerr("Pixel scale less than one")
		quit(1)
		return
	var expected_viewport := Vector2i(expected_size.x / pixel_scale, expected_size.y / pixel_scale)
	var actual_logical := result_image.get_size()
	if actual_logical != expected_viewport:
		printerr("Unexpected logical viewport: ",actual_logical," instead of ",expected_viewport)
		quit(1)
		return
	result_image.resize(expected_size.x,expected_size.y,Image.INTERPOLATE_NEAREST)
	var result := result_image.save_png(args[2])
	if result != OK:
		printerr("PNG save failed: ",result)
		quit(1)
		return
	print("CAPTURE PASS: ",mode," scale=",scale_choice," sim=",seconds," viewport=",actual_logical," pixels=",expected_size," file=",args[2])
	quit(0)
