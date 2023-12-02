extends Label

func _ready() -> void:
	_on_cursor_selected_object_changed(Levels.OT_FLOOR)

func _on_cursor_selected_object_changed(selected_object: int) -> void:
	var object_str: String

	match selected_object:
		Levels.OT_FLOOR:
			object_str = "Floor"
		Levels.OT_BOX:
			object_str = "Box"
		Levels.OT_TARGET:
			object_str = "Target"
		Levels.OT_PLAYER:
			object_str = "Player"

	text = "Selected Object: %s" % object_str
