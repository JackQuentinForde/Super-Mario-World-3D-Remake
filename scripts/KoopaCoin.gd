extends Area3D

func _on_body_entered(_body):
	$AnimationPlayer.play("disappear")

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
