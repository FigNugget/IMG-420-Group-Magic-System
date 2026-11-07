class_name VisualMouseMovement
extends Panel

## Radius of each dot, in pixels.
@export var dot_size := 3.0

@export_group("Colors")
@export var background_color := Color(0, 0, 0, 0)
@export var fireColor := Color.RED
@export var waterColor := Color.SKY_BLUE
@export var airColor := Color.ANTIQUE_WHITE
@export var earthColor := Color.SADDLE_BROWN

enum State {DRAWING, NOT_DRAWING}
@export var mouseState = State.NOT_DRAWING

enum Spell {FIRE, WATER, EARTH, AIR}
var spell: Spell

var drawing_points: Array[Vector2] = []
var mousePosition: Vector2
var startMousePosition: Vector2
@export_range(1.0, 30.0, 0.5) var rdpEpsilon := 5.0


func _gui_input(event) -> void:

	# Check if a mouse button was pressed or released
	if event is InputEventMouseButton:

		# Check for left mouse button press
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if mouseState == State.NOT_DRAWING:
				# Start drawing
				mouseState = State.DRAWING

				# Record starting position
				startMousePosition = event.position
				
				# change color based on what shape 
				color = recognizeShape()

		# Check for left mouse button release
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:

			# Stop drawing
			mouseState = State.NOT_DRAWING
			# check type of drawing
			spell = recognizeShape()
			# execute spell
			castSpell(spell)
			# Reset drawing
			resetDrawing()


	# Check if mouse is moving
	if event is InputEventMouseMotion:

		if mouseState == State.DRAWING:

			# Get current mouse position
			mousePosition = event.position

			if mousePosition != startMousePosition:
				# Update the drawing
				updateDrawing(mousePosition)
				startMousePosition = mousePosition
func resetDrawing() -> void:
	drawing_points.clear()
	queue_redraw()
	
func updateDrawing(position:Vector2) -> void:
	drawing_points.append(position)
	queue_redraw()
	
func _draw() -> void:
	if drawing_points.size()<2:
		return
	for i in range(drawing_points.size()-1):
		draw_line(
			drawing_points[i],
			drawing_points[i+1],
			fireColor,
			dot_size
		)

func castSpell(spell:int):
	print(spell)
	pass
	
func recognizeShape(points:Array[Vector2]):

	# Simplify the drawing
	simplify = RDP(points)

	# Get center of drawing
	center = getCenter(points)

	# Check for circle
	if isCircle(points, center):
		return CIRCLE

	# Check for spiral
	if isSpiral(points, center):
		return SPIRAL

	# Check for triangle
	if isTriangle(simplified_points):
		return TRIANGLE

	# Check for square
	if isSquare(simplified_points):
		return SQUARE

	return UNKNOWN
	
func RDP(points:Array[Vector2]):
	# if theres only two points
		# return points
	# find the point w the greatest distance
		# max dis
		# intex
	
	# for loop to find max distance
		# find vertical distance
		# find horizontal distance
		# find hypotenuse
		# if hypo is > than max then replace
		
	# check if max dist is within epsilon
	# split graph and recersive
	# combine arrays and return array
	pass
