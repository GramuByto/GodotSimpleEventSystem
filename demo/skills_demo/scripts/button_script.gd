extends Node
class_name ButtonScript

@export var OnButtonPress: SimpleEventSystem

func _on_pressed():
	OnButtonPress.invoke()
