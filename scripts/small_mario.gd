extends Node3D

var bodyMaterial
var hatMaterial
var armsMaterial
var legsMaterial

func _ready():
	var isLuigi = get_parent().isLuigi
	
	if isLuigi:
		bodyMaterial = preload("res://materials/luigi_body.tres")
		hatMaterial = preload("res://materials/luigi_hat.tres")
		armsMaterial = preload("res://materials/luigi_arms.tres")
		legsMaterial = preload("res://materials/luigi_legs.tres")
	else:
		bodyMaterial = preload("res://materials/mario_body.tres")
		hatMaterial = preload("res://materials/mario_hat.tres")
		armsMaterial = preload("res://materials/mario_arms.tres")
		legsMaterial = preload("res://materials/mario_legs.tres")
		
	$Armature/Skeleton3D/Body.set_surface_override_material(0, bodyMaterial)
	$Armature/Skeleton3D/Hat.set_surface_override_material(0, hatMaterial)
	$Armature/Skeleton3D/LeftArm.set_surface_override_material(0, armsMaterial)
	$Armature/Skeleton3D/RightArm.set_surface_override_material(0, armsMaterial)
	$Armature/Skeleton3D/LeftLeg.set_surface_override_material(0, legsMaterial)
	$Armature/Skeleton3D/RightLeg.set_surface_override_material(0, legsMaterial)
