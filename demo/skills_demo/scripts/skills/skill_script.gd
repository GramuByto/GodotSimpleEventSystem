extends Node
class_name SkillScript

@export var OnActivateSkill: SimpleEvent

func _ready():
	activate_skill()

func activate_skill():
	OnActivateSkill.invoke()
