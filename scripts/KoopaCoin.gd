extends Area3D

const VALUE = 1000

var popupText = preload("res://scenes/score_popup.tscn")

func _on_body_entered(_body):
	var popup = popupText.instantiate()
	popup.text = str(VALUE)
	add_child(popup)
	$AudioStreamPlayer.play()
	$AnimationPlayer.play("disappear")

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
