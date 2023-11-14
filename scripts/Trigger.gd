extends Area3D

var mushroom = preload("res://scenes/mushroom.tscn")

func _on_body_entered(body):
	if body.name == "Player":
		$CollisionShape3D.set_deferred("disabled", true)
		var instance = mushroom.instantiate()
		instance.global_position = global_position
		get_parent().add_child(instance)
