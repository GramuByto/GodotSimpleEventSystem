extends Node3D
class_name HealthEffect

@export var heal: int

func _on_area_entered(area:Area3D):
	if area.is_in_group('enemy'):
		var nodes := area.owner.get_children(true)
		for node in nodes:
			if str(node.get_script()) == str(HealthClass):
				node = node as HealthClass
				node.add_health(heal)
				break
	