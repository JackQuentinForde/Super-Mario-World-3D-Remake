extends StaticBody3D

@export var text = "KEYBOARD CONTROLS\n
Up: Up Arrow\n
Down: Down Arrow\n
Right: Right Arrow\n
Left: Left Arrow\n
Jump: Spacebar\n
Spin Jump: Ctrl\n
Sprint: RShift\n"

func _ready():
	$CanvasLayer.visible = false
	$CanvasLayer/Label.text = text

func _on_area_3d_area_entered(area):
	if area.name == "HeadArea":
		$CanvasLayer.visible = true
		area.get_parent().call_deferred("Bonk")
		get_tree().paused = true
