extends ItemList

func _ready() -> void:
	var dir: DirAccess = DirAccess.open(".")
	if dir:
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

func _on_item_activated(index: int) -> void:
	var pack_name: String = get_item_text(index)
	Levels.pack_file = pack_name + ".lpk"
	Progress.read_progress()
	get_tree().change_scene_to_file("res://MainScene.tscn")
