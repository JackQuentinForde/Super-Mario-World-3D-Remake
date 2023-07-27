extends CharacterBody3D

const SPEED = 4

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {TOWARDS_END, TOWARDS_START}
var heading
var vector
var point

func _ready():
	heading = TOWARDS_END

func _physics_process(delta):
	$AnimationPlayer.play("walk")
	ApplyGravity(delta)
	Move()
	move_and_slide()
	
func ApplyGravity(delta):
	velocity.y -= gravity * delta

func Move():	
	if heading == TOWARDS_END:
		point = $EndPoint.global_position
	else:
		point = $StartPoint.global_position
		
	vector = (point - global_position).normalized()
	var target_velocity = (vector * SPEED)
	velocity.x = move_toward(velocity.x, target_velocity.x, SPEED)
	velocity.z = move_toward(velocity.z, target_velocity.z, SPEED)
	var lookDirection = -Vector2(velocity.z, velocity.x)
	rotation.y = lookDirection.angle()
	
func ChangeDirection():
	if heading == TOWARDS_END:
		heading = TOWARDS_START
	else:
		heading = TOWARDS_END

func _on_start_point_body_entered(body):
	if body.name == self.name and heading == TOWARDS_START:
		ChangeDirection()

func _on_end_point_body_entered(body):
	if body.name == self.name and heading == TOWARDS_END:
		ChangeDirection()
