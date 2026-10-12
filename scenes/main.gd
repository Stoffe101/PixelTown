extends Node2D
## First ART/CAMERA/ACTIVITY prototype. Neither a released game nor final art.
const DemoState = preload("res://scripts/demo_simulation.gd")
const Painter = preload("res://scenes/world_art.gd")

var sim
var world
var cam: Camera2D
var selected_view: String = "village"
var art_scale: int = 0
var paused: bool = false
var speed: float = 1.0
var hud_title: Label
var hud_detail: Label
var hud_footer: Label
var last_camera_position: Vector2 = Vector2(552, 351)

func _ready() -> void:
	sim = DemoState.new()
	world = Painter.new()
	world.name = "ProceduralPixelArt"
	add_child(world)
	world.configure_sim(sim)
	cam = Camera2D.new()
	cam.name = "WorldCamera"
	add_child(cam)
	cam.position = last_camera_position
	cam.make_current()
	_create_hud()
	_update_presentation()

func _process(delta: float) -> void:
	if not paused:
		sim.advance(minf(delta, 0.1) * speed)
	world.update_art(sim, selected_view == "cave", art_scale)
	_update_presentation()

func configure_capture(mode: String, scale_choice: int, seconds: float) -> void:
	# Called by visual test capture to produce repeatable art states.
	selected_view = "cave" if mode == "cave" else "village"
	art_scale = clampi(scale_choice, 0, 1)
	sim = DemoState.new()
	world.configure_sim(sim)
	var t: float = maxf(0.0, minf(seconds, 90.0))
	while t > 0.0:
		var step: float = minf(0.05,t)
		sim.advance(step)
		t -= step
	_update_presentation()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_TAB:
				_switch_view()
			KEY_F1:
				hud_footer.get_parent().visible = not hud_footer.get_parent().visible
			KEY_ESCAPE:
				selected_view = "village"
			KEY_1:
				art_scale = 0
			KEY_2:
				art_scale = 1
			KEY_SPACE:
				paused = not paused
			KEY_R:
				sim = DemoState.new()
				world.configure_sim(sim)
			KEY_EQUAL, KEY_KP_ADD:
				cam.zoom = (cam.zoom + Vector2(0.25,0.25)).clamp(Vector2(0.75,0.75),Vector2(2,2))
			KEY_MINUS, KEY_KP_SUBTRACT:
				cam.zoom = (cam.zoom - Vector2(0.25,0.25)).clamp(Vector2(0.75,0.75),Vector2(2,2))
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam.zoom = (cam.zoom + Vector2(0.25,0.25)).clamp(Vector2(0.75,0.75),Vector2(2,2))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam.zoom = (cam.zoom - Vector2(0.25,0.25)).clamp(Vector2(0.75,0.75),Vector2(2,2))
		elif event.button_index == MOUSE_BUTTON_LEFT:
			var click: Vector2 = get_global_mouse_position()
			if selected_view == "village" and click.distance_to(world.get_cave_entrance_position()) < 65:
				selected_view = "cave"
			elif selected_view == "cave" and click.x < 320:
				selected_view = "village"
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		cam.position -= event.relative / cam.zoom
		cam.position.x = clampf(cam.position.x,300,820)
		cam.position.y = clampf(cam.position.y,175,480)

func _switch_view() -> void:
	selected_view = "village" if selected_view == "cave" else "cave"

func _create_hud() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.name = "HUD"
	add_child(ui_layer)
	var root := Control.new()
	root.name = "Layout"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(root)
	var header := PanelContainer.new()
	header.name = "Header"
	header.position = Vector2(12, 12)
	header.custom_minimum_size = Vector2(154, 36)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#172b2ccf")
	style.border_color = Color("#d1ba83")
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(6)
	header.add_theme_stylebox_override("panel",style)
	root.add_child(header)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",3)
	header.add_child(stack)
	hud_title = Label.new()
	hud_title.add_theme_color_override("font_color", Color("#f3e6bb"))
	hud_title.add_theme_font_size_override("font_size", 9)
	stack.add_child(hud_title)
	hud_detail = Label.new()
	hud_detail.add_theme_color_override("font_color", Color("#b7d7c9"))
	hud_detail.add_theme_font_size_override("font_size", 8)
	stack.add_child(hud_detail)
	var footer_box := PanelContainer.new()
	footer_box.name = "Help"
	footer_box.anchor_top = 1
	footer_box.anchor_bottom = 1
	footer_box.offset_top = -35
	footer_box.offset_bottom = -10
	footer_box.offset_left = 12
	footer_box.offset_right = 425
	footer_box.add_theme_stylebox_override("panel",style.duplicate())
	root.add_child(footer_box)
	footer_box.visible = false # F1 opens controls; let the world own the screen.
	hud_footer = Label.new()
	hud_footer.add_theme_font_size_override("font_size", 10)
	hud_footer.add_theme_color_override("font_color",Color("#f2dfba"))
	footer_box.add_child(hud_footer)

func _update_presentation() -> void:
	if world == null:
		return
	world.update_art(sim, selected_view == "cave", art_scale)
	var label_size := "16 x 24" if art_scale == 0 else "20 x 30"
	if selected_view == "village":
		hud_title.text = "THE SETTLEMENT"
		hud_detail.text = "Wood %d    Delivered %d/3" % [sim.storage_wood,sim.delivered_wood]
	else:
		hud_title.text = "UNDER THE HILL"
		hud_detail.text = "Enemy %d/5    Loot %d" % [sim.enemy_hp, sim.expedition_loot]
	hud_footer.text = "TAB views | 1/2 scale (%s) | SPACE pause | R reset | MMB pan | wheel zoom | %s" % [label_size, sim.status()]
