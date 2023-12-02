extends Label

@onready var action_label_timer: Timer = $ActionLabelTimer

func _on_cursor_level_changed() -> void:
	text = "Level changed"
	label_settings.font_color = Color.WHITE
	action_label_timer.start()

func _on_cursor_level_cleared() -> void:
	text = "Level cleared"
	label_settings.font_color = Color.WHITE
	action_label_timer.start()

func _on_cursor_level_loaded() -> void:
	text = "Level loaded"
	label_settings.font_color = Color.WHITE
	action_label_timer.start()

func _on_cursor_level_saved() -> void:
	text = "Level saved"
	label_settings.font_color = Color.WHITE
	action_label_timer.start()

func _on_cursor_object_deleted(object_type: int) -> void:
	if object_type >= 0:
		text = "%s deleted" % get_object_name(object_type)
		label_settings.font_color = Color.WHITE
		action_label_timer.start()

func _on_cursor_object_placed(object_type: int) -> void:
	text = "%s placed" % get_object_name(object_type)
	label_settings.font_color = Color.WHITE
	action_label_timer.start()

func _on_cursor_play_mode_requested(validation_result: Levels.ValidationResult) -> void:
	match validation_result:
		Levels.ValidationResult.NOT_ONE_PLAYER:
			text = "One player is required"
			label_settings.font_color = Color.RED
		Levels.ValidationResult.BOX_TARGET_MISMATCH:
			text = "Number of boxes and targets must be\nmore than 0 and be the same"
			label_settings.font_color = Color.RED

	action_label_timer.start()

func _on_action_label_timer_timeout() -> void:
	text = ""
	label_settings.font_color = Color.WHITE

func get_object_name(object_type: int) -> String:
	match object_type:
		Levels.OT_FLOOR:
			return "Floor"
		Levels.OT_BOX:
			return "Box"
		Levels.OT_TARGET:
			return "Target"
		Levels.OT_PLAYER:
			return "Player"

	return "Unknown object"


