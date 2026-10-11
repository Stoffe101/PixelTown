@tool
extends Sprite2D
## Reusable scene-owned sprite. Position is authored in a level, not GDScript.
@export var display_name: String = ""
@export_enum("Building", "Environment", "Prop", "Cave") var category: String = "Prop"
@export var visual_variant: String = "default"
@export var footprint_cells: Vector2i = Vector2i.ONE:
	set(value):
		footprint_cells = Vector2i(maxi(1, value.x), maxi(1, value.y))
		queue_redraw()
@export var interaction_offset: Vector2 = Vector2.ZERO:
	set(value):
		interaction_offset = value
		queue_redraw()
@export var blocks_movement: bool = false:
	set(value):
		blocks_movement = value
		_apply_collision()
@export var show_placement_guides: bool = false:
	set(value):
		show_placement_guides = value
		queue_redraw()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_apply_collision()

func _apply_collision() -> void:
	if not is_inside_tree():
		return
	var obstacle := get_node_or_null("Obstacle") as StaticBody2D
	if obstacle != null:
		obstacle.collision_layer = 1 if blocks_movement else 0
		obstacle.collision_mask = 0

func _draw() -> void:
	if not Engine.is_editor_hint() or not show_placement_guides:
		return
	var width_px := float(footprint_cells.x * 16)
	var height_px := float(footprint_cells.y * 16)
	draw_rect(Rect2(-width_px * 0.5, -height_px, width_px, height_px), Color(0.2, 0.85, 0.7, 0.7), false, 1.0)
	draw_circle(interaction_offset, 2.0, Color(1.0, 0.75, 0.25, 0.9))
