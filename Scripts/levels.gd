extends Node

enum ValidationResult { SUCCESS, NOT_ONE_PLAYER, BOX_TARGET_MISMATCH }

const LEVEL_X_SIZE: int = 100
const LEVEL_Y_SIZE: int = 100

@warning_ignore("integer_division")
const LEVEL_HALF_X_SIZE: int = LEVEL_X_SIZE / 2
@warning_ignore("integer_division")
const LEVEL_HALF_Y_SIZE: int = LEVEL_Y_SIZE / 2

const LEVEL_SIZE: int = LEVEL_X_SIZE * LEVEL_Y_SIZE

const OT_FLOOR: int = 0
const OT_PLAYER: int = 1
const OT_BOX: int = 2
const OT_TARGET: int = 3

var filename_prefix: String = ""
var pack_file: String = "Original Levels.lpk"
var levels: int = 0

var level: int = 0
var level_grid: Array[Array] = []
var level_changed: bool = false

func _ready() -> void:
	if OS.get_name() == "Web":
		filename_prefix = "user://"

func load_level(only_levels: bool = false) -> void:
	var file: FileAccess = FileAccess.open(filename_prefix + pack_file, FileAccess.READ)
	if file:
		levels = file.get_8()
		if only_levels:
			file.close()
			return

		if level == levels:
			file.close()
			clear_level()
			save_level()
		else:
			if len(level_grid) == 0:
				clear_level()

			file.seek(1 + (level * LEVEL_SIZE))
			for x: int in LEVEL_X_SIZE:
				for y: int in LEVEL_Y_SIZE:
					level_grid[x][y] = file.get_8()
			file.close()

			level_changed = false
	else:
		clear_level()
		save_level()

func save_level() -> void:
	if level_changed:
		var file: FileAccess = FileAccess.open(filename_prefix + pack_file, FileAccess.READ_WRITE)
		if file == null:
			file = FileAccess.open(filename_prefix + pack_file, FileAccess.WRITE)

		if level == levels:
			levels += 1
		file.store_8(levels)

		file.seek(1 + (level * LEVEL_SIZE))
		for x: int in LEVEL_X_SIZE:
			for y: int in LEVEL_Y_SIZE:
				file.store_8(level_grid[x][y])
		file.close()

		Progress.save_progress(-1)

		level_changed = false

func clear_level() -> void:
	level_grid = []
	for x: int in LEVEL_X_SIZE:
		level_grid.append([])
		for y: int in LEVEL_Y_SIZE:
			level_grid[x].append(0)
	level_changed = true

func next_level() -> void:
	save_level()
	level += 1
	load_level()

func prev_level() -> void:
	if level - 1 >= 0:
		save_level()
		level -= 1
		load_level()

func validate_level() -> ValidationResult:
	var players: int = 0
	var boxes: int = 0
	var targets: int = 0

	for x: int in LEVEL_X_SIZE:
		for y: int in LEVEL_Y_SIZE:
			match level_grid[x][y] - 1:
				OT_PLAYER:
					players += 1
					if players > 1:
						return ValidationResult.NOT_ONE_PLAYER
				OT_BOX:
					boxes += 1
				OT_TARGET:
					targets += 1

	if players != 1:
		return ValidationResult.NOT_ONE_PLAYER
	elif boxes == 0 or targets == 0 or boxes != targets:
		return ValidationResult.BOX_TARGET_MISMATCH
	else:
		return ValidationResult.SUCCESS
