extends Control

var animationPlayer
var musicPlayer

func _ready():
	$VBoxContainer/Start.grab_focus()
	animationPlayer = $"../../Camera3D/AnimationPlayer"
	musicPlayer = $"../../AudioStreamPlayer"

func _process(_delta):
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
		$AudioStreamPlayer.play()

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
