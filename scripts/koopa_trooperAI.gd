extends CharacterBody3D

const PATROL_SPEED = 2
const CHASE_SPEED = 3
const SLIDE_SPEED = 4
const ROT_SPEED = 6

var rewardCoin = preload("res://scenes/RewardCoin.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {SLIDE_STATE, PATROL_STATE, CHASE_STATE, WAIT_STATE, DYING_STATE}
var vector
var point
var state
var player
var touchedGround
var scoreLabel

func _ready():
	scoreLabel = $"../CanvasLayer/HBoxContainer/Score"
	touchedGround = false
	position = $StartPos.global_position
	point = $Point1.global_position
	state = SLIDE_STATE

func _physics_process(delta):
	ApplyGravity(delta)
	Move(delta)
	move_and_slide()
	$Popup.rotation_degrees = Vector3(0, -90, 0)
	
func ApplyGravity(delta):
	velocity.y -= gravity * delta

func Move(delta):	
	if state == SLIDE_STATE:
		Slide()
	elif state == PATROL_STATE:
		Patrol(delta)
	elif state == CHASE_STATE:
		Chase(delta)
	elif state == DYING_STATE:
		if $GPUParticles3D.emitting == false:
			queue_free()
	else:
		Wait()
		
func Slide():
	$AnimationPlayer.play("Slide")
	if is_on_floor() && not touchedGround:
		velocity.z = -SLIDE_SPEED
	elif velocity.z != 0:
		touchedGround = true
		velocity.z = move_toward(velocity.z, 0, 0.04)
		
func Patrol(delta):
	$AnimationPlayer.play("Walk")
	vector = (point - global_position).normalized()
	var target_velocity = vector * PATROL_SPEED
	velocity.x = move_toward(velocity.x, target_velocity.x, PATROL_SPEED)
	velocity.z = move_toward(velocity.z, target_velocity.z, PATROL_SPEED)
	rotation.y = lerp_angle(rotation.y, atan2(-vector.x, -vector.z), delta * ROT_SPEED)
	
func Chase(delta):
	$AnimationPlayer.play("Walk")
	var playerLoc = player.global_position
	vector = (playerLoc - global_position).normalized()
	var target_velocity = vector * CHASE_SPEED
	velocity.x = move_toward(velocity.x, target_velocity.x, CHASE_SPEED)
	velocity.z = move_toward(velocity.z, target_velocity.z, CHASE_SPEED)		
	rotation.y = lerp_angle(rotation.y, atan2(-vector.x, -vector.z), delta * ROT_SPEED)
	
func Wait():
	$AnimationPlayer.play("Idle")
	velocity.x = 0
	velocity.z = 0

func PointReached(nextPoint):
	state = WAIT_STATE
	point = nextPoint
	$Timer.start()
	
func TakeHit():
	$GPUParticles3D.emitting = true
	$Armature.visible = false
	$CollisionShape3D.call_deferred("set_disabled", true)
	$HitBox/CollisionShape3D.call_deferred("set_disabled", true)
	$SquishArea/CollisionShape3D.call_deferred("set_disabled", true)
	$CollisionShape3D2.call_deferred("set_disabled", true)
	$HitBox/CollisionShape3D2.call_deferred("set_disabled", true)
	$SquishArea/CollisionShape3D.call_deferred("set_disabled", true)
	scoreLabel.text = "x" + str(int(scoreLabel.text) + 200)
	$AnimationPlayer2.play("200")
	state = DYING_STATE

func _on_detection_area_body_entered(body):
	if body.name == "Player" and state != SLIDE_STATE:
		player = body.get_node("Mario")
		state = CHASE_STATE
		
func _on_detection_area_body_exited(body):
	if body.name == "Player" and state != SLIDE_STATE:
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
		PointReached($Point2.global_position)
		
func _on_point_2_body_entered(body):
	if (point == $Point2.global_position and 
	body.name == self.name and 
	state == PATROL_STATE):
		PointReached($Point1.global_position)

func _on_squish_area_area_entered(area):
	if area.name == "SpinArea" or area.name == "JumpArea":
		TakeHit()

func _on_timer_2_timeout():
	if state == SLIDE_STATE:
		state = PATROL_STATE

func _on_fireball_hit_box_body_entered(body):
	if body.is_in_group("Fireballs"):
		SpawnCoin()
		body.call_deferred("Destroy")
		queue_free()
		
func SpawnCoin():
	var instance = rewardCoin.instantiate()
	instance.call_deferred("set_global_position", global_position)
	get_parent().add_child(instance)
