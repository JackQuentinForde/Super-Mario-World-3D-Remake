extends StaticBody3D

var mushroom = preload("res://scenes/mushroom.tscn")

func _on_area_3d_area_entered(area):
	if area.name == "HeadArea":
		$Area3D/CollisionShape3D2.call_deferred("set_disabled", true)
		$AnimationPlayer.play("bonk")
		var instance = mushroom.instantiate()
		add_child(instance)
