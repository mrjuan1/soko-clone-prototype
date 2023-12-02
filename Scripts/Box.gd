extends Node3D

@onready var box_body: CharacterBody3D = $BoxBody

func prepare() -> void:
	box_body.target_position = position
	box_body.active = true
