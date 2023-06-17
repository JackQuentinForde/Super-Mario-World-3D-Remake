extends Area3D

const VALUE = 1000

var scoreLabel

func _ready():
	scoreLabel = $"../Score"
	$Popup.visible = false

func _on_body_entered(_body):
	collision_mask = 0
	$Popup.visible = true
	scoreLabel.text = str(int(scoreLabel.text) + VALUE)
	$AudioStreamPlayer.play()
	$AnimationPlayer.play("disappear")

func _on_animation_player_animation_finished(_anim_name):
	$KoopaCoin.visible = false
	$Timer.start()
	
func _on_timer_timeout():
	queue_free()
