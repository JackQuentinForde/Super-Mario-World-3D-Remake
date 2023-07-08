extends StaticBody3D

func _on_area_3d_area_entered(area):
	if area.name == "HeadArea":
		$Area3D/CollisionShape3D2.call_deferred("set_disabled", true)
		$AnimationPlayer.play("bonk")
