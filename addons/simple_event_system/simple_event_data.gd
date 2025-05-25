@tool
@icon("res://addons/simple_event_system/listener_icon.png")
extends Resource
class_name SimpleEventData

var _parent_node: Node

@export var _node_path_target: NodePath:
	set(val):
		_node_path_target = val
		_update_resource_name()

@export var _resource_target: Resource:
	set(val):
		_resource_target = val
		_update_resource_name()

@export var _function_name: String:
	set(val):
		_function_name = val
		_update_resource_name()

@export var _is_dynamic: bool:
	set(val):
		_is_dynamic = val
		notify_property_list_changed()

@export var _args: Array:
	set(val):
		_args = val

func _update_resource_name():
	if !Engine.is_editor_hint():
		return

	if _parent_node == null:
		return

	var target_name = 'SimpleEventData'

	if _get_target() != null:
		target_name = _get_target_name() + '.' + _get_function_name()

	if resource_name != target_name:
		resource_name = target_name
		_args.clear()
		notify_property_list_changed()

func _get_target():
	var node = _get_node() 
	if node != null:
		return node
	if _resource_target != null:
		return _resource_target
	return null

func _get_target_name() -> String:
	if _get_node() != null:
		return _get_node().name
	if _resource_target != null:
		return _resource_target.resource_path.split('/')[-1].split('.')[0]
	return ''

func _get_node():
	if _node_path_target == null or _parent_node == null:
		return null

	return _parent_node.get_node_or_null(_node_path_target)	#This is the only reason why I need the parent node

func _check_existing_function() -> bool:
	if _function_name == '!!!(Function Missing)!!!' or _function_name == '':
		return false

	var f_list = _get_all_node_functions(_get_type_name())

	if f_list.find(_get_function_name()) == -1:
		_function_name = '!!!(Function Missing)!!!'
		return true
	
	return false

func _update_parameters() -> void:	#automatically assigns the type of variables in _args
	if _node_path_target == null:
		return

	_args.clear()
	var method_list = _get_target().get_method_list()

	for function_dict in method_list:
		if function_dict['name'] == _get_function_name().split('(')[0]:
			var cur_arg_count = 0
			var func_args = function_dict['args']
			var func_def_args = function_dict['default_args']
			
			for function_arg in func_args:
				var func_type = function_arg['type']

				if func_type != 24:
					_args.append(type_convert(0, function_arg['type']))
				else:
					var global_classes = ProjectSettings.get_global_class_list()
					var is_found = false
					
					for gc in global_classes:
						if gc['class'] == function_arg['class_name']:
							var arg_class =  load(gc['path']) #The path of the class
							_args.append(NodePath())
							is_found = true

					if(!is_found):
						var p = PackedScene
						_args.append(PackedScene)
				
				#For default_args assignment
				var default_arg_index = len(func_def_args) + cur_arg_count - len(func_args)
				
				if default_arg_index > -1:
					_args[-1] = func_def_args[default_arg_index]
					
				cur_arg_count += 1
			break
	
	notify_property_list_changed()

func _get_all_node_functions(type_name: String) -> Array:
	var function_list:= []

	if _get_target() != null:
		var f_list = ClassDB.class_get_method_list(type_name, true)	#Get Node Functions
		var starting_index = 0
		f_list.sort_custom(_sort_by_name)

		if f_list.size() == 0:	#To only get the class functions
			f_list = _get_target().get_method_list()

			for i in range(f_list.size() - 1, -1, -1):
				if f_list[i]['name'] == 'cancel_free':
					starting_index = i + 1
					break

		for i in range(starting_index, f_list.size()):
			var func_text = f_list[i]['name'] + '('
			var args = f_list[i]['args']

			if func_text[0] == '_' or func_text[0] == '@':
				continue

			for arg in args:
				func_text += arg['name'] + ','

			if args.size() != 0:
				func_text = func_text.rstrip(func_text[-1])
				
			func_text += ')'
			function_list.append(func_text)

	return function_list

func _get_all_node_types() -> Array:
	var inherited_classes:= []

	if _node_path_target != null:
		var script = _get_target().get_script()
		var node_class = _get_target().get_class()
		var count = 25	#To not get stuck in a while loop. I doubt there are scripts that will reach this much inheriting, right?

		if script != null:
			var paths = script.get_path().split('/')
			inherited_classes.append(paths[paths.size() - 1])
		
		while node_class != '' and count > 0:
			count -= 1
			inherited_classes.append(node_class)
			node_class = ClassDB.get_parent_class(node_class)

	return inherited_classes

func _sort_by_name(a, b):
	return a['name'] < b['name']  # Ascending order

func _get_type_name() -> String:
	return _function_name.split('.')[0]

func _get_function_name() -> String:
	return _function_name.split('.')[-1]