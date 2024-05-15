extends Node
class_name HealthClass

@export var OnTakeDamage: SimpleEventSystem
@export var OnAddHealth: SimpleEventSystem

var health: int

func take_damage(val: int = 2):
	health -= val
	OnTakeDamage.invoke()

func add_health(val: int):
	health += val
	OnAddHealth.invoke()

func set_health(val: int):
	health = val