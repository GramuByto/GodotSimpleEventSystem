extends VBoxContainer

func _init(call: Callable):
	_add_padding(self)

	var add_button_h_container := HBoxContainer.new()
	self.add_child(add_button_h_container)
	_add_padding(add_button_h_container)
	_add_padding(self)

	var add_button = Button.new()
	add_button.modulate = Color(1, 1.75, 1)
	add_button.text = '+ Add Callable'
	add_button.custom_minimum_size = Vector2(0, 40)
	add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_button_h_container.add_child(add_button)

	_add_padding(add_button_h_container)
	add_button.button_down.connect(call)

func _add_padding(container: Control):
	var padding := Container.new()
	padding.custom_minimum_size = Vector2(5, 5)
	container.add_child(padding)