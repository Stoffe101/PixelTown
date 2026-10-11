extends SceneTree
## Render the REAL project bootstrap at requested display size and save the frame.
## These files are layout diagnostics, not approved game reference screenshots.

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 3:
		printerr("Usage: capture.gd -- WIDTH HEIGHT OUTPUT_PNG")
		quit(2)
		return

	var expected_size := Vector2i(int(args[0]), int(args[1]))
	if expected_size.x <= 0 or expected_size.y <= 0:
		printerr("Invalid capture dimensions")
		quit(2)
		return

	DisplayServer.window_set_size(expected_size)
	var source := load("res://scenes/main.tscn") as PackedScene
	if source == null:
		printerr("Unable to load main scene")
		quit(1)
		return
	var scene := source.instantiate()
	get_root().add_child(scene)
	for i in range(6):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := get_root().get_texture().get_image()
	if image == null or image.is_empty():
		printerr("No rendered frame available")
		quit(1)
		return
	# Viewport pixel-art mode renders at logical resolution. Validate its actual
	# expanded aspect and reproduce the integer-scaled display frame.
	var base_size := Vector2i(640, 360)
	var pixel_scale := mini(expected_size.x / base_size.x, expected_size.y / base_size.y)
	var expected_viewport := Vector2i(expected_size.x / pixel_scale, expected_size.y / pixel_scale)
	var rendered_size := image.get_size()
	if pixel_scale < 1 or rendered_size != expected_viewport:
		printerr("Logical viewport mismatch: got ", rendered_size, ", expected ", expected_viewport, " for ", expected_size)
		quit(1)
		return
	image.resize(expected_size.x, expected_size.y, Image.INTERPOLATE_NEAREST)
	var result := image.save_png(args[2])
	if result != OK:
		printerr("PNG save failed: ", result)
		quit(1)
		return
	print("CAPTURE PASS: ", args[2], " viewport=", rendered_size, " integer_scale=", pixel_scale, " PNG=", image.get_width(), "x", image.get_height())
	quit(0)
