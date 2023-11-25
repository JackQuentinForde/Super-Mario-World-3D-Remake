extends Camera3D

const CAM_SPEED = 4

var originalZPos

func _ready():
	$AnimationPlayer.play("fadein")
	originalZPos = global_position.z

func _process(delta):
	global_position.z += CAM_SPEED * delta
	if global_position.z >= 305 && not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("fadeout")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fadeout":
		global_position.z = originalZPos 
		$AnimationPlayer.play("fadein")
	elif anim_name == "start":
		get_tree().change_scene_to_file("res://scenes/level_1.tscn")
	elif anim_name == "quit":
		get_tree().quit()
