extends Label

func _ready() -> void:
	_on_cursor_level_changed()

func _on_cursor_level_changed() -> void:
	text = "Level: %d/%d" % [Levels.level + 1, Levels.levels]
