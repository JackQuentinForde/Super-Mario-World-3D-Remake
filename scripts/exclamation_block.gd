extends StaticBody3D

@export var flowerBlock = false

var mushroom = preload("res://scenes/mushroom.tscn")
var fireFlower = preload("res://scenes/fire_flower.tscn")

var instance

func _on_area_3d_area_entered(area):
	if area.name == "HeadArea":
		visible = true
		$Area3D/CollisionShape3D2.call_deferred("set_disabled", true)
		$AnimationPlayer.play("bonk")
		if flowerBlock:
			instance = fireFlower.instantiate()
			add_child(instance)
		else:
			instance = mushroom.instantiate()
			instance.call_deferred("set_global_position", global_position)
			get_parent().add_child(instance)
