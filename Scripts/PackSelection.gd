extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit") and OS.get_name() != "Web":
		get_tree().quit()
