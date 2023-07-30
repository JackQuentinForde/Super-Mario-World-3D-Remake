extends CharacterBody3D

const PATROL_SPEED = 4
const CHASE_SPEED = 8
const ROT_SPEED = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {TOWARDS_END, TOWARDS_START}
enum {PATROL_STATE, CHASE_STATE}
var heading
var vector
var point
var state
var player

func _ready():
	heading = TOWARDS_END
	state = PATROL_STATE

func _physics_process(delta):
	$AnimationPlayer.play("walk")
	ApplyGravity(delta)
	Move()
	move_and_slide()
	
func ApplyGravity(delta):
	velocity.y -= gravity * delta

func Move():	
	if state == PATROL_STATE:
		Patrol()
	else:
		Chase()
	
func Patrol():
	if heading == TOWARDS_END:
		point = $EndPoint.global_position
	else:
		point = $StartPoint.global_position
		
	vector = (point - global_position).normalized()
	var target_velocity = vector * PATROL_SPEED
	velocity.x = move_toward(velocity.x, target_velocity.x, PATROL_SPEED)
	velocity.z = move_toward(velocity.z, target_velocity.z, PATROL_SPEED)
	var lookDirection = Vector2(velocity.z, velocity.x)
	rotation.y = move_toward(rotation.y, lookDirection.angle_to_point(Vector2(rotation.x, rotation.z)), ROT_SPEED)
	
func Chase():
	point = player.global_position
	vector = (point - global_position).normalized()
	var target_velocity = vector * CHASE_SPEED
	velocity.x = move_toward(velocity.x, target_velocity.x, CHASE_SPEED)
	velocity.z = move_toward(velocity.z, target_velocity.z, CHASE_SPEED)
	var lookDirection = Vector2(velocity.z, velocity.x)
	rotation.y = lookDirection.angle_to_point(Vector2(rotation.x, rotation.z))
	
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

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		state = CHASE_STATE

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		state = PATROL_STATE
