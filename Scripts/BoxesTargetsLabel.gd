extends Label

var boxes: int = 0
var targets: int = 0

func _ready() -> void:
	label_settings.font_color = Color.WHITE

func _on_cursor_object_placed(object_type: int) -> void:
	match object_type:
		Levels.OT_BOX:
			boxes += 1
		Levels.OT_TARGET:
			targets += 1
	update_text()

func _on_cursor_object_deleted(object_type: int) -> void:
	match object_type:
		Levels.OT_BOX:
			boxes -= 1
		Levels.OT_TARGET:
			targets -= 1
	update_text()

func update_text() -> void:
	var note: String = ""

	if boxes > 0 and boxes == targets:
		label_settings.font_color = Color.GREEN
	elif boxes > targets:
		note = " (%d too many)" % (boxes - targets)
		label_settings.font_color = Color.RED
	else:
		label_settings.font_color = Color.WHITE

	text = "Boxes/Targets: %d/%d %s" % [boxes, targets, note]
