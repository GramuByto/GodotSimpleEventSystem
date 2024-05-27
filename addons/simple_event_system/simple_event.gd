@tool

extends Node
class_name SimpleEvent

enum NAMING_FORMAT {METHOD_ONLY, SCRIPT, NODE}

var text: RichTextLabel

@export var namingFormat: NAMING_FORMAT = NAMING_FORMAT.SCRIPT:
	set(val):
		namingFormat = val
		update_all_name_format()
		notify_property_list_changed()
		
@export var add_function_button: String	#This will be replaced by a button

@export_subgroup("Extra Properties")
@export var refresh_time: float = 0

func invoke():
	for child in get_children():
		(child as SimpleEventFunction).invoke()

func _init():
	self.set_display_folded(true);

#Check if functions still exists
func _process(delta):
	refresh_time += delta
	
	if refresh_time < 0.1:
		return
	refresh_time = 0

	if !Engine.is_editor_hint():
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	var has_changes = false;
	
	for child in get_children():
		var event = (child as SimpleEventFunction)
		var does_node_exist = event.node != null

		if does_node_exist:
			does_node_exist = event.node.is_inside_tree()

		if !does_node_exist:
			if(!event.name.contains('<<<')):
				event.name = '<<<SimpleEventFunction>>>'
				has_changes = true
			continue
			
		var function_index = event.get_all_node_functions().find(event.function_name)
		
		if(event.name.contains('!!!')):
			if(function_index != -1):
				update_name_format(event)
				has_changes = true
		else:
			if(function_index == -1):
				event.name = '!!!(Function Missing)!!!'
				has_changes = true
				
	if has_changes:
		notify_property_list_changed()

func update_name_format(child):
	var cur_name = child.function_name
	
	if(child.node == null):
		return
		
	if namingFormat != NAMING_FORMAT.METHOD_ONLY:
		match namingFormat:
			NAMING_FORMAT.SCRIPT:
				var script_assigned = child.node.get_script()
				var title = str(child.node.get_class())

				if script_assigned != null:
					title = script_assigned.get_path().split('/')[-1]

				cur_name = title + '->' + cur_name
			NAMING_FORMAT.NODE:
				cur_name = child.node.name + '->' + cur_name
	
	child.name = cur_name

func display_text():
	if text != null:
		if OS.has_feature("editor"):
			text.text = "editor"
			text.text = String.num(Engine.get_frames_per_second())
		else:
			set_process(false)

func update_all_name_format():
	for child in get_children():
		update_name_format(child)
