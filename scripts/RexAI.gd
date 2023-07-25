extends CharacterBody3D

const SPEED = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	ApplyGravity(delta)
	move_and_slide()

func ApplyGravity(delta):
	velocity.y -= gravity * delta
