extends Control

var animationPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$VBoxContainer/Start.grab_focus()
	animationPlayer = $"../../Camera3D/AnimationPlayer"

func _on_start_pressed():
	animationPlayer.play("start")

func _on_quit_pressed():
	animationPlayer.play("quit")
