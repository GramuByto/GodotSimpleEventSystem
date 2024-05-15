extends EditorInspectorPlugin

var InspectorToolButton = preload("simple_event_tool.gd")
var AddButton = preload("simple_event_add_button.gd")

func _can_handle(object) -> bool:
	return true

func _parse_property(object: Object, type: Variant.Type, name: String, 
	hint_type: PropertyHint, hint_string: String, usage_flags, wide: bool):

#region Legacy

	var target_class = object as SimpleEvent
	var strings_to_match = ['process_mode', 'process_priority', 'process_physics_priority', 'process_thread_group', 'script', '_refresh_interval']
	
	if target_class != null:
		if name == 'add_function_button':
			add_custom_control(InspectorToolButton.new(object, 'Add Function'))
			return true #Returning true removes the built-in editor for this property
		if string_matches_any(name, strings_to_match):
			return true;

	target_class = object as SimpleEventFunction

	if target_class != null:
		if name == 'function_name':
			add_custom_control(InspectorToolButton.new(object, target_class.function_name))
			return true
		elif name == 'type_name':
			add_custom_control(InspectorToolButton.new(object, "!!" + target_class.type_name))
			return true
		elif string_matches_any(name, strings_to_match):
			return true;
	
	


#endregion
	target_class = object as SimpleEventSystem

	if target_class != null:
		var callable_index = target_class._cur_index

		if callable_index == -1 and target_class._callable_nodes.size() != 0:
			target_class._select_callable(0)

		if callable_index == -1:
			return true
		
		if name == '_type_name':
			var type_list = target_class._get_all_node_types(callable_index)
			
			if type_list.size() != 0:
				var callable = target_class._callable_values[callable_index]
				var button:= add_option_button()
				var cur_index:= -1

				add_custom_control(button)
				button.item_selected.connect(_on_type_change.bind(target_class, button))

				for item_index in range(type_list.size()):
					button.add_item(type_list[item_index])
					if cur_index == -1:
						if type_list[item_index] == callable[0]:
							cur_index = item_index
			
				if cur_index != -1:
					button.selected = cur_index
					button.text = callable[0]
				else:
					callable[0] = _get_class_missing_text()
					button.text = _get_class_missing_text()
					target_class._type_name = _get_class_missing_text()
			else:
				_add_empty_space(30)
			return true
		elif name == '_function_name':
			var function_list = target_class._get_all_node_functions(callable_index)
	
			if function_list.size() != 0:
				var callable = target_class._callable_values[callable_index]
				var button = add_option_button()
				var cur_index:= -1

				add_custom_control(button)
				button.item_selected.connect(_on_function_change.bind(target_class, button))

				for item_index in range(function_list.size()):
					button.add_item(function_list[item_index])
					if cur_index == -1:
						if function_list[item_index] == callable[1]:
							cur_index = item_index
		
				if cur_index != -1:
					button.selected = cur_index
					button.text = callable[1]
				else:
					callable[1] = _get_function_missing_text()
					button.text = _get_function_missing_text()
					target_class._function_name = _get_function_missing_text()
			else:
				_add_empty_space(30)
			return true
		elif name == '_args':
			if target_class._function_name == '' or target_class._function_name == _get_function_missing_text():
				_add_empty_space(30)
				return true
		elif name == '_callable_values' || name == '_callable_nodes':
			return !target_class._show_raw_data
		elif string_matches_any(name, strings_to_match):
			return true

	return false

func _add_empty_space(height: int):
	var space := Container.new()
	space.custom_minimum_size = Vector2(0, height)
	add_custom_control(space)

func _on_type_change(index: int, obj: SimpleEventSystem, button: OptionButton):
	obj._type_name = button.get_item_text(index)

func _on_function_change(index: int, obj: SimpleEventSystem, button: OptionButton):
	obj._function_name = button.get_item_text(index)
	obj._update_parameters()

func add_option_button() -> OptionButton:
	var button := OptionButton.new()
	button.size_flags_horizontal = Control.SIZE_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.allow_reselect = true
	return button

func string_matches_any(name: String, strings_to_match) -> bool:
	for option in strings_to_match:
		if name == option:
			return true
	return false

func _parse_category(object, category):
	var target_class = object as SimpleEventSystem

	if category == 'simple_event_system.gd' and target_class != null:
		add_custom_control(AddButton.new(target_class._add_callable))

		if target_class._cur_index == -1:
			_add_empty_space(136)

func _parse_group(object, group):
	var target_class = object as SimpleEventSystem

	if group == 'Callables' and target_class != null:
		var callables = target_class._callable_values

		if callables != null:
			var index: int = 0
			for callable in callables:
				var hbox_container = HBoxContainer.new()
				hbox_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				add_custom_control(hbox_container)
				
				var vbox_container = VBoxContainer.new()
				var size = vbox_container.get_minimum_size()
				size.x = 30
				vbox_container.custom_minimum_size = size
				hbox_container.add_child(vbox_container)

				var up_button = Button.new()
				up_button.text = 'Λ'

				if index == 0:
					up_button.disabled = true
				else:
					up_button.modulate = Color(1.5, 1.5, 1.5)
					up_button.button_down.connect(target_class._move_callable.bind(index, true))
				vbox_container.add_child(up_button)

				var down_button = Button.new()
				down_button.text = 'V'
				if index + 1 == target_class._callable_values.size():
					down_button.disabled = true
				else:
					down_button.modulate = Color(1.5, 1.5, 1.5)
					down_button.button_down.connect(target_class._move_callable.bind(index, false))
				vbox_container.add_child(down_button)
				
				var callable_button = Button.new()
				var button_name = '<<SimpleEventCallable>>'
				var callable_node = target_class._callable_nodes[index]

				if _verify_node(callable_node):
					button_name = callable_node.name
					if callable[0] != _get_class_missing_text():
						button_name += '.' + callable[0] + '\n'
						if callable[1] != _get_function_missing_text():
							button_name += callable[1]
						else:
							button_name += _get_function_missing_text()
					else:
						button_name += '\n' + _get_class_missing_text()

				callable_button.text = button_name	#Revise This
				callable_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				callable_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
				var col:= Color(1.5, 1.5, 1.5)
				
				if index == target_class._cur_index:
					col = Color(1.75, 1.75, 1.25)

				callable_button.modulate = col

				var delete_button = Button.new()
				delete_button.text = 'X'
				delete_button.modulate = Color(1.75, 1, 1)
				delete_button.custom_minimum_size = Vector2(30, 0)

				hbox_container.add_child(callable_button)
				hbox_container.add_child(delete_button)
				delete_button.button_down.connect(target_class._delete_callable.bind(index))
				callable_button.button_down.connect(target_class._select_callable.bind(index))
				
				index += 1

func _verify_node(node: Node) -> bool:
	if node != null:
		if node.is_inside_tree():
			return true
	return false

func _get_class_missing_text() -> String:
	return '!!!(Class Missing)!!!'

func _get_function_missing_text() -> String:
	return '!!!(Function Missing)!!!'
