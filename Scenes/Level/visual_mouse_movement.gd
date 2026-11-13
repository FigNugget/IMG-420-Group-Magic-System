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

enum Spell {FIRE, WATER, EARTH, AIR, UNKNOWN}
enum Shape {TRIANGLE, CIRCLE, SQUARE, SPIRAL, UNKNOWN}
var spell: Spell
var simplifiedPoints: Array[Vector2] = []

var drawingPoints: Array[Vector2] = []
var mousePosition: Vector2
var startMousePosition: Vector2
@export_range(1.0, 30.0, 0.5) var rdpEpsilon := 20
var circleEpsilon := 40


@export var spiralTolerance:=0.15



var color:= unknownColor
var shape:=Shape.UNKNOWN
var center:Vector2
func _gui_input(event):
	# Check for left mouse button press
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start drawing
				mouseState = State.DRAWING
				# Record starting position
				drawingPoints.clear()
				drawingPoints.append(event.position)
			else:
				if mouseState == State.DRAWING:
					mouseState = State.NOT_DRAWING
					# recognize shape
					shape = recognizeShape(drawingPoints)
					# execute spell
					spell = getSpell(shape)
					color = getColor(shape)
					queue_redraw()
					castSpell(spell)
					# Reset drawing
					resetDrawing()
	# Check if mouse is moving
	if event is InputEventMouseMotion:

		if mouseState == State.DRAWING:
			drawingPoints.append(event.position)
			queue_redraw()
func getColor(shape)->Color:
	match shape:
		Shape.TRIANGLE:
			return fireColor
		Shape.CIRCLE:
			return waterColor
		Shape.SPIRAL:
			return airColor
		Shape.SQUARE:
			return earthColor
		_:
			return unknownColor
func getSpell(shape)->Spell:
	match shape:
		Shape.TRIANGLE:
			return Spell.FIRE
		Shape.CIRCLE:
			return Spell.WATER
		Shape.SPIRAL:
			return Spell.AIR
		Shape.SQUARE:
			return Spell.EARTH
		_:
			return Spell.UNKNOWN
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
			color,
			dot_size
		)

func castSpell(spell:int):
	print(spell)
	pass
	
func recognizeShape(points:Array[Vector2]):
	print("Original points: ", points.size())
	print("Point count: ", points.size())
	
	# Simplify the drawing
	simplifiedPoints = RDP(points)

	# Get center of drawing
	center = getCenter(points)
	
	if points.size() < 3:
		return Shape.UNKNOWN
	if points[0].distance_to(points[-1])<50:
		points.append(points[0])

	print("Simplified points: ", simplifiedPoints.size())
	print("Center: ", center)
	
	print("Circle: ", isCircle(points, center))
	print("Spiral: ", isSpiral(points, center))
	
	print("Triangle: ", isTriangle(simplifiedPoints))
	print("Square: ", isSquare(simplifiedPoints))
	
	
	
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
	
func getCenter(points:Array[Vector2])->Vector2:
	if points.is_empty():
		return Vector2.ZERO
	var curCenter = Vector2.ZERO
	for point in points:
		curCenter += point
	curCenter /= points.size()
	return curCenter
func isCircle(points:Array[Vector2], center:Vector2)->bool:
	if points.size() < 3:
		return false
	var distances: Array[float] = []
	for point in points:
		distances.append(point.distance_to(center))
	var avg = 0.0
	for distance in distances:
		avg += distance
	avg /= distances.size()
	for distance in distances:
		if not is_finite(distance):
			return false
		if abs(distance - avg) > circleEpsilon:
			return false
	return true
func isSpiral(points:Array[Vector2], center:Vector2):
	if points.size() < 3:
		return false
	var distances: Array[float] = []
	for point in points:
		distances.append(point.distance_to(center))
		
	var increasing = 0

	for i in range(distances.size()-1):
		if increasing < (distances.size() - 1) * 0.7:
			return false

	var totalRotation = 0.0

	for i in range(points.size()-1):
		var angle1 = (points[i] - center).angle()
		var angle2 = (points[i+1] - center).angle()

		totalRotation += wrapf(angle2-angle1, -PI, PI)
	if abs(totalRotation) < TAU:
		return false
	var distanceChange: Array[float] = []
	for i in range (distances.size()-1):
		distanceChange.append(abs(distances[i+1]-distances[i]))
	var avg = 0.0
	for singleDistanceChange in distanceChange:
		avg += singleDistanceChange
	avg /= distanceChange.size()
	for singleDistanceChange in distanceChange:
		if abs(singleDistanceChange - avg) > avg * spiralTolerance:
			return false
	return true
func isTriangle(points:Array[Vector2]) -> bool:
	return points.size() == 3
func isSquare(points:Array[Vector2]):
	if points.size() != 4:
		return false
	for i in range(4):
		var side1 = points[(i+1)%4] - points[i]
		var side2 = points[(i+2)%4] - points[(i+1)%4]
		if abs(side1.length()-side2.length())>rdpEpsilon:
			return false
		if abs(side1.normalized().dot(side2.normalized()))>0.2:
			return false
	return true
func RDP(points:Array[Vector2])->Array[Vector2]:
	# if theres two or less points
	if points.size() <= 2:
		# return points
		return points
	# find the point w the greatest perpendicular distance
		# max dis
	var maxDistance = 0
		# intex
	var maxIndex = 0
	var firstPoint = points[0]
	var lastPoint = points[points.size()-1]
	var line = lastPoint - firstPoint
	if line.length_squared() == 0:
		return [firstPoint, lastPoint]
	# for loop to find max distance
	for i in range(1,points.size()-1):
		var curPoint = points[i]
		
		# calculate perp distance
		
		var offset = curPoint - firstPoint
		var curDistance = abs(line.cross(offset))/line.length()
		
		# if hypo is > than max then replace
		if curDistance > maxDistance:
			maxDistance = curDistance
			maxIndex = i
		
	# check if max dist is within epsilon
	if maxDistance <= rdpEpsilon:
		return[firstPoint,lastPoint]
	# split graph and recersive
	var leftArr: Array[Vector2] = []
	var rightArr: Array[Vector2] = []
	for i in range(maxIndex + 1):
		leftArr.append(points[i])

	for i in range(maxIndex, points.size()):
		rightArr.append(points[i])

	var result: Array[Vector2] = RDP(leftArr)
	var rightResult: Array[Vector2] = RDP(rightArr)

	for i in range(1, rightResult.size()):
		result.append(rightResult[i])
	return result
