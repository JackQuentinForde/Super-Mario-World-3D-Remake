extends Node3D

const VALUE = 1000

var scoreLabel
var popup

func _ready():
	$AudioStreamPlayer.play()
	scoreLabel = $"../../CanvasLayer/HBoxContainer/Score"
	popup = $Popup
	popup.visible = false

func _on_hit_box_body_entered(body):
	if body.name == "Player":
		$HitBox/CollisionShape3D.call_deferred("set_disabled", true)
		popup.visible = true
		scoreLabel.text = "x" + str(int(scoreLabel.text) + VALUE)
		$"Fire Flower2".visible = false
		$Stem.visible = false
		$Feet.visible = false
		body.call_deferred("FirePower")
		$Timer.start()

func _on_timer_timeout():
	queue_free()
