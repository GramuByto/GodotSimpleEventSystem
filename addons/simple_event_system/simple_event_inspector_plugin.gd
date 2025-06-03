extends EditorInspectorPlugin

const strings_to_match = ['process_mode', 'process_priority', 'process_physics_priority', 'process_thread_group', '_refresh_interval', 'physics_interpolation_mode']
const unhidable_variables = ['editor_description', 'global_event', 'pre_invoked_event']
var space_height

func _init():
	var display_scale = EditorInterface.get_editor_settings().get("interface/editor/display_scale")
	space_height = 32	#option zero on display_scale

	if display_scale == 1:
		space_height = 24
	elif display_scale > 2:
		display_scale -= 2
		space_height += (display_scale * 8)

func _can_handle(object) -> bool:
	return true

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags, wide: bool):
	var target_class = object as SimpleEvent
	
	if target_class != null:
		if _string_matches_any(name, strings_to_match):
			return true
		if name == '_signal_name':
			if target_class._get_source() == null:
				_add_panel_container(Color.AQUAMARINE)
				return true

			var label := Label.new()
			label.text = 'Signal:    '
			var hbox := HBoxContainer.new()
			add_custom_control(hbox)
			hbox.add_child(label)
			_add_panel_container(Color.AQUAMARINE)

			var option_button := OptionButton.new()
			var type_list = _get_all_node_types(target_class._get_source())
			var temp_signal_list = target_class._get_source().get_signal_list()
			option_button.text = _get_signal_missing_text()
			option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			option_button.alignment = HORIZONTAL_ALIGNMENT_CENTER

			for type_name in type_list:
				var signal_list = temp_signal_list.duplicate()	#What will be left are the custom classes

				if not '.' in type_name:
					signal_list = ClassDB.class_get_signal_list(type_name, true)	#This doesn't work for custom classes

				if signal_list.size() == 0:
					continue

				var popup = PopupMenu.new()
				popup.name = type_name
				popup.index_pressed.connect(_on_signal_change.bind(target_class, popup))
				option_button.get_popup().add_submenu_node_item(popup.name, popup)

				for signal_item in signal_list:
					var signal_text = signal_item['name'] + '('
					var args = signal_item['args']

					for arg in args:
						signal_text = signal_text + arg['name'] + ','

					if args.size() != 0:
						signal_text = signal_text.rstrip(signal_text[-1])

					signal_text = signal_text + ')'

					popup.add_item(signal_text)

					if signal_text == target_class._signal_name:
						option_button.text = target_class._signal_name

					for temp_signal in temp_signal_list:
						if temp_signal['name'] == signal_item['name']:
							temp_signal_list.erase(temp_signal)	#From all signals, erase all signals from built-in classes
							break

			if option_button.text == _get_signal_missing_text():
				target_class._signal_name = _get_signal_missing_text()

			hbox.add_child(option_button)
			return true
		if name == '_signal_source_node_path':
			if target_class._signal_source_resource != null:
				target_class._signal_source_node_path = ''	#just in case
				return true
		if name == '_signal_source_resource':
			if target_class._get_source_node() != null:
				target_class._signal_source_resource = null	#just in case
				return true

	target_class = object as SimpleEventData

	if _string_matches_any(name, unhidable_variables):
		return false

	if target_class != null:
		if name == '_node_path_target':
			var panel_height = space_height
			_add_panel_container(Color.BEIGE)
			return target_class._resource_target != null

		if name == '_resource_target':
			return target_class._get_node() != null

		if target_class._get_target() == null:
			if name == '_function_name':
				return true	#Don't add space if it's type_name if no target yet
			return _add_empty_space(space_height)

		if name == "_function_name":
			var type_list = _get_all_node_types(target_class._get_target())
			var option_button = OptionButton.new()
			option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			option_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
			option_button.text = _get_function_missing_text()
			add_custom_control(option_button)

			for type_name in type_list:
				var popup = PopupMenu.new()
				var f_list = target_class._get_all_node_functions(type_name)
				var dot_index = type_name.rfind('.')	#For custom classes
				popup.name = type_name

				if dot_index != -1:
					popup.name = type_name.substr(0, dot_index)

				popup.index_pressed.connect(_on_function_name_change.bind(target_class, popup))
				option_button.get_popup().add_submenu_node_item(popup.name, popup)

				for function_name in f_list:
					popup.add_item(function_name)

					if function_name == target_class._get_function_name():
						option_button.text = popup.name + "." + function_name

			if option_button.text == _get_function_missing_text():
				target_class._function_name = _get_function_missing_text()

			return true
		elif name == '_is_dynamic':
			if target_class._function_name == '' or target_class._function_name == _get_function_missing_text() or target_class._args.size() == 0:
				return _add_empty_space(space_height)
		elif name == '_args':
			if target_class._function_name == '' or target_class._function_name == _get_function_missing_text() or target_class._args.size() == 0 or target_class._is_dynamic:
				return _add_empty_space(space_height)

	return false

func _get_all_node_types(target) -> Array:
	var inherited_classes:= []

	if target != null:
		var script = target.get_script()
		var node_class = target.get_class()
		var count = 25	#To not get stuck in a while loop. I doubt there are scripts that will reach this much inheriting, right?

		if script != null:
			var paths = script.get_path().split('/')
			inherited_classes.insert(0, paths[paths.size() - 1])
		
		while node_class != '' and count > 0:
			count -= 1
			inherited_classes.insert(0, node_class)
			node_class = ClassDB.get_parent_class(node_class)

	return inherited_classes

func _add_empty_space(height) -> bool:
	var space := Container.new()
	space.custom_minimum_size = Vector2(0, height)
	add_custom_control(space)
	return true

func _add_panel_container(panel_color: Color) -> PanelContainer:
	var panel_container := PanelContainer.new()
	panel_container.custom_minimum_size = Vector2(0, space_height / 2)
	
	add_custom_control(panel_container)
	var cr := ColorRect.new()
	cr.color = panel_color
	panel_container.add_child(cr)
	cr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := Label.new()
	cr.add_child(label)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return panel_container

func _on_signal_change(index: int, obj: SimpleEvent, popup: PopupMenu):
	obj._signal_name = popup.get_item_text(index)

func _on_function_name_change(index: int, obj: SimpleEventData, popup: PopupMenu):
	obj._function_name = popup.name + "." + popup.get_item_text(index)
	obj._update_parameters()

func _string_matches_any(name: String, strings_to_match) -> bool:
	for option in strings_to_match:
		if name == option:
			return true
	return false

func _get_signal_missing_text() -> String:
	return '!!! Signal Missing !!!'

func _get_function_missing_text() -> String:
	return '!!! Function Missing !!!'