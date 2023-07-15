extends Node3D

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		body.call_deferred("Win")
		$Area3D/CollisionShape3D.call_deferred("set_disabled", true)
		$Area3D/EndGoalBar.call_deferred("set_visible", false)
