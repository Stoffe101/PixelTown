extends SceneTree
## Captures actual Godot village/cave art using the same integer-pixel display path
## as normal play. These are review candidates, not approved final-game baselines.

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3 or args.size() > 7:
		printerr("Usage: capture.gd -- WIDTH HEIGHT OUTPUT_PNG [village|cave] [0|1 art scale] [sim seconds] [camera zoom]")
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
	var camera_zoom := float(args[6]) if args.size() > 6 else 1.0
	if mode != "village" and mode != "cave" and mode != "showcase":
		printerr("Unknown capture mode ",mode)
		quit(2)
		return

	DisplayServer.window_set_size(expected_size)
	var scene_file: String = "res://scenes/levels/artist_showcase.tscn" if mode == "showcase" else "res://scenes/main.tscn"
	var source := load(scene_file) as PackedScene
	if source == null:
		printerr("Unable to load main scene")
		quit(1)
		return
	var scene: Node = source.instantiate()
	get_root().add_child(scene)
	if mode != "showcase" and not scene.has_method("configure_capture"):
		printerr("Scene missing capture configuration")
		quit(1)
		return
	if mode != "showcase":
		scene.call("configure_capture",mode,scale_choice,seconds)
	else:
		(scene.get_node("ShowcaseCamera") as Camera2D).make_current()
	if camera_zoom != 1.0:
		var camera: Camera2D = scene.get_node_or_null("ShowcaseCamera" if mode == "showcase" else "WorldCamera")
		if camera != null:
			camera.zoom = Vector2.ONE * camera_zoom
	for i in range(6):
		await process_frame
	await RenderingServer.frame_post_draw
	var result_image := get_root().get_texture().get_image()
	if result_image == null or result_image.is_empty():
		printerr("No rendered frame available")
		quit(1)
		return
	var base_size := Vector2i(
		int(ProjectSettings.get_setting("display/window/size/viewport_width",640)),
		int(ProjectSettings.get_setting("display/window/size/viewport_height",360)))
	var pixel_scale := mini(expected_size.x / base_size.x, expected_size.y / base_size.y)
	if pixel_scale < 1:
		printerr("Pixel scale less than one")
		quit(1)
		return
	var expected_viewport := Vector2i(expected_size.x / pixel_scale, expected_size.y / pixel_scale)
	var actual_logical := result_image.get_size()
	if actual_logical != expected_viewport and actual_logical != base_size:
		printerr("Unexpected logical viewport: ",actual_logical," instead of ",expected_viewport," or ",base_size)
		quit(1)
		return
	# Godot can preserve its configured base canvas in smaller integer-scaled
	# windows. Capture the genuine base render with centered integer bars.
	if actual_logical == base_size and expected_viewport != base_size:
		var scaled := result_image.duplicate()
		scaled.resize(base_size.x*pixel_scale,base_size.y*pixel_scale,Image.INTERPOLATE_NEAREST)
		var framed := Image.create(expected_size.x,expected_size.y,false,Image.FORMAT_RGBA8)
		framed.fill(Color("#18252f"))
		var target := Vector2i((expected_size.x-scaled.get_width())/2,(expected_size.y-scaled.get_height())/2)
		framed.blit_rect(scaled,Rect2i(Vector2i.ZERO,scaled.get_size()),target)
		result_image=framed
	else:
		result_image.resize(expected_size.x,expected_size.y,Image.INTERPOLATE_NEAREST)
	var result := result_image.save_png(args[2])
	if result != OK:
		printerr("PNG save failed: ",result)
		quit(1)
		return
	print("CAPTURE PASS: ",mode," scale=",scale_choice," sim=",seconds," viewport=",actual_logical," pixels=",expected_size," file=",args[2])
	quit(0)
