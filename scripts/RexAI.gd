extends CharacterBody3D

const PATROL_SPEED = 2
const CHASE_SPEED = 3
const ROT_SPEED = 6

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {PATROL_STATE, CHASE_STATE, WAIT_STATE, DYING_STATE}
var vector
var point
var state
var player
var health
var scoreLabel

func _ready():
	scoreLabel = $"../CanvasLayer/Score"
	$Popup.visible = false
	$Popup2.visible = false
	point = $Point1.global_position
	health = 2
	state = PATROL_STATE

func _physics_process(delta):
	ApplyGravity(delta)
	Move(delta)
	move_and_slide()
	$Popup.rotation_degrees = Vector3(0, -90, 0)
	$Popup2.rotation_degrees = Vector3(0, -90, 0)
	
func ApplyGravity(delta):
	velocity.y -= gravity * delta

func Move(delta):	
	if state == PATROL_STATE:
		Patrol(delta)
	elif state == CHASE_STATE:
		Chase(delta)
	elif state == DYING_STATE:
		if $GPUParticles3D2.emitting == false:
			queue_free()
	else:
		Wait()
	
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
	
func TakeHit(dmg):
	health -= dmg
	
	if health > 0:
		$GPUParticles3D.emitting = true
		$Armature.scale = Vector3(1.0, 0.6, 1.0)
		$CollisionShape3D.call_deferred("set_disabled", true)
		$HitBox/CollisionShape3D.call_deferred("set_disabled", true)
		$SquishArea/CollisionShape3D.call_deferred("set_disabled", true)
		
		$CollisionShape3D2.call_deferred("set_disabled", false)
		$HitBox/CollisionShape3D2.call_deferred("set_disabled", false)
		$SquishArea/CollisionShape3D2.call_deferred("set_disabled", false)
	else:
		$GPUParticles3D2.emitting = true
		$Armature.visible = false
		$CollisionShape3D.call_deferred("set_disabled", true)
		$HitBox/CollisionShape3D.call_deferred("set_disabled", true)
		$SquishArea/CollisionShape3D.call_deferred("set_disabled", true)
		$CollisionShape3D2.call_deferred("set_disabled", true)
		$HitBox/CollisionShape3D2.call_deferred("set_disabled", true)
		$SquishArea/CollisionShape3D2.call_deferred("set_disabled", true)
		state = DYING_STATE

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
		PointReached($Point2.global_position)
		
func _on_point_2_body_entered(body):
	if (point == $Point2.global_position and 
	body.name == self.name and 
	state == PATROL_STATE):
		PointReached($Point1.global_position)

func _on_squish_area_area_entered(area):
	if area.name == "SpinArea":
		scoreLabel.text = "x " + str(int(scoreLabel.text) + 200)
		$AnimationPlayer2.play("200")
		TakeHit(2)
	elif area.name == "JumpArea" and $Armature.visible:
		if health > 1:
			scoreLabel.text = "x " + str(int(scoreLabel.text) + 200)
			$AnimationPlayer2.play("200")
		else:
			scoreLabel.text = "x " + str(int(scoreLabel.text) + 400)
			$AnimationPlayer2.play("400")
		TakeHit(1)

func _on_fireball_hit_box_body_entered(body):
	if body.is_in_group("Fireballs"):
		body.call_deferred("Destroy")
		queue_free()
