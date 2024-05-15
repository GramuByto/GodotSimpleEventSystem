@tool
extends Node
class_name SimpleEventFunction

@export var node: Node:
	set(val):
		node = val
		notify_property_list_changed() #refreshing will select the node put in here
		var editor_selection = EditorInterface.get_selection()

		editor_selection.clear()
		editor_selection.add_node(self)	#reselect this node
		
@export var type_name:String = ''
@export var function_name:String = ''

@export var args: Array:
	set(val):
		args = val
		notify_property_list_changed()

func invoke():
	var new_args : Array
	
	for arg in args:
		if typeof(arg) == TYPE_NODE_PATH:	#Changing NodePath into Node
			new_args.append(get_node(arg))
		else:
			new_args.append(arg)
	
	node.callv(get_function_name(), new_args)

func get_all_node_types():	
	var inherited_classes = []
	var count = 10

	if node != null:
		var script = node.get_script()

		if script != null:
			var paths = script.get_path().split('/')
			inherited_classes.append(paths[paths.size() - 1])
		
		var node_class = node.get_class()

        # Traverse up the inheritance hierarchy until reaching Node
		while node_class != 'Node' and count > 0:
				
			count = count - 1
			inherited_classes.append(node_class)
			node_class = ClassDB.get_parent_class(node_class)

		inherited_classes.append('Node')
	return inherited_classes

func get_all_node_functions():
	var function_list = []
	
	if node != null:
		var f_list = ClassDB.class_get_method_list(type_name, true)
		var starting_index = 0
		f_list.sort()

		if f_list.size() == 0:	#To only get the class functions
			f_list = node.get_method_list()

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

func _on_function_change_selected(text):
	function_name = text
	$"..".update_name_format(self)	#Will probably look a better way for this
	args.clear()
	var method_list = node.get_method_list()
	
	for function_dict in method_list:
		if function_dict['name'] == get_function_name():
			var cur_arg_count = 0
			var func_args = function_dict['args']
			var func_def_args = function_dict['default_args']
			
			for function_arg in func_args:
				var func_type = function_arg['type']

				if func_type != 24:
					args.append(type_convert(0, function_arg['type']))
				else:
					var global_classes = ProjectSettings.get_global_class_list()
					var is_found = false
					
					for gc in global_classes:
						if gc['class'] == function_arg['class_name']:
							var arg_class =  load(gc['path']) #The path of the class
							args.append(NodePath())
							is_found = true

					if(!is_found):
						var p = PackedScene
						args.append(PackedScene)
						pass
				
				#For default_args assignment
				var default_arg_index = len(func_def_args) + cur_arg_count - len(func_args)
				
				if default_arg_index > -1:
					args[-1] = func_def_args[default_arg_index]
					
				cur_arg_count += 1
			break
	
	notify_property_list_changed()
	
func _on_type_change_selected(text):
	type_name = text
	$"..".update_name_format(self)	#Will probably look a better way for this
	notify_property_list_changed()

func get_function_name() -> String:
	return function_name.split('(')[0]
