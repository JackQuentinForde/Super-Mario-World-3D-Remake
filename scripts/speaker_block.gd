extends StaticBody3D

@export_multiline var text = "Put your message here!"

var canvasLayer

func _ready():
	var scene = get_tree().get_current_scene().get_name()
	if scene == "Level 1":
		canvasLayer = get_parent().get_node("CanvasLayer2")
		canvasLayer.call_deferred("set_visible", false)

func _on_area_3d_area_entered(area):
	if area.name == "HeadArea":
		$AnimationPlayer.play("bonk")

func _on_animation_player_animation_finished(_anim_name):
	$AudioStreamPlayer.play()
	canvasLayer.get_node("Label").call_deferred("set_text", text)
	canvasLayer.call_deferred("set_visible", true)
	get_tree().paused = true
