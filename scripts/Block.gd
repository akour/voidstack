extends Node2D
class_name StackBlock

@export var block_size := Vector2(240.0, 48.0)
@export var block_color := Color(0.18, 0.75, 0.9, 1.0)

@onready var rect: Panel = $Rect


func _ready() -> void:
	_apply_visuals()


func set_block_size(value: Vector2) -> void:
	block_size = value
	if is_node_ready():
		_apply_visuals()


func set_block_color(value: Color) -> void:
	block_color = value
	if is_node_ready():
		_apply_visuals()


func get_width() -> float:
	return block_size.x


func get_height() -> float:
	return block_size.y


func _apply_visuals() -> void:
	# Keep the rectangle centered on the Block origin for simple stack math later.
	rect.size = block_size
	rect.position = -block_size * 0.5
	var style := StyleBoxFlat.new()
	style.bg_color = block_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	rect.add_theme_stylebox_override("panel", style)
