extends Node

const MOVES_FILE: String = "moves.sav"

func read_level_moves() -> int:
	# print("Attempting to read level moves...")
	var file: FileAccess = FileAccess.open(MOVES_FILE, FileAccess.READ)
	if file:
		# print("  [R] Succeeded in opening moves file for reading")
		var packs: int = file.get_8()
		# print("  [R] Number of packs found: %d" % packs)
		for i in packs:
			var pack_file_len: int = file.get_8()
			var pack_file_buf: PackedByteArray = file.get_buffer(pack_file_len)
			var pack_file_str: String = pack_file_buf.get_string_from_ascii()

			if pack_file_str == Levels.pack_file:
				# print("  [R] Current pack found (%s)" % pack_file_str)
				var levels: int = file.get_8()
				for j in levels:
					var moves: int = file.get_16()
					if j == Levels.level:
						# print("  [R] Current level found (%d)" % j)
						file.close()
						# print("  [R] Moves read: %d" % moves)
						return moves

		# print("  [R] Current pack not found (%s)" % Levels.pack_file)
		file.close()
		add_current_pack()
	else:
		# print("  [R] Failed to open moves file for reading")
		if create_moves_file():
			return read_level_moves()

	# print("  [R] End of read function reached, returning 0")
	return 0

func create_moves_file() -> bool:
	# print("Attempting to create moves file...")
	var file: FileAccess = FileAccess.open(MOVES_FILE, FileAccess.WRITE)
	if file:
		# print("  [C] Succeeded in opening moves file for writing")
		file.store_8(0)
		file.close()
		# print("  [C] Empty moves file created")
		return true

	# print("Cannot create moves file")
	return false

func add_current_pack() -> void:
	# print("Attempting to add current pack to moves file...")
	var file: FileAccess = FileAccess.open(MOVES_FILE, FileAccess.READ_WRITE)
	if file:
		# print("  [A] Succeeded in opening moves file for reading and writing")
		var packs: int = file.get_8()
		# print("  [A] Number of packs found: %d" % packs)
		packs += 1
		file.seek(0)
		file.store_8(packs)
		# print("  [A] Number of packs updated: %d" % packs)

		file.seek_end()
		file.store_8(len(Levels.pack_file))
		file.store_string(Levels.pack_file)
		# print("  [A] Pack file name stored (%s)" % Levels.pack_file)

		file.store_8(Levels.levels)
		# print("  [A] Number of levels stored: %d" % Levels.levels)
		for i in Levels.levels:
			file.store_16(0)

		file.close()
		# print("  [A] Initial moves values stored for each level")
	elif create_moves_file():
		# print("  [A] Failed to open moves file for reading and writing")
		add_current_pack()

func save_level_moves(moves: int) -> void:
	# print("Attempting to save level moves...")
	var file: FileAccess = FileAccess.open(MOVES_FILE, FileAccess.READ_WRITE)
	if file:
		# print("  [S] Succeeded in opening moves file for reading and writing")
		var packs: int = file.get_8()
		# print("  [S] Number of packs found: %d" % packs)
		for i in packs:
			var pack_file_len: int = file.get_8()
			var pack_file_buf: PackedByteArray = file.get_buffer(pack_file_len)
			var pack_file_str: String = pack_file_buf.get_string_from_ascii()

			if pack_file_str == Levels.pack_file:
				# print("  [S] Current pack found (%s)" % pack_file_str)
				var levels: int = file.get_8()
				for j in levels:
					if j == Levels.level:
						# print("  [S] Current level found (%d)" % j)
						file.store_16(moves)
						file.close()
						# print("  [S] Moves saved: %d" % moves)
						return
					else:
						file.get_16()

		# print("  [S] Current pack not found (%s)" % Levels.pack_file)
		file.close()
		add_current_pack()
	elif create_moves_file():
		# print("  [S] Failed to open moves file for reading and writing")
		save_level_moves(moves)
