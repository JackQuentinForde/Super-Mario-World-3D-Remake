extends Control

var animationPlayer
var musicPlayer

func _ready():
	$VBoxContainer/Start.grab_focus()
	animationPlayer = $"../../Camera3D/AnimationPlayer"
	musicPlayer = $"../../AudioStreamPlayer"

func _input(_event):
	if (not $VBoxContainer/Start.has_focus() 
	and not $VBoxContainer/Quit.has_focus()):
		$VBoxContainer/Start.grab_focus()

func _on_start_pressed():
	$AudioStreamPlayer2.play()
	musicPlayer.stop()
	animationPlayer.play("start")

func _on_quit_pressed():
	musicPlayer.stop()
	animationPlayer.play("quit")

func _on_start_focus_entered():
	$AudioStreamPlayer.play()

func _on_quit_focus_entered():
	$AudioStreamPlayer.play()
