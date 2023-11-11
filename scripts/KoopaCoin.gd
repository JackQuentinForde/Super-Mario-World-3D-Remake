extends Area3D

@export var VALUE = 4000

var scoreLabel

func _ready():
	scoreLabel = $"../CanvasLayer/Score"
	$Popup.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		collision_mask = 0
		$Popup.visible = true
		scoreLabel.text = "x " + str(int(scoreLabel.text) + VALUE)
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("disappear")

func _on_animation_player_animation_finished(_anim_name):
	$Mesh.visible = false
	$Timer.start()
	
func _on_timer_timeout():
	queue_free()
