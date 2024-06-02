extends Resource
class_name SimpleGlobalEventSystem

var event_systems: Array[SimpleEventSystem]

func invoke():
	for i in range(event_systems.size() - 1, -1, -1):
		if event_systems[i] == null or not event_systems[i].is_inside_tree():
			event_systems.remove_at(i)

	for event_system in event_systems:
		if event_system == null:
			continue

		event_system.invoke()
