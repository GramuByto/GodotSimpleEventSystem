@tool
extends EditorPlugin

var inspector_plugin

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		inspector_plugin = preload("simple_event_inspector_plugin.gd").new()
		add_inspector_plugin(inspector_plugin)
		add_custom_type("SimpleEvent", "Node", preload("res://addons/simple_event_system/simple_event.gd"), preload("res://addons/simple_event_system/signal_icon.png"))
		add_custom_type("SimpleEventFunction", "Node", preload("res://addons/simple_event_system/simple_event_function.gd"), preload("res://addons/simple_event_system/listener_icon.png"))
		add_custom_type("SimpleEventSystem", "Node", preload("res://addons/simple_event_system/simple_event_system.gd"), preload("res://addons/simple_event_system/listener_icon.png"))

func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)

func _get_plugin_name() -> String:
	return "SimpleEventSystem"
