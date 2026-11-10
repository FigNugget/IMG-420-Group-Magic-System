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
@export var unknownColor := Color.DIM_GRAY

enum State {DRAWING, NOT_DRAWING}
@export var mouseState = State.NOT_DRAWING

enum Spell {FIRE, WATER, EARTH, AIR}
enum Shape {TRIANGLE, CIRCLE, SQUARE, SPIRAL, UNKNOWN}
var spell: Spell
var simplifiedPoints: Array[Vector2] = []

var drawingPoints: Array[Vector2] = []
var mousePosition: Vector2
var startMousePosition: Vector2
@export_range(1.0, 30.0, 0.5) var rdpEpsilon := 5.0

var maxDistance: int
var maxIndex: int
var curDistance: int

var color:= unknownColor
var center:Vector2
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
				color = recognizeShape(drawingPoints)

		# Check for left mouse button release
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:

			# Stop drawing
			mouseState = State.NOT_DRAWING
			# check type of drawing
			spell = recognizeShape(drawingPoints)
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
	drawingPoints.clear()
	queue_redraw()
	
func updateDrawing(position:Vector2) -> void:
	drawingPoints.append(position)
	queue_redraw()
	
func _draw() -> void:
	if drawingPoints.size()<2:
		return
	for i in range(drawingPoints.size()-1):
		draw_line(
			drawingPoints[i],
			drawingPoints[i+1],
			fireColor,
			dot_size
		)

func castSpell(spell:int):
	print(spell)
	pass
	
func recognizeShape(points:Array[Vector2]):

	# Simplify the drawing
	simplifiedPoints = RDP(points)

	# Get center of drawing
	center = getCenter(points)

	# Check for circle
	if isCircle(points, center):
		return Shape.CIRCLE

	# Check for spiral
	if isSpiral(points, center):
		return Shape.SPIRAL

	# Check for triangle
	if isTriangle(simplifiedPoints):
		return Shape.TRIANGLE

	# Check for square
	if isSquare(simplifiedPoints):
		return Shape.SQUARE

	return Shape.UNKNOWN
	
func getCenter(points:Array[Vector2]):
	pass
func isCircle(points:Array[Vector2], center:Vector2):
	pass
func isSpiral(points:Array[Vector2], center:Vector2):
	pass
func isTriangle(simplifiedPoints:Array[Vector2]):
	pass
func isSquare(simplifiedPoints:Array[Vector2]):
	pass
func RDP(points:Array[Vector2]):
	# if theres two or less points
	if points.size() <= 2:
		# return points
		return points
	# find the point w the greatest perpendicular distance
		# max dis
	maxDistance = 0
		# intex
	maxIndex = 0
	
	# for loop to find max distance
	for
		# resert cur distance
		curDistance = 0
		
		# calculate perp distance
		
		# if hypo is > than max then replace
		if curDistance > maxDistance:
			maxDistance = curDistance
			maxIndex = i
		
	# check if max dist is within epsilon
	if maxDistance <= rdpEpsilon
		return[firstPoint,lastPoint]
	# split graph and recersive
	leftArr = 
	rightArr
	# combine arrays and return array
	pass
