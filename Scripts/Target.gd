extends Node3D

signal entered
signal exited

const ENTERED_HUE: float = 135.0 / 360.0

@export var movement_lerp_speed: float = 10.0
@export var colour_lerp_speed: float = 10.0

@onready var target_mesh: MeshInstance3D = $TargetMesh
@onready var target_animation: AnimationPlayer = $TargetAnimation
@onready var target_y: float = position.y

var material: StandardMaterial3D
var target_hue: float

var is_playing: bool = false

func _ready() -> void:
	target_mesh.mesh = target_mesh.mesh.duplicate()
	target_mesh.mesh.material = target_mesh.mesh.material.duplicate()
	material = target_mesh.mesh.material
	target_hue = material.albedo_color.h
	target_animation.play("hover")

func _physics_process(delta: float) -> void:
	position.y = lerpf(position.y, target_y, movement_lerp_speed * delta)
	target_mesh.rotation_degrees.y -= 45.0 * delta
	material.albedo_color.h = lerp(material.albedo_color.h, target_hue, colour_lerp_speed * delta)

func _on_target_area_body_entered(body: Node3D) -> void:
	if is_playing and body.get_meta("is_box", false):
		target_y = 0.75
		target_hue = ENTERED_HUE
		entered.emit()

func _on_target_area_body_exited(body: Node3D) -> void:
	if is_playing and body.get_meta("is_box", false):
		target_y = 0.0
		target_hue = 0.0
		exited.emit()
