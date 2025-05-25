@tool
extends Node
class_name SimpleEvent

@export var _signal_source_node_path: NodePath:
	set(val):
		_signal_source_node_path = val
		notify_property_list_changed()

@export var _signal_source_resource: Resource:
	set(val):
		_signal_source_resource = val
		notify_property_list_changed()

@export var _signal_name: String:
	set(val):
		_signal_name = val
		notify_property_list_changed()

@export var _events: Array[SimpleEventData]:
	set(val):
		_events = val
		
		for i in range(val.size()):
			if _events[i] == null:
				_events[i] = SimpleEventData.new()

var _refresh_time := 0.0
var _default_instance := SimpleEventData #No class other than this is going to use this at runtime, right?

func _init():
	set_process(Engine.is_editor_hint())	

func _enter_tree() -> void:
	if _has_signal():
		_get_source().connect(_get_signal_name(), invoke)

func _exit_tree() -> void:
	if _has_signal():
		_get_source().disconnect(_get_signal_name(), invoke)

func _has_signal() -> bool:
	if Engine.is_editor_hint():
		return false

	if _get_source() == null:
		return false
	
	return _get_source().has_signal(_get_signal_name())

func invoke(arg0 = _default_instance, arg1 = _default_instance, arg2 = _default_instance, arg3 = _default_instance, arg4 = _default_instance, arg5 = _default_instance, arg6 = _default_instance, arg7 = _default_instance):
	var args := [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7]
	var dynamic_args: Array
	_assign_parent_node()

	for arg in args:
		if typeof(arg) == typeof(_default_instance):
			if arg == _default_instance:
				continue	#Append
		
		dynamic_args.append(arg)

	for event in _events:
		var target = event._get_target()

		if target == null:
			continue

		if event._is_dynamic:
			args = dynamic_args
		else:
			args = []
		
			for arg in event._args:
				if typeof(arg) == TYPE_NODE_PATH:	#Changing NodePath into Node
					args.append(get_node(arg))
				else:
					args.append(arg)

		target.callv(event._get_function_name().split('(')[0], args)

func _process(delta: float) -> void:
	_refresh_time += delta
	if _refresh_time < 0.25:	#Check for missing functions every 0.25s
		return
	_refresh_time = 0

	var has_changes := false
	_assign_parent_node()

	for event in _events:
		if event == null:
			continue

		if event.resource_name == 'SimpleEventData' || event.resource_name == '':
			event._update_resource_name()
		
		if event._check_existing_function():
			has_changes = true

	if has_changes:
		notify_property_list_changed()

func _get_signal_list() -> Array[String]:
	if _get_source() == null:
		return []

	var signal_list: Array[String] = []
	var source_signals = _get_source().get_signal_list()

	for signal_item in source_signals:
		var signal_text = signal_item['name'] + '('
		var args = signal_item['args']

		for arg in args:
			signal_text = signal_text + arg['name'] + ','
		
		if args.size() != 0:
			signal_text = signal_text.rstrip(signal_text[-1])

		signal_text = signal_text + ')'
		signal_list.append(signal_text)
		
	return signal_list

func _get_source():
	var node = _get_source_node() 
	if node != null:
		return node
	if _signal_source_resource != null:
		return _signal_source_resource
	return null

func _get_signal_name():
	return _signal_name.split('(')[0]

func _get_source_node():
	return get_node_or_null(_signal_source_node_path) 

func _assign_parent_node():
	for i in range(_events.size()):
		if _events[i]._parent_node != self:
			_events[i]._parent_node = self
