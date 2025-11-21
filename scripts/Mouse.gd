class_name Mouse
extends Enemy

var move_chance := 0.75

func _ready() -> void:
	enemy_type = &"mouse"

func setup(cell: Vector2i, tex: Texture2D) -> void:
	enemy_type = &"mouse"
	configure(cell, 1, null)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.texture = tex
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
