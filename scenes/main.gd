extends Control
## Technical viewport and layout diagnostic. NOT actual game art or gameplay.

const BACKGROUND := Color("1b2525")
const PANEL := Color("364c43")
const ACCENT := Color("e8c983")
const TEXT := Color("f4eed8")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = BACKGROUND
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var frame := Panel.new()
	frame.name = "SafeArea"
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 12.0
	frame.offset_top = 12.0
	frame.offset_right = -12.0
	frame.offset_bottom = -12.0
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = PANEL
	panel_style.border_color = ACCENT
	panel_style.set_border_width_all(1)
	panel_style.set_content_margin_all(12.0)
	frame.add_theme_stylebox_override("panel", panel_style)
	add_child(frame)

	var heading := Label.new()
	heading.name = "Heading"
	heading.text = "PIXELTOWN / DISPLAY PROBE"
	heading.add_theme_color_override("font_color", TEXT)
	heading.position = Vector2(26, 25)
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(heading)

	var subheading := Label.new()
	subheading.name = "Status"
	subheading.text = "CI FOUNDATION ONLY - NO GAME ART OR GAMEPLAY YET"
	subheading.add_theme_color_override("font_color", ACCENT)
	subheading.position = Vector2(26, 55)
	subheading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(subheading)

	var left_marker := ColorRect.new()
	left_marker.name = "BottomLeftMarker"
	left_marker.color = ACCENT
	left_marker.position = Vector2(25, 0)
	left_marker.size = Vector2(14, 14)
	left_marker.anchor_top = 1.0
	left_marker.anchor_bottom = 1.0
	left_marker.offset_top = -37.0
	left_marker.offset_bottom = -23.0
	left_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_marker)

	var right_marker := ColorRect.new()
	right_marker.name = "BottomRightMarker"
	right_marker.color = ACCENT
	right_marker.anchor_left = 1.0
	right_marker.anchor_right = 1.0
	right_marker.anchor_top = 1.0
	right_marker.anchor_bottom = 1.0
	right_marker.offset_left = -39.0
	right_marker.offset_right = -25.0
	right_marker.offset_top = -37.0
	right_marker.offset_bottom = -23.0
	right_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(right_marker)
