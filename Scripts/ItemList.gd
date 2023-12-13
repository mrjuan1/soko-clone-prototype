extends ItemList

@onready var okay_button: Button = %OkayButton

var selected_item_index: int = -1

func _ready() -> void:
	var dir_name: String = "."
	if OS.get_name() == "Web":
		dir_name = "user://"

	var dir: DirAccess = DirAccess.open(dir_name)
	if dir:
		if OS.get_name() == "Web":
			if not FileAccess.file_exists("user://Original Levels.lpk"):
				dir.copy("res://Original Levels.lpk", "user://Original Levels.lpk")
			if not FileAccess.file_exists("user://Sokoban Levels.lpk"):
				dir.copy("res://Sokoban Levels.lpk", "user://Sokoban Levels.lpk")

		dir.list_dir_begin()
		var file: String = dir.get_next()
		while file != "":
			if not dir.current_is_dir() and file.ends_with(".lpk"):
				var pack_name: String = file.replace(".lpk", "")
				add_item(pack_name)
			file = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to read current directory")

	grab_focus()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("continue") and (okay_button.has_focus() or has_focus()) and selected_item_index >= 0:
		_on_item_activated(selected_item_index)

func _on_item_selected(index: int) -> void:
	selected_item_index = index

func _on_item_activated(index: int) -> void:
	var pack_name: String = get_item_text(index)
	Levels.pack_file = pack_name + ".lpk"
	get_tree().change_scene_to_file("res://MainScene.tscn")
