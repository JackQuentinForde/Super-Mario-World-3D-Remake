extends CharacterBody3D

const SPEED = 10
const ROT_SPEED = 1

var state
var player
var vector
var point

enum {CHASE_STATE, WAIT_STATE, LOST_STATE, DYING_STATE}

func _ready():
	self.visible = false
	state = WAIT_STATE

func _physics_process(delta):
	Action(delta)
	move_and_slide()
	
func Action(delta):	
	if state == WAIT_STATE:
		Wait()
	elif state == CHASE_STATE:
		Chase(delta)
	elif state == LOST_STATE:
		FlyAway(delta)
	else:
		queue_free()
		
func Wait():
	velocity.x = 0
	velocity.z = 0
	
func Chase(delta):
	var playerLoc = player.global_position
	vector = (playerLoc - global_position).normalized()
	var target_velocity = vector * SPEED
	velocity.x = move_toward(velocity.x, target_velocity.x, SPEED)
	velocity.z = move_toward(velocity.z, target_velocity.z, SPEED)
	rotation.y = lerp_angle(rotation.y, atan2(-vector.x, -vector.z), delta * ROT_SPEED)
	
func FlyAway(delta):
	var target_velocity = vector * SPEED
	velocity.x = move_toward(velocity.x, target_velocity.x, SPEED)
	velocity.z = move_toward(velocity.z, target_velocity.z, SPEED)
	rotation.y = lerp_angle(rotation.y, atan2(-vector.x, -vector.z), delta * ROT_SPEED)
	
func GetLost():
	$CollisionShape3D.call_deferred("set_disabled", true)
	$Timer.start()
	state = LOST_STATE

func _on_detection_area_body_entered(body):
	if body.name == "Player" and state != LOST_STATE:
		player = body.get_node("Mario")
		self.visible = true
		state = CHASE_STATE

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		GetLost()

func _on_timer_timeout():
	state = DYING_STATE

func _on_hit_area_body_entered(body):
	if body.name == "Player":
		body.call_deferred("TakeHit")
		GetLost()
	elif body.is_in_group("Fireballs"):
		body.call_deferred("Destroy")
	elif body is StaticBody3D:
		state = DYING_STATE
