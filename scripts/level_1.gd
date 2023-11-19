extends Node3D

func HideMountains(isHiding):
	var mountains = get_tree().get_nodes_in_group("Mountains")
	
	if isHiding:
		for mountain in mountains:
			mountain.visible = false
	else:
		for mountain in mountains:
			mountain.visible = true
			
