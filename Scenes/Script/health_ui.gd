extends Control

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#EventController.connect("health_deplete", on_event_health_deplete)
	label.text = str(GameController.health)
	EventController.connect("health_deplete", on_event_health_deplete)


func on_event_health_deplete(value: int) -> void:
	#print("Value: ", value)
	pass
