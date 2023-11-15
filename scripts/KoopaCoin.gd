extends Area3D

@export var VALUE = 4000

var scoreLabel

func _ready():
	scoreLabel = $"../CanvasLayer/HBoxContainer/Score"
	$Popup.visible = false
	SetPopupMaterial()

func _on_body_entered(body):
	if body.name == "Player":
		collision_mask = 0
		$Popup.visible = true
		scoreLabel.text = "x" + str(int(scoreLabel.text) + VALUE)
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("disappear")

func SetPopupMaterial():
	match VALUE:
		1000: 
			$Popup.texture = load("res://assets/textures/1000_Texture.png")
			$Popup.material_override = load("res://materials/1000.tres")
		2000: 
			$Popup.texture = load("res://assets/textures/2000_Texture.png")
			$Popup.material_override = load("res://materials/2000.tres")
		4000: 
			$Popup.texture = load("res://assets/textures/4000_Texture.png")
			$Popup.material_override = load("res://materials/4000.tres")
		8000: 
			$Popup.texture = load("res://assets/textures/8000_Texture.png")
			$Popup.material_override = load("res://materials/8000.tres")

func _on_animation_player_animation_finished(_anim_name):
	$Mesh.visible = false
	$Timer.start()
	
func _on_timer_timeout():
	queue_free()
