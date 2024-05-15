extends MarginContainer

var object: Object

func _init(obj: Object, text:String):
	match text:
		'Add Function':
			_add_function(obj, text)
		_:
			if text.begins_with('!!'):
				_type_button(obj, text.substr(2, text.length()))
			else:
				_function_button(obj, text)

func add_option_button() -> OptionButton:
	var button := OptionButton.new()
	button.size_flags_horizontal = Control.SIZE_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.allow_reselect = true
	return button

func _add_function(obj: Object, text:String):
	var button:= Button.new()

	size_flags_horizontal = Control.SIZE_FILL
	button.text = 'Add Function'
	add_child(button)

	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.button_down.connect(_add_function_logic.bind(obj))

func _add_function_logic(obj: Object):
	print(obj.get_script())
	var node = Node.new()
	obj.add_child(node)
	node.owner = get_tree().edited_scene_root
	node.name = '<SimpleEventFunction>'
	node.set_script(SimpleEventFunction)

func _function_button(obj: Object, text:String):
	var button = add_option_button()
	var function_list = (obj as SimpleEventFunction).get_all_node_functions()
	
	if(function_list.size() == 0):
		return

	for i in function_list:
		button.add_item(i)
	
	var cur_index = -1
	
	for item_index in range(button.item_count):
		if button.get_item_text(item_index) == text:
			cur_index = item_index
			break
		
	if cur_index != -1:
		button.selected = cur_index
		button.text = text
	else:
		button.text = '!!!(Function Missing)!!!'
		obj.name = '!!!(Function Missing)!!!'

	add_child(button)
	
	button.item_selected.connect(_on_function_change.bind(obj, button))
	notify_property_list_changed()

func _type_button(obj: Object, text:String):
	var button = add_option_button()
	var type_list = (obj as SimpleEventFunction).get_all_node_types()

	if(type_list.size() == 0):
		return

	for i in type_list:
		button.add_item(i)

	var cur_index = -1
	
	for item_index in range(button.item_count):
		if button.get_item_text(item_index) == text:
			cur_index = item_index
			break
		
	if cur_index != -1:
		button.selected = cur_index
		button.text = text
	else:
		button.text = '!!!(Class Missing)!!!'
		obj.name = '!!!(Class Missing)!!!'

	add_child(button)
	button.item_selected.connect(_on_type_change.bind(obj, button))
	notify_property_list_changed()

func _on_function_change(index: int, obj: Object, button: OptionButton):
	obj._on_function_change_selected(button.get_item_text(index))

func _on_type_change(index: int, obj: Object, button: OptionButton):
	obj._on_type_change_selected(button.get_item_text(index))
