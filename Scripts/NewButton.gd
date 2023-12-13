extends Button

@onready var pack_name_field: LineEdit = %PackNameField

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("continue") and (pack_name_field.has_focus() or has_focus()):
		_pressed()

func _pressed() -> void:
	if pack_name_field.text:
		Levels.pack_file = pack_name_field.text + ".lpk"
		get_tree().change_scene_to_file("res://MainScene.tscn")
