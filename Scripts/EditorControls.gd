extends VBoxContainer

func _on_cursor_play_mode_requested(validation_result: Levels.ValidationResult) -> void:
	if validation_result == Levels.ValidationResult.SUCCESS:
		visible = false

func _on_cursor_starting_edit_mode() -> void:
	visible = true
