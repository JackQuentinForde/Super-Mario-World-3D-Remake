extends CharacterBody3D

const SPEED = 2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {MOVE_STATE, WAIT_STATE, HIDE_STATE, DYING_STATE}
var point
var vector
var state
var playerNearby

func _ready():
	playerNearby = false
	point = $SouthPoint.global_position
	state = MOVE_STATE

func _physics_process(delta):
	ApplyGravity(delta)
	Action(delta)
	move_and_slide()

func ApplyGravity(delta):
	velocity.y -= gravity * delta
	
func Action(delta):	
	if state == MOVE_STATE:
		Move(delta)
	elif state == WAIT_STATE:
		Wait()
	elif state == HIDE_STATE:
		Hide()
	else:
		Die()
		
func Move(delta):
	$AnimationPlayer.play("Bite")
	vector = (point - global_position).normalized()
	var target_velocity = vector * SPEED
	velocity.y = move_toward(velocity.y, target_velocity.y, SPEED)
	
func Wait():
	velocity.x = 0
	velocity.z = 0
	
func Hide():
	if !playerNearby:
		state = MOVE_STATE
	
func PointReached(nextPoint):
	state = WAIT_STATE
	point = nextPoint
	$Timer.start()
	
func Die():
	queue_free()

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		playerNearby = true

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		playerNearby = false

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.call_deferred("TakeHit")

func _on_timer_timeout():
	if state == WAIT_STATE:
		if playerNearby:
			state = HIDE_STATE
		else:
			state = MOVE_STATE
			
func _on_north_point_body_entered(body):
	if (point == $NorthPoint.global_position and 
	body.name == self.name and 
	state == MOVE_STATE):
		PointReached($SouthPoint.global_position)

func _on_south_point_body_entered(body):
	if (point == $SouthPoint.global_position and 
	body.name == self.name and 
	state == MOVE_STATE):
		PointReached($NorthPoint.global_position)
