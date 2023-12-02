extends Node3D

signal moved

@export var min_movement_threshold: float = 0.1
@export var movement_lerp_speed: float = 10.0

const HALF_PI: float = PI / 2.0

@onready var target_position: Vector3 = position
@onready var player_ray: RayCast3D = $PlayerRay

var is_playing: bool = false

func _process(_delta: float) -> void:
	if is_playing:
		if Input.is_action_just_pressed("up"):
			move(PI)
		elif Input.is_action_just_pressed("down"):
			move(0.0)
		elif Input.is_action_just_pressed("left"):
			move(-HALF_PI)
		elif Input.is_action_just_pressed("right"):
			move(HALF_PI)

	if not Settings.start_in_editor:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		elif Input.is_action_just_pressed("edit"):
			Settings.start_in_editor = true
			Settings.save_settings()
			get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	position = lerp(position, target_position, movement_lerp_speed * delta)

func move(angle: float) -> void:
	if position.distance_squared_to(target_position) < min_movement_threshold:
		player_ray.rotation.y = angle
		player_ray.force_raycast_update()
		var collider: Object = player_ray.get_collider()
		if collider and (collider.get_meta("is_wall", false) or (collider.get_meta("is_box", false) and not collider.push(angle))):
			return

		var direction: Vector3 = Vector3(sin(angle), 0.0, cos(angle))
		target_position += direction

		moved.emit(target_position.x, target_position.z)
