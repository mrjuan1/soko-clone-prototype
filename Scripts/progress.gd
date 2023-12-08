extends Node

var best_moves: int = 0

func load_progress() -> void:
	var progress_file: String = Levels.pack_file.replace(".lpk", ".sav")
	var file: FileAccess = FileAccess.open(progress_file, FileAccess.READ)
	if file:
		Levels.level = file.get_8()
		file.seek(1 + (Levels.level * 2))
		best_moves = file.get_16()
		print("Loaded best moves for level %d at file position %d: %d" % [Levels.level, file.get_position() - 2, best_moves])
		file.close()
	else:
		create_progress_file()

func create_progress_file() -> bool:
	var progress_file: String = Levels.pack_file.replace(".lpk", ".sav")
	var file: FileAccess = FileAccess.open(progress_file, FileAccess.WRITE)
	if file:
		file.store_8(0)
		for i in Levels.levels:
			file.store_16(0)
		file.close()
		return true

	print("Failed to create progress file \"%s\"" % progress_file)
	return false

func save_progress(moves: int = 0, dont_progress: bool = false) -> void:
	var progress_file: String = Levels.pack_file.replace(".lpk", ".sav")
	var file: FileAccess = FileAccess.open(progress_file, FileAccess.READ_WRITE)
	if file:
		if moves <= 0 or dont_progress:
			file.store_8(Levels.level)
		else:
			file.store_8(Levels.level + 1)

		if moves > 0 and (best_moves == 0 or moves < best_moves):
			file.seek(1 + (Levels.level * 2))
			file.store_16(moves)
			best_moves = moves
		elif moves == -1:
			file.seek(1 + (Levels.level * 2))
			file.store_16(0)
			best_moves = 0
		print("Saved best moves for level %d at file position %d: %d" % [Levels.level, file.get_position() - 2, best_moves])

		file.close()
	elif create_progress_file():
		save_progress(moves)
	else:
		print("Failed to save progress :(")
