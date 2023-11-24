extends Node3D

func _ready():
	if get_node("Player").isLuigi:
		get_node("CanvasLayer/TextureRect2").call_deferred("set_texture", load("res://assets/textures/Luigi HUD.png"))

func HideMountains(isHiding):
	var mountains = get_tree().get_nodes_in_group("Mountains")
	
	if isHiding:
		for mountain in mountains:
			mountain.visible = false
	else:
		for mountain in mountains:
			mountain.visible = true
			
