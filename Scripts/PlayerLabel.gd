extends Label

var players_placed: int = 0;

func _ready() -> void:
	label_settings.font_color = Color.WHITE

func _on_cursor_object_placed(object_type: int) -> void:
	if object_type == Levels.OT_PLAYER:
		players_placed += 1
		update_text()

func _on_cursor_object_deleted(object_type: int) -> void:
	if object_type == Levels.OT_PLAYER:
		players_placed -= 1
		update_text()

func update_text() -> void:
	var value: String = "None"

	if players_placed == 1:
		value = "Preset"
		label_settings.font_color = Color.GREEN
	elif players_placed > 1:
		value = "Too many (%d)" % players_placed
		label_settings.font_color = Color.RED
	else:
		label_settings.font_color = Color.WHITE

	text = "Player: %s" % value
