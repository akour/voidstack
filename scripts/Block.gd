extends Node2D
class_name StackBlock

@export var block_size := Vector2(240.0, 48.0)
@export var block_color := Color(0.18, 0.75, 0.9, 1.0)

@onready var rect: ColorRect = $Rect


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


func _apply_visuals() -> void:
	# Keep the rectangle centered on the Block origin for simple stack math later.
	rect.size = block_size
	rect.position = -block_size * 0.5
	rect.color = block_color
