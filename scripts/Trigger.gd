extends Area3D

var mushroom = preload("res://scenes/mushroom.tscn")

func _on_body_entered(body):
	if body is CharacterBody3D:
		$CollisionShape3D.set_deferred("disabled", true)
		var instance = mushroom.instantiate()
		add_child(instance)
