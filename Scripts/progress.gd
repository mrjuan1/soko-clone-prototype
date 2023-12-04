extends Node

const PROGRESS_FILE: String = "progress.sav"

var moves: int = 0

func read_progress(only_level: bool = false) -> void:
	var file: FileAccess = FileAccess.open(PROGRESS_FILE, FileAccess.READ)
	if file:
		var packs: int = file.get_8()
		for i in packs:
			var pack_file_len: int = file.get_8()
			var pack_file_buf: PackedByteArray = file.get_buffer(pack_file_len)
			var pack_file_str: String = pack_file_buf.get_string_from_ascii()

			if pack_file_str == Levels.pack_file:
				Levels.level = file.get_8()
				if only_level:
					file.close()
					return

				var levels: int = file.get_8()
				for j in levels:
					moves = file.get_16()
					if j == Levels.level:
						file.close()
						return

		file.close()
		add_current_pack()
	elif create_progress_file():
		read_progress(only_level)

func create_progress_file() -> bool:
	var file: FileAccess = FileAccess.open(PROGRESS_FILE, FileAccess.WRITE)
	if file:
		file.store_8(0)
		file.close()
		return true

	return false

func add_current_pack() -> void:
	var file: FileAccess = FileAccess.open(PROGRESS_FILE, FileAccess.READ_WRITE)
	if file:
		var packs: int = file.get_8()
		packs += 1
		file.seek(0)
		file.store_8(packs)

		file.seek_end()
		file.store_8(len(Levels.pack_file))
		file.store_string(Levels.pack_file)

		file.store_8(Levels.level)
		file.store_8(Levels.levels)
		for i in Levels.levels:
			file.store_16(0)

		file.close()
	elif create_progress_file():
		add_current_pack()

func save_progress(new_moves: int = 0, progress_level: bool = false) -> void:
	if moves == 0 or (new_moves > 0 and new_moves < moves):
		moves = new_moves

	var file: FileAccess = FileAccess.open(PROGRESS_FILE, FileAccess.READ_WRITE)
	if file:
		var packs: int = file.get_8()
		for i in packs:
			var pack_file_len: int = file.get_8()
			var pack_file_buf: PackedByteArray = file.get_buffer(pack_file_len)
			var pack_file_str: String = pack_file_buf.get_string_from_ascii()

			if pack_file_str == Levels.pack_file:
				if progress_level:
					file.store_8(Levels.level + 1)
				else:
					file.store_8(Levels.level)

				if new_moves == 0 or moves != new_moves:
					file.close()
					return

				var levels: int = file.get_8()
				for j in levels:
					if j == Levels.level:
						file.store_16(moves)
						if progress_level:
							moves = file.get_16()
							Levels.next_level()

						file.close()
						return
					else:
						file.get_16()

		file.close()
		add_current_pack()
	elif create_progress_file():
		save_progress(new_moves, progress_level)
