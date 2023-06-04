extends Node3D

var mousSensitivity := 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation_degrees.y = -90
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mousSensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
