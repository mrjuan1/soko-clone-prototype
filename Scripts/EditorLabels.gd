extends VBoxContainer

@onready var editor_label: Label = %EditorLabel

func _on_cursor_play_mode_requested(validation_result: Levels.ValidationResult) -> void:
	if validation_result == Levels.ValidationResult.SUCCESS:
		visible = false

func _on_cursor_starting_edit_mode() -> void:
	editor_label.text = "Edit mode (%s)" % Levels.pack_file.replace(".lpk", "")
	visible = true
