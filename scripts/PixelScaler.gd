extends Node

const BASE_SIZE := Vector2i(1152, 768)

func _ready() -> void:
	var win := get_window()
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	if not win.size_changed.is_connected(_on_window_size_changed):
		win.size_changed.connect(_on_window_size_changed)
	_apply_integer_scale()

func _on_window_size_changed() -> void:
	_apply_integer_scale()

func _apply_integer_scale() -> void:
	var win := get_window()
	var size: Vector2i = win.size
	var sx: int = int(floor(float(size.x) / float(BASE_SIZE.x)))
	var sy: int = int(floor(float(size.y) / float(BASE_SIZE.y)))
	var scale: int = sx
	if sy < scale:
		scale = sy
	if scale < 1:
		scale = 1
	win.content_scale_factor = float(scale)
