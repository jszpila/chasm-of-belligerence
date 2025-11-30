class_name Minotaur
extends Enemy

func _ready() -> void:
	enemy_type = &"minotaur"
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func setup(cell: Vector2i, live_tex: Texture2D, corpse_tex: Texture2D) -> void:
	enemy_type = &"minotaur"
	configure(cell, 2, corpse_tex)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and live_tex:
		sprite.texture = live_tex
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.modulate = Color(1, 1, 1, 1)

func _on_damaged(_amount: int) -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		# Slight red tint to show the minotaur has been hurt
		var intensity := 0.6
		sprite.modulate = Color(1, intensity, intensity, 1)
