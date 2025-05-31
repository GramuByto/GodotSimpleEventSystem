extends Node
class_name EnemyClass

@export var OnInitialize: SimpleEvent

func _ready():
    OnInitialize.invoke()