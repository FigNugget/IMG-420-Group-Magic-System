class_name Fireball extends Area2D

@export var move_speed: float = 400

var direction_modifier: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.flip_h = direction_modifier < 0
	body_entered.connect(_on_body_entered)
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.queue_free()
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += move_speed * delta * direction_modifier
	
