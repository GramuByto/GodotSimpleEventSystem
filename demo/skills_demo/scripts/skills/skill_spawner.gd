extends Node
class_name SkillSpawner

func spawnNode(node: PackedScene, spawnPosition: Vector3):
	var newNode := node.instantiate()
	newNode.position = spawnPosition
	add_child(newNode)
