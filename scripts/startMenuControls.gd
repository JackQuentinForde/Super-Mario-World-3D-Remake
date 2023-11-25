extends Control

var animationPlayer

func _ready():
	$VBoxContainer/Start.grab_focus()
	animationPlayer = $"../../Camera3D/AnimationPlayer"

func _input(_event):
	if (not $VBoxContainer/Start.has_focus() 
	and not $VBoxContainer/Quit.has_focus()):
		$VBoxContainer/Start.grab_focus()

func _on_start_pressed():
	animationPlayer.play("start")

func _on_quit_pressed():
	animationPlayer.play("quit")
