extends StaticBody3D

func _ready():
	$BreakableBlock.visible = true
	$GPUParticles3D.emitting = false

func _on_area_3d_area_entered(area):
	if area.name == "SpinArea":
		$CollisionShape3D.call_deferred("set_disabled", true)
		$Area3D/CollisionShape3D2.call_deferred("set_disabled", true)
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("break")
			
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "break":
		queue_free()
