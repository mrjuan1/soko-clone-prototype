extends CharacterBody3D

@export var movement_lerp_speed: float = 10.0

@onready var box_ray: RayCast3D = $BoxRay
@onready var parent: Node3D = get_parent_node_3d()

var target_position: Vector3
var active: bool = false

func _physics_process(delta: float) -> void:
	if active:
		parent.position = lerp(parent.position, target_position, movement_lerp_speed * delta)

func push(angle: float) -> bool:
	box_ray.rotation.y = angle
	box_ray.force_raycast_update()
	var collider: Object = box_ray.get_collider()
	if collider and (collider.get_meta("is_wall", false) or collider.get_meta("is_box", false)):
		return false

	var direction: Vector3 = Vector3(sin(angle), 0.0, cos(angle))
	target_position += direction

	return true
