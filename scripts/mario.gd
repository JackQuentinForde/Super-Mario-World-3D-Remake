extends Node3D

var fireBodyMaterial = preload("res://materials/fire_mario_body.tres")
var fireHatMaterial = preload("res://materials/fire_mario_hat.tres")
var fireArmsMaterial = preload("res://materials/fire_mario_arms.tres")
var fireLegsMaterial = preload("res://materials/fire_mario_legs.tres")

var bodyMaterial = preload("res://materials/mario_body.tres")
var hatMaterial = preload("res://materials/mario_hat.tres")
var armsMaterial = preload("res://materials/mario_arms.tres")
var legsMaterial = preload("res://materials/mario_legs.tres")

func FirePower():
	$Armature/Skeleton3D/Body.set_surface_override_material(0, fireBodyMaterial)
	$Armature/Skeleton3D/Hat.set_surface_override_material(0, fireHatMaterial)
	$Armature/Skeleton3D/LeftArm.set_surface_override_material(0, fireArmsMaterial)
	$Armature/Skeleton3D/RightArm.set_surface_override_material(0, fireArmsMaterial)
	$Armature/Skeleton3D/LeftLeg.set_surface_override_material(0, fireLegsMaterial)
	$Armature/Skeleton3D/RightLeg.set_surface_override_material(0, fireLegsMaterial)
	
func RemoveFirePower():
	$Armature/Skeleton3D/Body.set_surface_override_material(0, bodyMaterial)
	$Armature/Skeleton3D/Hat.set_surface_override_material(0, hatMaterial)
	$Armature/Skeleton3D/LeftArm.set_surface_override_material(0, armsMaterial)
	$Armature/Skeleton3D/RightArm.set_surface_override_material(0, armsMaterial)
	$Armature/Skeleton3D/LeftLeg.set_surface_override_material(0, legsMaterial)
	$Armature/Skeleton3D/RightLeg.set_surface_override_material(0, legsMaterial)
