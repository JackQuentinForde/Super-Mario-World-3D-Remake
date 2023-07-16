extends CharacterBody3D

const WALK_SPEED = 8
const RUN_SPEED = 16
const TURN_SPEED = 1
const AIR_TURN_SPEED = 0.2
const ACCEL = 0.18
const JUMP_ACCEL = 1
const JUMP_MIN_VELOCITY = 5
const JUMP_MAX_VELOCITY = 9
const ANIMATION_RUN_SPEED = 1.5
const ANIMATION_SPRINT_SPEED = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jumping = false
var jumpReleased = true
var spinJumpReleased = true
var spinJump = false
var invincible = false
var fallen = false
var win = false
var speed
var turnSpeed
var currentSize
var respawnPoint

enum {SIZE_SMALL, SIZE_BIG}

# variables that are set in the ready function
var cameraBasis
var mario
var animationPlayer
var animationPlayer2
var headBox
var canvasAnimationPlayer
var music

func _ready():
	currentSize = SIZE_SMALL
	cameraBasis = $CameraBasis
	mario = $SmallMario
	animationPlayer = $SmallMario/AnimationPlayer
	animationPlayer2 = $SmallMario/AnimationPlayer2
	headBox = $HeadArea/CollisionShape3D
	canvasAnimationPlayer = $"../CanvasLayer/AnimationPlayer"
	music = $"../Music"
	cameraBasis.rotation_degrees.y = -90
	speed = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	respawnPoint = position
	canvasAnimationPlayer.call_deferred("play", "fadein")

func _physics_process(delta):
	ApplyGravity(delta)
	move_and_slide()
	AnimationLogic()
	CheckWin()
	if not win:
		JumpLogic()
		SpinJumpLogic()
		SetMoveSpeed()
		SetTurnSpeed()
		MoveLogic()
		CheckInvincible()
		CheckFallen()
		
func SetMoveSpeed():
	if Input.is_action_pressed("player_sprint") and is_on_floor():
		speed = min(speed + ACCEL, RUN_SPEED)
	else:
		if speed > WALK_SPEED:
			speed = max(speed - ACCEL, WALK_SPEED)
		elif speed < WALK_SPEED:
			speed = min(speed + ACCEL, WALK_SPEED)
		
func SetTurnSpeed():
	if not is_on_floor():
		turnSpeed = AIR_TURN_SPEED
		headBox.call_deferred("set_disabled", false)
	else:
		turnSpeed = TURN_SPEED
		headBox.call_deferred("set_disabled", true)
		
func MoveLogic():
	var input_dir = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		direction = direction.rotated(Vector3.UP, cameraBasis.rotation.y).normalized()
		var target_velocity = direction * speed
		velocity.x = move_toward(velocity.x, target_velocity.x, turnSpeed)
		velocity.z = move_toward(velocity.z, target_velocity.z, turnSpeed)
		if not spinJump:
			var lookDirection = Vector2(velocity.z, velocity.x)
			mario.rotation.y = lookDirection.angle()
	else:
		velocity.x = move_toward(velocity.x, 0, turnSpeed)
		velocity.z = move_toward(velocity.z, 0, turnSpeed)	
		
func JumpLogic():
	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor():
			velocity.y = JUMP_MIN_VELOCITY
			$JumpSound.play()
			jumpReleased = false
	elif Input.is_action_pressed("player_jump") and !jumpReleased:
		velocity.y = min(velocity.y + JUMP_ACCEL, JUMP_MAX_VELOCITY)
		jumpReleased = velocity.y >= JUMP_MAX_VELOCITY
	else:
		jumpReleased = true
		
func SpinJumpLogic():
	if Input.is_action_just_pressed("player_spin_jump"):
		if is_on_floor():
			SpinJump()
			$SpinSound.play()
			spinJumpReleased = false
	elif Input.is_action_pressed("player_spin_jump") and !spinJumpReleased:
		velocity.y = min(velocity.y + JUMP_ACCEL, JUMP_MAX_VELOCITY)
		spinJumpReleased = velocity.y >= JUMP_MAX_VELOCITY
	else:
		spinJumpReleased = true
	
	if (animationPlayer.is_playing() and 
	animationPlayer.current_animation == "SpinJump" and 
	velocity.y <= 0):
		$SpinArea/CollisionShape3D.call_deferred("set_disabled", false)
		
func SpinJump():
	velocity.y = JUMP_MIN_VELOCITY
	spinJump = true
		
func ApplyGravity(delta):
	velocity.y -= gravity * delta
		
func ChangeSize(size):
	if currentSize == size:
		pass
	
	if size == SIZE_BIG:
		$MarioBodyCollision.disabled = false
		$MarioHeadCollision.disabled = false
		$SmallMarioBodyCollision.disabled = true
		$SmallMarioHeadCollision.disabled = true
		headBox = $HeadArea/CollisionShape3D2
		$SmallMario.visible = false
		$Mario.visible = true
		mario = $Mario
		animationPlayer = $Mario/AnimationPlayer
		animationPlayer2 = $Mario/AnimationPlayer2
	else:
		$SmallMarioBodyCollision.disabled = false
		$SmallMarioHeadCollision.disabled = false
		$MarioBodyCollision.disabled = true
		$MarioHeadCollision.disabled = true
		headBox = $HeadArea/CollisionShape3D
		$Mario.visible = false
		$SmallMario.visible = true
		mario = $SmallMario
		animationPlayer = $SmallMario/AnimationPlayer
		animationPlayer2 = $SmallMario/AnimationPlayer2
	
	animationPlayer.play("Jump", 1, 1, true)
	animationPlayer2.play("Flash")
		
func AnimationLogic():
	if is_on_floor():
		jumping = false
		spinJump = false
		$SpinArea/CollisionShape3D.call_deferred("set_disabled", true)
		if velocity.x != 0 or velocity.z != 0:
			if speed == RUN_SPEED:
				animationPlayer.play("Sprint")
				animationPlayer.speed_scale = ANIMATION_SPRINT_SPEED
			else:
				animationPlayer.play("Walk")
				if Input.is_action_pressed("player_sprint"):
					animationPlayer.speed_scale = ANIMATION_RUN_SPEED
				else:
					animationPlayer.speed_scale = 1
		else:
			animationPlayer.play("Idle")
	else:
		if spinJump:
			animationPlayer.speed_scale = ANIMATION_RUN_SPEED
			animationPlayer.play("SpinJump")
			jumping = true
			spinJump = false
		elif not jumping:
			animationPlayer.speed_scale = 1
			animationPlayer.play("Jump")
			jumping = true
			
func CheckInvincible():
	if animationPlayer2.is_playing():
		invincible = true
	else:
		invincible = false
		
func SetSpawn():
	respawnPoint.x = position.x
	respawnPoint.z = position.z - 2
		
func CheckFallen():
	if position.y < respawnPoint.y - 15 and not fallen:
		music.stop()
		fallen = true
		cameraBasis.call_deferred("set_as_top_level", true)
		canvasAnimationPlayer.call_deferred("play", "fadeout")
	elif fallen:
		if not canvasAnimationPlayer.is_playing():
			Respawn()

func Respawn():
	music.play()
	ChangeSize(SIZE_SMALL)
	cameraBasis.call_deferred("set_as_top_level", false)
	canvasAnimationPlayer.call_deferred("play", "fadein")
	position = respawnPoint
	cameraBasis.global_position = Vector3(position.x, position.y + 9, position.z)
	fallen = false
	
func Win():
	music.stop()
	canvasAnimationPlayer.call_deferred("play", "fadeout")
	win = true
	
func CheckWin():
	if win and not canvasAnimationPlayer.is_playing():
		get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_spin_area_area_entered(area):
	if area.get_parent().is_in_group("BreakableBlocks"):
		SpinJump()
