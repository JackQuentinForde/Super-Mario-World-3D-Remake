extends StaticBody3D

func _ready():
	$"Flat Block".visible = false
	$BreakableBlock.visible = true
	$GPUParticles3D.emitting = false

func _on_area_3d_area_entered(area):
	if area.name == "SpinArea":
		$CollisionShape3D.call_deferred("set_disabled", true)
		$Area3D/CollisionShape3D2.call_deferred("set_disabled", true)
		$Area3D2/CollisionShape3D3.call_deferred("set_disabled", true)
		$AnimationPlayer.play("break")
			
func _on_area_3d_2_area_entered(area):
	if area.name == "HeadArea":
		$CollisionShape3D.call_deferred("set_disabled", true)
		$Area3D/CollisionShape3D2.call_deferred("set_disabled", true)
		$Area3D2/CollisionShape3D3.call_deferred("set_disabled", true)
		$AnimationPlayer.play("spin")
		$Timer.start()
			
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "break":
		queue_free()

func _on_timer_timeout():
	$AnimationPlayer.stop()
	$"Flat Block".visible = false
	$BreakableBlock.visible = true
	$CollisionShape3D.call_deferred("set_disabled", false)
	$Area3D/CollisionShape3D2.call_deferred("set_disabled", false)
	$Area3D2/CollisionShape3D3.call_deferred("set_disabled", false)
