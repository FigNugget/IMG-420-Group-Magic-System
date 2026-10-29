extends CharacterBody2D

@onready var player_node: CharacterBody2D = get_parent().get_node("PlayerChar")

@export var health: int = 3

var speed: float = 35
var gravity = 15

#@export_range(-1,1) var dir: int = 1
#
#func _ready() -> void:
	#if dir == 0:
		#dir = 1
	#$AnimatedSprite2D.flip_h = false if dir == 1 else true
#
#func physics_process(delta: float) -> void:
	#if dir == 1 and (!$rightRay.is_colliding() or $rightWallRay.is_colliding()):
		#$AnimatedSprite2D.flip_h = true
		#dir = 0
		#_wait_dir_change(-1)
	#if dir == -1 and (!$leftRay.is_colliding() or $leftWallRay.is_colliding()):
		#$AnimatedSprite2D.flip_h = false
		#dir = 1

#func _physics_process(delta: float) -> void:
	## Check for ledge detection
	#if dir == 1 and not $rightRay.is_colliding():
		##$AnimatedSprite2D.flip_h = true
		#dir = -1
	#elif dir == -1 and not $leftRay.is_colliding():
		##$AnimatedSprite2D.flip_h = false
		#dir = 1
#
	## Check for wall detection
	#if (dir == 1 and $rightWallRay.is_colliding()) or (dir == -1 and $leftWallRay.is_colliding()):
		#dir *= -1
		#$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
		#
	#velocity.x = dir * speed
	#velocity.y += gravity
	#move_and_slide()
#
	##velocity.x = lerp(velocity.x, dir * speed, 10.0*delta)
	##velocity.y != gravity
	##move_and_slide()
	#
	#
	#if not is_on_floor():
		#$AnimatedSprite2D.play("up")
	#else: 

#func _wait_dir_change(desired_dir: int):
	#await get_tree().create_timer(0.5).timeout
	#dir = desired_dir

func _physics_process(delta):
	velocity = Vector2.ZERO
	
	if player_node:
		#velocity = position.direction_to(player_node.position) * speed
		velocity.x = signf(player_node.global_position.x - global_position.x) * speed
		
	move_and_slide()
	
	if velocity.x != 0:
		$AnimatedSprite2D.play("move")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	#if velocity.x > 0:
		#$AnimatedSprite2D.play("move")
		#$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")

func _on_area_2d_chase_body_entered(body: CharacterBody2D) -> void:
	player_node = body

func _on_area_2d_chase_body_exited(body: Node2D) -> void:
	player_node = null
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player_node:
		GameController.health_deplete(health)
		get_tree().call_deferred("reload_current_scene")
