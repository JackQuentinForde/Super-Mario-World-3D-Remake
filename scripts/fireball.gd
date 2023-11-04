extends RigidBody3D

func _ready():
	position.y = position.y + 7
	fire()

func fire():
	apply_force(Vector3(0, 0, 800))
	$Timer.start()
	
func _on_timer_timeout():
	queue_free()

func _on_fire_area_body_entered(body):
	if body is CharacterBody3D:
		queue_free()

func _on_fire_area_area_entered(area):
	if area.name == "HitBox":
		queue_free()
