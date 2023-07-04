extends Node3D

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		$Area3D/CollisionShape3D3.call_deferred("set_disabled", true)
		$Area3D/CheckpointBar.call_deferred("set_visible", false)
