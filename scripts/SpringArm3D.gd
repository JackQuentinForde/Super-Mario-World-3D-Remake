extends SpringArm3D

var mousSensitivity := 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mousSensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		rotation_degrees.y -= event.relative.x * mousSensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
