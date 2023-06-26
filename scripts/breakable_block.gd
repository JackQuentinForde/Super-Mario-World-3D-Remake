extends StaticBody3D

func _ready():
	$BreakableBlock.visible = true

func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		if body.call_deferred("CheckSpinJump") == false:
			$CollisionShape3D.call_deferred("set_disabled", true)
			$AnimationPlayer.play("break")
			
func _on_animation_player_animation_finished(_anim_name):
	queue_free()
