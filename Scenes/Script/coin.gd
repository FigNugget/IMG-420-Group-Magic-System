extends Node2D

@export var value: int = 1 

func _process(delta):
	$AnimatedSprite2D.play("spin")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerChar:
		GameController.coin_collected(value)
		self.queue_free()
