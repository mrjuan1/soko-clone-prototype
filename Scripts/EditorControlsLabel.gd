extends Label

func _ready() -> void:
	visible = Settings.show_help

func _process(_delta: float) -> void:
	if Settings.start_in_editor and Input.is_action_just_pressed("toggle_help"):
		visible = !visible
		Settings.show_help = visible
		Settings.save_settings()
