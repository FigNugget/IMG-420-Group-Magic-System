
class_name Rock extends Area2D

@export var move_speed: float = 400.0
@export var max_distance: float = 200.0

var direction_modifier: int = 1
var distance_traveled: float = 0.0

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.flip_h = direction_modifier < 0

	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var movement = move_speed * delta

	position.x += movement * direction_modifier
	distance_traveled += movement

	if distance_traveled >= max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()
