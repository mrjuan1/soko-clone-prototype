extends Button

@onready var pack_name_field: LineEdit = %PackNameField

func _pressed() -> void:
	if pack_name_field.text:
		Levels.pack_file = pack_name_field.text + ".lpk"
		get_tree().change_scene_to_file("res://MainScene.tscn")
