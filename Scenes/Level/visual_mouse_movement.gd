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
@export_range(0.01, 0.3, 0.01) var rdpEpsilon := 0.07
var circleEpsilon := 0.2
var squareEpsilon := 0.5


@export var spiralTolerance:=0.5

var drawingTimer:= Timer.new()

func _ready()->void:
	drawingTimer.wait_time = 0.3
	drawingTimer.one_shot = true
	add_child(drawingTimer)
	drawingTimer.timeout.connect(resetDrawing)


var color:= unknownColor
var shape:=Shape.UNKNOWN
var center:Vector2
func _gui_input(event):
	# Check for left mouse button press
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start drawing
				color = unknownColor
				mouseState = State.DRAWING
				# Record starting position
				drawingTimer.stop()
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
					drawingTimer.start()
					castSpell(spell)
					# Reset drawing
					queue_redraw()
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

func castSpell(spell:Spell):
	print(spell)
	pass
	
func recognizeShape(points:Array[Vector2])->Shape:
	print("Original points: ", points.size())
	print("Point count: ", points.size())
	if points.size() < 3:
		return Shape.UNKNOWN
		
	var bounds:= Rect2(points[0], Vector2.ZERO)
	for p in points:
		bounds = bounds.expand(p)
	var extent:= maxf(bounds.size.x, bounds.size.y)
	if extent < 20.0:
		return Shape.UNKNOWN
	var closed:= points[0].distance_to(points[-1])<extent*0.25
	simplifiedPoints = RDP(points, extent*rdpEpsilon)
	if closed:
		simplifiedPoints = prunePolygon(simplifiedPoints)
	# Get center of drawing
	center = bounds.get_center()
	
		# delete after
	print("Simplified points: ", simplifiedPoints.size())
	print("Center: ", center)
	var spiralBool = isSpiral(points,center)
	var triangleBool = true if closed and isTriangle(simplifiedPoints) else false
	var squareBool = true if closed and isSquare(simplifiedPoints) else false
	var circleBool = true if closed and isCircle(points,center) else false
	
	
	
	
	print("Circle: ", circleBool)
	print("Spiral: ", spiralBool)
	
	print("Triangle: ", triangleBool)
	print("Square: ", squareBool)
	

	# Check for spiral
	if spiralBool:
		return Shape.SPIRAL

	# Check for triangle
	if triangleBool:
		return Shape.TRIANGLE

	# Check for square
	if squareBool:
		return Shape.SQUARE
		# Check for circle
	if circleBool:
		return Shape.CIRCLE
		

	return Shape.UNKNOWN
	
func prunePolygon(pts:Array[Vector2],minTurn:=deg_to_rad(35.0))->Array[Vector2]:
	var out := pts.duplicate()
	# drop duplicated closing point
	if out.size()> 3 and out[0].distance_to(out[-1])<1.0:
		out.remove_at(out.size()-1)
	var changed := true
	while changed and out.size()>3:
		changed = false
		for i in out.size():
			var prev: Vector2 = out[(i-1+out.size())%out.size()]
			var next :Vector2= out[(i + 1) % out.size()]
			var a :Vector2= (out[i] - prev).normalized()
			var b :Vector2= (next - out[i]).normalized()
			if abs(a.angle_to(b)) < minTurn:
				out.remove_at(i)
				changed = true
				break
	return out
	

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
			# does not go based on pixels and rather by avg
		if abs(distance - avg) > avg*circleEpsilon:
			return false
	return true
func isSpiral(points:Array[Vector2], center:Vector2):
	if points.size() < 3:
		return false
	var distances: Array[float] = []
	for point in points:
		distances.append(point.distance_to(center))
		
	var increasing = 0
	var decreasing = 0

	for i in range(distances.size()-1):
		if distances[i+1]>distances[i]:
			increasing+=1
		elif distances[i+1]<distances[i]:
			decreasing+=1
	var needed:= (distances.size() - 1) * 0.7
	if increasing < needed and decreasing < needed:
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
		var length1 = side1.length()
		var length2 = side2.length()
		if abs(length1-length2) > maxf(length1,length2)* squareEpsilon:
			return false
		if abs(side1.normalized().dot(side2.normalized()))>0.2:
			return false
	return true
func RDP(points:Array[Vector2],epsilon:float)->Array[Vector2]:
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
	if maxDistance <= epsilon:
		return[firstPoint,lastPoint]
	# split graph and recersive
	var leftArr: Array[Vector2] = []
	var rightArr: Array[Vector2] = []
	for i in range(maxIndex + 1):
		leftArr.append(points[i])

	for i in range(maxIndex, points.size()):
		rightArr.append(points[i])

	var result: Array[Vector2] = RDP(leftArr,epsilon)
	var rightResult: Array[Vector2] = RDP(rightArr,epsilon)

	for i in range(1, rightResult.size()):
		result.append(rightResult[i])
	return result
