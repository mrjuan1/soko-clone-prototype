extends Button

@onready var item_list: ItemList = %ItemList

func _pressed() -> void:
	var indices: PackedInt32Array = item_list.get_selected_items()
	if indices:
		var index = indices[0]
		item_list.item_activated.emit(index)
