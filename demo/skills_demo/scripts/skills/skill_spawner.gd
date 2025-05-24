extends Node
class_name SkillSpawner



func spawnNode(node: PackedScene, spawnPosition: Vector3):
	var newNode := node.instantiate()
	newNode.position = spawnPosition
	newNode.tree_exited.connect(test_func)
	add_child(newNode)

func test_func():
	print(523523)