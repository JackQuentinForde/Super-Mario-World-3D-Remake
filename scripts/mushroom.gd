extends RigidBody3D

const VALUE = 1000

var scoreLabel
var popup
var rng = RandomNumberGenerator.new()

func _ready():
	scoreLabel = $"../../../CanvasLayer/Score"
	popup = $"../Popup"
	popup.visible = false
	jump()
	
func jump():
	var rand_x = rng.randf_range(-200.0, 200.0)
	var rand_z = rng.randf_range(-200.0, 200.0)
	apply_force(Vector3(rand_x, 400, rand_z))

func _on_body_entered(body):
	if body.name == "Player":
		collision_mask = 0
		popup.position = Vector3(position.x, position.y + 2, position.z)
		popup.visible = true
		scoreLabel.text = "x " + str(int(scoreLabel.text) + VALUE)
		$MushroomMesh.visible = false
		body.call_deferred("ChangeSize", body.SIZE_BIG)
		$Timer.start()

func _on_timer_timeout():
	get_parent().queue_free()
