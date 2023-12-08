extends Node3D

signal starting_edit_mode
signal moved
signal selected_object_changed
signal object_placed
signal object_deleted
signal level_saved
signal level_loaded
signal level_cleared
signal level_changed
signal play_mode_requested

@export var movement_lerp_speed: float = 10.0

@onready var target_position: Vector3 = position
@onready var objects: Array[Node3D] = [
	%Floor,
	%Player,
	%Box,
	%Target
]
@onready var object_resources: Array[Resource] = [
	preload("res://Objects/Floor.tscn"),
	preload("res://Objects/Player.tscn"),
	preload("res://Objects/Box.tscn"),
	preload("res://Objects/Target.tscn")
]
@onready var parent: Node3D = get_parent_node_3d()
@onready var wall_resource: Resource = preload("res://Objects/Wall.tscn")

const HALF_PI: float = PI / 2.0

var selected_object: int = Levels.OT_FLOOR
var level_objects: Array[Array] = []

var first_frame: bool = true

func _process(_delta: float) -> void:
	if first_frame:
		initialise()
		first_frame = false
	elif Input.is_action_just_pressed("up"):
		target_position.z -= 1.0
		moved.emit(target_position.x, target_position.z)
	elif Input.is_action_just_pressed("down"):
		target_position.z += 1.0
		moved.emit(target_position.x, target_position.z)
	elif Input.is_action_just_pressed("left"):
		target_position.x -= 1.0
		moved.emit(target_position.x, target_position.z)
	elif Input.is_action_just_pressed("right"):
		target_position.x += 1.0
		moved.emit(target_position.x, target_position.z)
	elif Input.is_action_just_pressed("next_object"):
		change_selected_object(1)
	elif Input.is_action_just_pressed("prev_object"):
		change_selected_object(-1)
	elif Input.is_action_just_pressed("place"):
		place_selected_object()
	elif Input.is_action_just_pressed("delete"):
		delete_object()
	elif Input.is_action_just_pressed("save"):
		save_level()
	elif Input.is_action_just_pressed("load"):
		load_level()
	elif Input.is_action_just_pressed("clear"):
		clear_level()
	elif Input.is_action_just_pressed("next_level"):
		change_level(1)
	elif Input.is_action_just_pressed("prev_level"):
		change_level(-1)
	elif Input.is_action_just_pressed("play"):
		play_level()

func _physics_process(delta: float) -> void:
	position = lerp(position, target_position, movement_lerp_speed * delta)

func initialise() -> void:
	Levels.load_level(true)
	if Settings.start_in_editor:
		Progress.load_progress()
	load_level()
	level_changed.emit()

	if Settings.start_in_editor:
		starting_edit_mode.emit()
	elif not play_level():
		Settings.start_in_editor = true
		Settings.save_settings()
		starting_edit_mode.emit()

func change_selected_object(direction: int) -> void:
	selected_object += direction

	if selected_object < Levels.OT_FLOOR:
		selected_object = Levels.OT_TARGET
	elif selected_object > Levels.OT_TARGET:
		selected_object = Levels.OT_FLOOR

	for i in 4:
		if i > 0:
			objects[i].visible = false
	objects[selected_object].visible = true

	selected_object_changed.emit(selected_object)

func place_selected_object() -> void:
	var grid_x: int = Levels.LEVEL_HALF_X_SIZE + int(target_position.x)
	var grid_y: int = Levels.LEVEL_HALF_Y_SIZE + int(target_position.z)

	if Levels.level_grid[grid_x][grid_y] > 0:
		object_deleted.emit(Levels.level_grid[grid_x][grid_y] - 1)

	Levels.level_grid[grid_x][grid_y] = selected_object + 1
	Levels.level_changed = true

	if not level_objects[grid_x][grid_y][0]:
		level_objects[grid_x][grid_y][0] = object_resources[Levels.OT_FLOOR].instantiate()
		level_objects[grid_x][grid_y][0].position = target_position
		parent.add_child(level_objects[grid_x][grid_y][0]);

	if level_objects[grid_x][grid_y][1]:
		level_objects[grid_x][grid_y][1].queue_free()
		level_objects[grid_x][grid_y][1] = null

	if selected_object > 0:
		level_objects[grid_x][grid_y][1] = object_resources[selected_object].instantiate()
		level_objects[grid_x][grid_y][1].position = target_position
		parent.add_child(level_objects[grid_x][grid_y][1]);

	object_placed.emit(selected_object)

func delete_object() -> void:
	var grid_x: int = Levels.LEVEL_HALF_X_SIZE + int(target_position.x)
	var grid_y: int = Levels.LEVEL_HALF_Y_SIZE + int(target_position.z)

	var object_type: int = Levels.level_grid[grid_x][grid_y] - 1
	Levels.level_grid[grid_x][grid_y] = 0
	Levels.level_changed = true

	for i in 2:
		if level_objects[grid_x][grid_y][i]:
			level_objects[grid_x][grid_y][i].queue_free()
			level_objects[grid_x][grid_y][i] = null

	object_deleted.emit(object_type)

func save_level() -> void:
	Levels.save_level()
	level_saved.emit()

func load_level() -> void:
	clear_level_objects()
	Levels.load_level()
	populate_level()
	level_loaded.emit()

func populate_level() -> void:
	for x in Levels.LEVEL_X_SIZE:
		for y in Levels.LEVEL_Y_SIZE:
			if Levels.level_grid[x][y] > 0:
				var world_x: float = float(x - Levels.LEVEL_HALF_X_SIZE)
				var world_z: float = float(y - Levels.LEVEL_HALF_Y_SIZE)

				level_objects[x][y][0] = object_resources[Levels.OT_FLOOR].instantiate()
				level_objects[x][y][0].position.x = world_x
				level_objects[x][y][0].position.z = world_z
				parent.add_child(level_objects[x][y][0])

				if Levels.level_grid[x][y] > 1:
					var index: int = Levels.level_grid[x][y] - 1
					level_objects[x][y][1] = object_resources[index].instantiate()
					level_objects[x][y][1].position.x = world_x
					level_objects[x][y][1].position.z = world_z
					parent.add_child(level_objects[x][y][1])

					object_placed.emit(index)

func clear_level_objects() -> void:
	if len(level_objects) > 0:
		for x in Levels.LEVEL_X_SIZE:
			for y in Levels.LEVEL_Y_SIZE:
				for i in 2:
					if level_objects[x][y][i]:
						level_objects[x][y][i].queue_free()
						level_objects[x][y][i] = null
						if i == 1:
							var index: int = Levels.level_grid[x][y] - 1
							object_deleted.emit(index)
	else:
		for x in Levels.LEVEL_X_SIZE:
			level_objects.append([])
			for y in Levels.LEVEL_Y_SIZE:
				level_objects[x].append([null, null])

func clear_level() -> void:
	clear_level_objects()
	Levels.clear_level()
	level_cleared.emit()

func change_level(direction: int) -> void:
	if Levels.level + direction >= 0:
		clear_level_objects()

		if direction > 0:
			Levels.next_level()
		else:
			Levels.prev_level()
		Progress.save_progress()

		populate_level()
		level_changed.emit()

func play_level() -> bool:
	var result: Levels.ValidationResult = Levels.validate_level()
	if result == Levels.ValidationResult.SUCCESS:
		save_level()
		Settings.start_in_editor = false
		Settings.save_settings()
		place_walls()
		play_mode_requested.emit(result)
		queue_free()
		return true
	else:
		play_mode_requested.emit(result)
		return false

func place_walls() -> void:
	for x in Levels.LEVEL_X_SIZE:
		for y in Levels.LEVEL_Y_SIZE:
			if Levels.level_grid[x][y] > 0:
				var new_x: int = x - 1
				if new_x == -1 or Levels.level_grid[new_x][y] == 0:
					place_wall(new_x, y, HALF_PI)

				new_x = x + 1
				if new_x == Levels.LEVEL_X_SIZE or Levels.level_grid[new_x][y] == 0:
					place_wall(new_x, y, -HALF_PI)

				var new_y: int = y - 1
				if new_y == -1 or Levels.level_grid[x][new_y] == 0:
					place_wall(x, new_y, 0)

				new_y = y + 1
				if new_y == Levels.LEVEL_X_SIZE or Levels.level_grid[x][new_y] == 0:
					place_wall(x, new_y, PI)

func place_wall(x: int, y: int, angle: float) -> void:
	var wall: Node3D = wall_resource.instantiate()
	wall.position.x = float(x - Levels.LEVEL_HALF_X_SIZE)
	wall.position.z = float(y - Levels.LEVEL_HALF_Y_SIZE)
	wall.rotation.y = angle
	parent.add_child(wall)
