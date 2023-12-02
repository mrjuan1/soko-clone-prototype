extends Camera3D

@export var camera_z_offset: float = 2.5
@export var max_x_distance: float = 3.0
@export var min_y_distance: float = -5.5
@export var max_y_distance: float = -0.5
@export var movement_lerp_speed: float = 10.0

@onready var target_position: Vector3 = position

var controller_position: Vector3 = Vector3.ZERO

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("center_camera"):
		target_position = Vector3(controller_position.x, position.y, controller_position.z + camera_z_offset)

func _physics_process(delta: float) -> void:
	position = lerp(position, target_position, movement_lerp_speed * delta)

func _on_cursor_moved(x: float, y: float) -> void:
	controller_position = Vector3(x, 0.0, y)
	var diff: Vector3 = controller_position - position

	if diff.x < -max_x_distance:
		target_position.x -= 1.0
	elif diff.x > max_x_distance:
		target_position.x += 1.0
	if diff.z < min_y_distance:
		target_position.z -= 1.0
	elif diff.z > max_y_distance:
		target_position.z += 1.0

func _on_cursor_play_mode_requested(validation_result: Levels.ValidationResult) -> void:
	if validation_result == Levels.ValidationResult.SUCCESS:
		var parent: Node3D = get_parent_node_3d()
		var player: Node = parent.player
		player.connect("moved", _on_cursor_moved)
		target_position = Vector3(player.position.x, position.y, player.position.z + camera_z_offset)
