extends EnemyState

class_name EnemyPatrolState

enum {TOWARDS_END, TOWARDS_START}
var heading
var vector
var point

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	heading = TOWARDS_END
	point = persistent_state.state.end_point.global_position

func ApplyGravity(delta):
	persistent_state.velocity.y -= gravity * delta

func Move(delta):
	if persistent_state.position == point:
		ChangeDirection()
	
	if heading == TOWARDS_END:
		point = persistent_state.state.end_point.global_position
	else:
		point = persistent_state.state.start_point.global_position
		
	vector = (point - persistent_state.global_position).normalized()
	persistent_state.state.velocity = Vector3(5,5,5)
	
func ChangeDirection():
	if heading == TOWARDS_END:
		heading = TOWARDS_START
	else:
		heading = TOWARDS_END
