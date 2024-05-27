extends Node

@export var to_spawn: PackedScene

var time: float
var cur_count: int
var spawn_count := 1000

var scene_name: String
var spawned_node: Node

func _ready():
	spawned_node = to_spawn.instantiate()
	scene_name = spawned_node.name
	cur_count += 1

func _process(delta):
	time += delta
	
	if time > 1:
		time = 0

		for i in range(0, spawn_count):
			spawned_node = to_spawn.instantiate()
			add_child(spawned_node)

		cur_count += spawn_count

		print("-----------------------------------")
		print("PackedScene: " + scene_name + "\nSpawnCount: " + str(cur_count) + "\nFPS: " + str(Engine.get_frames_per_second()))
