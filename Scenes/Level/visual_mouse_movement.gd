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

var drawing_points: Array[Vector2] = []
var mousePosition: Vector2
var startMousePosition: Vector2


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

		# Check for left mouse button release
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:

			# Stop drawing
			mouseState = State.NOT_DRAWING

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
