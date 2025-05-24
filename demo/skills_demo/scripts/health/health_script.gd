extends Node
class_name HealthClass

@export var OnTakeDamage: SimpleEvent
@export var OnAddHealth: SimpleEvent

var health: int

func take_damage(val: int = 2):
	health -= val
	OnTakeDamage.invoke()

func add_health(val: int):
	health += val
	OnAddHealth.invoke()

func set_health(val: int):
	health = val