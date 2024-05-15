extends Node
class_name EnemyClass

@export var OnInitialize: SimpleEventSystem

func _ready():
    OnInitialize.invoke()