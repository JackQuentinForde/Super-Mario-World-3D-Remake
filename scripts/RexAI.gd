extends CharacterBody3D

const PATROL_SPEED = 2
const CHASE_SPEED = 3
const ROT_SPEED = 6

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {PATROL_STATE, CHASE_STATE, WAIT_STATE}
var vector
var point
var state
var player

func _ready():
	point = $Point1.global_position
	state = PATROL_STATE

func _physics_process(delta):
	$AnimationPlayer.play("walk")
	ApplyGravity(delta)
	Move(delta)
	move_and_slide()
	
func ApplyGravity(delta):
	velocity.y -= gravity * delta

func Move(delta):	
	if state == PATROL_STATE:
		Patrol(delta)
	elif state == CHASE_STATE:
		Chase(delta)
	else:
		Wait()
	
func Patrol(delta):
	vector = (point - global_position).normalized()
	var target_velocity = vector * PATROL_SPEED
	velocity.x = move_toward(velocity.x, target_velocity.x, PATROL_SPEED)
	velocity.z = move_toward(velocity.z, target_velocity.z, PATROL_SPEED)
	rotation.y = lerp_angle(rotation.y, atan2(-vector.x, -vector.z), delta * ROT_SPEED)
	
func Chase(delta):
	var playerLoc = player.global_position
	vector = (playerLoc - global_position).normalized()
	var target_velocity = vector * CHASE_SPEED
	velocity.x = move_toward(velocity.x, target_velocity.x, CHASE_SPEED)
	velocity.z = move_toward(velocity.z, target_velocity.z, CHASE_SPEED)		
	rotation.y = lerp_angle(rotation.y, atan2(-vector.x, -vector.z), delta * ROT_SPEED)
	
func Wait():
	velocity.x = 0
	velocity.z = 0

func pointReached(nextPoint):
	state = WAIT_STATE
	point = nextPoint
	$Timer.start()

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body.get_node("Mario")
		state = CHASE_STATE

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		state = PATROL_STATE

func _on_hit_area_body_entered(body):
	if body.name == "Player":
		body.call_deferred("TakeHit")

func _on_timer_timeout():
	if state == WAIT_STATE:
		state = PATROL_STATE

func _on_point_1_body_entered(body):
	if (point == $Point1.global_position and 
	body.name == self.name and 
	state == PATROL_STATE):
		pointReached($Point2.global_position)
		
func _on_point_2_body_entered(body):
	if (point == $Point2.global_position and 
	body.name == self.name and 
	state == PATROL_STATE):
		pointReached($Point1.global_position)
