extends EnemyState

class_name EnemyChaseState

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func ApplyGravity(delta):
	velocity.y -= gravity * delta

func Move():
	pass
