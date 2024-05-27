extends ProgressBar
class_name HealthBarClass

@export var health_class: HealthClass

func update_health():
    value = health_class.health