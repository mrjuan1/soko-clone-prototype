extends Node

const SETTINGS_FILE: String = "settings.json"

var filename_prefix: String = ""
var start_in_editor: bool = false
var show_help: bool = true

func _ready() -> void:
	if OS.get_name() == "Web":
		filename_prefix = "user://"

	var settings_str: String = FileAccess.get_file_as_string(filename_prefix + SETTINGS_FILE)
	if settings_str:
		var settings: Variant = JSON.parse_string(settings_str)
		if settings:
			show_help = settings.show_help
			start_in_editor = settings.start_in_editor
		else:
			print("Failed to load settings, reverting to defaults")
			save_settings()
	else:
		save_settings()

func save_settings() -> void:
	var file: FileAccess = FileAccess.open(filename_prefix + SETTINGS_FILE, FileAccess.WRITE)
	if file:
		var settings: Dictionary = {
			"show_help": show_help,
			"start_in_editor": start_in_editor
		}
		var settings_str: String = JSON.stringify(settings, "\t")
		file.store_string(settings_str)
		file.close()
	else:
		print("Failed to save settings")
