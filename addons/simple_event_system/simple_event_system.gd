@tool
extends Node
class_name SimpleEventSystem

#region Editor Variables

@export var _node: Node:
	set(val):
		if val != null and _cur_index != -1:
			if val != _callable_nodes[_cur_index]:
				_callable_nodes[_cur_index] = val
				notify_property_list_changed()

				var editor_selection = EditorInterface.get_selection()
				editor_selection.clear()
				editor_selection.add_node(self)	#reselect this _node

		_node = val
			
@export var _type_name:String:
	set(val):
		_assign_callable_values(val, 0)
		_type_name = val

@export var _function_name:String:
	set(val):
		_assign_callable_values(val, 1)
		_function_name = val

@export var _args: Array:
	set(val):
		_args = val

var _cur_index:= -1
var _refresh_time:= 0.0

@export_group("Callables")
@export var _refresh_interval: = 0.1	#It is exported just for the subgroup to show up

#endregion

@export_group("Raw Data")
@export var _show_raw_data:= false:
	set(val):
		_show_raw_data = val
		notify_property_list_changed()

@export var _callable_nodes: Array[Node]
@export var _callable_values:= []

func invoke():
	var new_args : Array

	for index in range(_callable_values.size()):
		for arg in _callable_values[index][2]:
			if typeof(arg) == TYPE_NODE_PATH:	#Changing NodePath into Node
				new_args.append(get_node(arg))
			else:
				new_args.append(arg)
	
		_callable_nodes[index].callv(_callable_values[index][1].split('(')[0], new_args)
		new_args.clear()

#region Editor Functions

func _process(delta):
	_refresh_time += delta

	if _refresh_time < _refresh_interval:	#Check for missing functions every 0.1s
		return
	_refresh_time = 0

	if !Engine.is_editor_hint():
		process_mode = Node.PROCESS_MODE_DISABLED
		return

	var has_changes = false;
	
	#Check for missing functions
	for index in range(_callable_nodes.size()):
		var temp_function = _callable_values[index][1]

		#so that we don't have to get and read every function all the time
		if temp_function == '!!!(Function Missing)!!!' or temp_function == '':
			continue
		
		var function_list = _get_all_node_functions(index)
		var temp_function_index = function_list.find(temp_function)

		if temp_function_index == -1:
			_callable_values[index][1] = '!!!(Function Missing)!!!'
			has_changes = true
	
	if has_changes:
		notify_property_list_changed()

	#change the selected _args
	if _cur_index != -1:
		var arr2:Array = _callable_values[_cur_index][2]
		var sync_values = false

		if _args.size() != arr2.size():
			sync_values = true
		else:
			for i in range(_args.size()):
				if _args[i] != arr2[i]:
					sync_values = true
					break

		if sync_values:
			_callable_values[_cur_index][2] = _args


func _add_callable():
	var callable = ['', '', []]
	_callable_values.append(callable)
	_callable_nodes.append(null)
	_cur_index = len(_callable_values) - 1
	_node = null
	_function_name = ''
	notify_property_list_changed()


func _delete_callable(index):
	_callable_nodes.remove_at(index)
	_callable_values.remove_at(index)
	_cur_index = -1
	notify_property_list_changed()


func _select_callable(index):
	_cur_index = index

	if _cur_index != -1 and _cur_index < len(_callable_values):
		var callable = _callable_values[index]
		_node = _callable_nodes[index]
		_type_name = callable[0]
		_function_name = callable[1]
		_args = callable[2]
		notify_property_list_changed()


func _move_callable(index: int, up: bool):
	var element = _callable_values[index]
	var temp_node = _callable_nodes[index]
	_callable_values.remove_at(index)
	_callable_nodes.remove_at(index)
	_cur_index = index + (-1 if up else 1)
	_callable_values.insert(_cur_index, element)
	_callable_nodes.insert(_cur_index, temp_node)
	notify_property_list_changed()


func _assign_callable_values(val, index: int):
	if _cur_index != -1:
		if val != _callable_values[_cur_index][index]:
			_callable_values[_cur_index][index] = val
			notify_property_list_changed()


func _update_parameters() -> void:
	if _node == null:
		return

	_args.clear()
	var method_list = _node.get_method_list()

	for function_dict in method_list:
		if function_dict['name'] == _function_name.split('(')[0]:
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


func _get_all_node_types(callable_index) -> Array:
	var callable_node:Node = _callable_nodes[callable_index]
	var inherited_classes:= []

	if callable_node != null:
		var script = callable_node.get_script()
		var node_class = callable_node.get_class()
		var count = 50	#To not get stuck in a while loop

		if script != null:
			var paths = script.get_path().split('/')
			inherited_classes.append(paths[paths.size() - 1])
		
		while node_class != 'Node' and count > 0:	# Traverse up the inheritance hierarchy until reaching Node
			count -= 1
			inherited_classes.append(node_class)
			node_class = ClassDB.get_parent_class(node_class)

		inherited_classes.append('Node')
	return inherited_classes


func _get_all_node_functions(callable_index:int) -> Array:
	var callable_node:Node = _callable_nodes[callable_index]
	var function_list:= []

	if callable_node != null:
		var f_list = ClassDB.class_get_method_list(_callable_values[callable_index][0], true)
		var starting_index = 0
		f_list.sort()

		if f_list.size() == 0:	#To only get the class functions
			f_list = callable_node.get_method_list()

			for i in range(f_list.size() - 1, -1, -1):
				if f_list[i]['name'] == 'cancel_free':
					starting_index = i + 1
					break

		for i in range(starting_index, f_list.size()):	#To get the Node functions
			var func_text = f_list[i]['name'] + '('
			
			if len(f_list[i]['args']) != 0:
				for arg in f_list[i]['args']:
					func_text += arg['name'] + ','
				
				func_text = func_text.rstrip(func_text[-1])
				
			func_text += ')'
			function_list.append(func_text)

	return function_list

#endregion
