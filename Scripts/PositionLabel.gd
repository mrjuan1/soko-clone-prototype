extends Label

func _ready() -> void:
	_on_cursor_moved(0.0, 0.0)

func _on_cursor_moved(x: float, y: float) -> void:
	text = "Position: %.0fx%.0f" % [x, y]
