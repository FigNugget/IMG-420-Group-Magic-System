class_name PlayerChar extends CharacterBody2D

# Direction of the player's movement.
var player_direction: Vector2

@export var run_speed := 280.0
@export var acceleration := 2200.0
@export var deceleration := 2200.0
@export var jump_speed := 430.0
@export var gravity := 1350.0

# Maximum number of footprints allowed.
@export var max_footprints := 10
# Spacing between consecutive footprints.
@export var footprint_spacing := 0.25
# Lifetime of each footprint before fading out.
@export var footprint_lifetime := 2.0  # Time until disappearance
# Scene for footprint instantiation.
var footprint_scene = preload("res://Scenes/Items/footprint.tscn")

@export var coyote_time := 0.62
var coyote_left := 0.0

# Container node for footprints.
var footprint_container: Node
# Time accumulator for spacing footprints.
var time := 0.0


func _ready():
# Create a container to organize footprints.
	footprint_container = Node2D.new()
	footprint_container.name = "FootprintContainer"
	get_tree().current_scene.add_child.call_deferred(footprint_container)

func update_coyote_time(delta: float) -> void:
	if is_on_floor():
		coyote_left = coyote_time
	else:
		coyote_left = maxf(coyote_left - delta, 0.0)

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_axis("move_left", "move_right")
	var target_speed := direction * run_speed
	var rate := acceleration if direction != 0.0 else deceleration
	
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = -jump_speed
		
	move_and_slide()
	
	
		
	if not is_on_floor():
		$AnimatedSprite2D.play("up")
	else: 
		if velocity.x != 0:
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = velocity.x < 0
		else:
			$AnimatedSprite2D.play("idle")
			
			
#https://docs.godotengine.org/en/stable/getting_started/first_2d_game/04.creating_the_enemy.html
# Direction of the player's movement.

func _process(delta):
# Only create footprints when moving.
	if velocity.length() == 0:
		return
		
	if velocity.y != 0:
		return

	time += delta

	# Create new footprint if enough time has passed.
	if time >= footprint_spacing:
		time = 0.0
		create_footprint()
		clean_old_footprints()

func create_footprint():
# Instantiate a footprint scene.
	var footprint = footprint_scene.instantiate()
	footprint_container.add_child(footprint)

	# Calculate movement direction.
	var move_direction = velocity.normalized()

	# Add slight offset to avoid overlapping with player.
	var _move_direction = move_direction   # Adjust this based on your sprite
	var offset = Vector2(randf_range(-1, 1), randf_range(-1, 1))

	# Position footprint slightly offset from player.
	footprint.global_position = global_position + offset
	footprint.global_position.y = footprint.global_position.y + 35  # Specific adjustments for my sprite (you can omit or change this)

	# Rotate footprint based on movement direction.
	if velocity.length() > 0:
		footprint.global_rotation = velocity.angle() + deg_to_rad(90)
	else:
		footprint.global_rotation = global_rotation  # Use current rotation if stationary

	# Configure fading effect.
	var tween = create_tween()
	tween.tween_property(footprint, "modulate:a", 0.0, footprint_lifetime)
	tween.tween_callback(footprint.queue_free)

func clean_old_footprints():
# Limit the number of footprints.
	if footprint_container.get_child_count() > max_footprints:
		var oldest = footprint_container.get_children()[0]
		oldest.queue_free()
