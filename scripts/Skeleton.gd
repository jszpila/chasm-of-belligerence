class_name Skeleton
extends Enemy

func _ready() -> void:
	enemy_type = &"skeleton"
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func setup(cell: Vector2i, live_tex: Texture2D, corpse_tex: Texture2D) -> void:
	enemy_type = &"skeleton"
	configure(cell, 1, corpse_tex)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and live_tex:
		sprite.texture = live_tex
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
