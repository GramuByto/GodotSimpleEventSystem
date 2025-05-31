extends Resource
class_name SimpleGlobalEvent

signal on_invoke

func invoke():
	on_invoke.emit()