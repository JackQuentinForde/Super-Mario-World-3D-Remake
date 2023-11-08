extends CharacterBody3D

const SPEED = 2

enum {MOVE_STATE, WAIT_STATE, HIDE_STATE, DYING_STATE}
var point
var vector
var state
var playerNearby
var rng = RandomNumberGenerator.new()

func _ready():
	playerNearby = false
	point = $NorthPoint.global_position
	state = MOVE_STATE
	var waitTime = rng.randf_range(0, 4.0)
	$Timer2.wait_time = waitTime
	$Timer2.start()

func _physics_process(_delta):
	if ($Timer2.is_stopped()):
		Action()
		move_and_slide()
	
func Action():	
	if state == MOVE_STATE:
		Move()
	elif state == WAIT_STATE:
		Wait()
	elif state == HIDE_STATE:
		Hide()
	else:
		Die()
		
func Move():
	$AnimationPlayer.play("Bite", -1, 0.5, false)
	vector = (point - global_position).normalized()
	var target_velocity = vector * SPEED
	velocity.y = move_toward(velocity.y, target_velocity.y, SPEED)
	
func Wait():
	if point == $SouthPoint.global_position:
		$AnimationPlayer.play("Bite", -1, 0.5, false)
	velocity = Vector3(0, 0, 0)
	
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
		if playerNearby and point == $NorthPoint.global_position:
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

func _on_fireball_hit_box_body_entered(body):
	if body.name == "Fireball":
		body.call_deferred("Destroy")
		Die()
