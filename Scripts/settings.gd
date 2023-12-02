extends Node

const SETTINGS_FILE: String = "settings.json"

var start_in_editor: bool = false
var show_help: bool = true

func _ready() -> void:
	var settings_str: String = FileAccess.get_file_as_string(SETTINGS_FILE)
	if settings_str:
		var settings: Variant = JSON.parse_string(settings_str)
		if settings:
			Levels.level = settings.level - 1
			Levels.pack_file = settings.pack_file
			show_help = settings.show_help
			start_in_editor = settings.start_in_editor
		else:
			print("Failed to load settings, reverting to defaults")
			save_settings()
	else:
		save_settings()

func save_settings() -> void:
	var file: FileAccess = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file:
		var settings: Dictionary = {
			"level": Levels.level + 1,
			"pack_file": Levels.pack_file,
			"show_help": show_help,
			"start_in_editor": start_in_editor
		}
		var settings_str: String = JSON.stringify(settings, "\t")
		file.store_string(settings_str)
		file.close()
	else:
		print("Failed to save settings")
