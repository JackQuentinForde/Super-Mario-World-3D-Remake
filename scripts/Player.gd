extends CharacterBody3D

@export var isLuigi = false

var overworldEnvironment = preload("res://environments/overworld.tres")
var undergroundEnvironment = preload("res://environments/underground.tres")

var fireBall = preload("res://scenes/fireball.tscn")

const WALK_SPEED = 9
const RUN_SPEED = 18
const TURN_SPEED = 0.8
const AIR_TURN_SPEED = 0.4
const ACCEL = 0.2
const JUMP_ACCEL = 2
const JUMP_MIN_VELOCITY = 5
const JUMP_MAX_VELOCITY = 16

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravMultiplier = 1

var jumping = false
var jumpReleased = true
var spinJumpReleased = true
var spinJump = false
var invincible = false
var fallen = false
var fadeout = false
var enteringPipe = false
var inPipeZone = false
var gotCheckpoint = false
var hasFirePower = false
var target_velocity = Vector3(0, 0, 1)
var speed
var turnSpeed
var currentSize
var respawnPoint
var lastPipe
var originalCameraPos
var currentAnimationTreeAnimation
var mario
var animationPlayer
var animationPlayer2
var animationTree
var headBox
var canvasAnimationPlayer
var music
var undergroundMusic

enum {SIZE_SMALL, SIZE_BIG}

func _ready():
	AudioServer.set_bus_effect_enabled(1, 0, false)
	get_parent().get_node("WorldEnvironment").call_deferred("set_environment", overworldEnvironment)
	currentSize = SIZE_SMALL
	originalCameraPos = $CameraBasis.global_position
	mario = $SmallMario
	animationPlayer = $SmallMario/AnimationPlayer
	animationPlayer2 = $SmallMario/AnimationPlayer2
	animationTree = $Mario/AnimationTree
	headBox = $HeadArea/CollisionShape3D
	canvasAnimationPlayer = $"../CanvasLayer/AnimationPlayer"
	music = $"../Music"
	undergroundMusic = $"../UndergroundMusic"
	$CameraBasis.rotation_degrees.y = -90
	speed = 0
	respawnPoint = position
	canvasAnimationPlayer.call_deferred("play", "fadein")

func _physics_process(delta):
	ApplyGravity(delta)
	move_and_slide()
	AnimationLogic()
	CheckWin()
	if not fadeout and not enteringPipe:
		JumpLogic()
		SpinJumpLogic()
		SetMoveSpeed()
		SetTurnSpeed()
		MoveLogic()
		CheckInvincible()
		CheckFallen()
		EnterPipeLogic()
		FireBallLogic()
		
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
		direction = direction.rotated(Vector3.UP, $CameraBasis.rotation.y).normalized()
		target_velocity = direction * speed
		velocity.x = move_toward(velocity.x, target_velocity.x, turnSpeed)
		velocity.z = move_toward(velocity.z, target_velocity.z, turnSpeed)
		if not spinJump:
			var lookDirection = Vector2(velocity.z, velocity.x)
			mario.rotation.y = lookDirection.angle()
	else:
		velocity.x = move_toward(velocity.x, 0, turnSpeed)
		velocity.z = move_toward(velocity.z, 0, turnSpeed)
		
	if is_on_ceiling() and not is_on_floor():
		Bonk()	
		
func JumpLogic():
	if Input.is_action_just_pressed("player_jump"):
		animationTree.active = false
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
		animationTree.active = false
		if is_on_floor():
			SpinJump()
			$Timer3.start()
			$SpinSound.play()
			spinJumpReleased = false
			if hasFirePower:
				DoubleShot()
	elif Input.is_action_pressed("player_spin_jump") and !spinJumpReleased:
		velocity.y = min(velocity.y + JUMP_ACCEL, JUMP_MAX_VELOCITY)
		spinJumpReleased = velocity.y >= JUMP_MAX_VELOCITY
	else:
		spinJumpReleased = true
		
func EnterPipeLogic():
	if Input.is_action_just_pressed("player_enter_pipe") and is_on_floor() and inPipeZone:
		enteringPipe = true
		position.x = lastPipe.global_position.x
		mario.rotation = Vector3(0,0,0)
		if lastPipe.name == "Exit Pipe":
			animationPlayer.play("Walk", -1, 1.25, false)
			velocity = Vector3(0, 0, WALK_SPEED)
		else:
			velocity = Vector3.ZERO
			position.z = lastPipe.global_position.z
			gravMultiplier = 0.5
		lastPipe.call_deferred("DisableCollisions")
		
func SpinJump():
	velocity.y = JUMP_MIN_VELOCITY
	gravMultiplier = 1.5
	spinJump = true
	
func SpinBounce():
	velocity.y = JUMP_MAX_VELOCITY
	gravMultiplier = 1.5
	spinJump = true
	
func Bounce():
	velocity.y = JUMP_MAX_VELOCITY
	gravMultiplier = 1.5
		
func ApplyGravity(delta):
	velocity.y -= (gravity * gravMultiplier) * delta
		
func ChangeSize(size):
	if currentSize == size:
		pass
	
	if size == SIZE_BIG:
		$GrowSound.play()
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
		RemoveFirePower()
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
	
	currentSize = size
	animationPlayer.play("Jump", -1, 1.75, true)
	animationPlayer2.play("Flash")
	
func FirePower():
	ChangeSize(SIZE_BIG)
	$Mario.call_deferred("FirePower")
	hasFirePower = true
	
func RemoveFirePower():
	$Mario.call_deferred("RemoveFirePower")
	hasFirePower = false
	
func FireBallLogic():
	if hasFirePower and Input.is_action_just_pressed("player_sprint"):
		Shoot()
		
func Shoot():
	if $Timer.is_stopped():
		var currentAnimation = animationPlayer.current_animation
		if currentAnimation != "Jump" and currentAnimation != "SpinJump":
			animationTree.call_deferred("setAnimation", currentAnimation)
			currentAnimationTreeAnimation = currentAnimation
			animationTree.active = true
		var instance = fireBall.instantiate()
		add_child(instance)
		$Timer.start()
		
func DoubleShot():
	if $Timer.is_stopped():
		var instance = fireBall.instantiate()
		add_child(instance)
		$Timer.start()
		$Timer2.start()
		
func AnimationLogic():
	if currentAnimationTreeAnimation != animationPlayer.current_animation:
		animationTree.active = false
	if is_on_floor():
		jumping = false
		spinJump = false
		gravMultiplier = 1
		if velocity.x != 0 or velocity.z != 0:
			if speed == RUN_SPEED:
				animationPlayer.play("Sprint", -1, 3, false)
			else:
				animationPlayer.play("Walk", -1, 1.25, false)
		else:
			animationPlayer.play("Idle")
		$SpinArea/CollisionShape3D.call_deferred("set_disabled", true)
	else:
		if enteringPipe:
			animationPlayer.play("Idle")
		elif spinJump:
			animationPlayer.play("SpinJump", -1, 1.5, false)
			jumping = true
			spinJump = false
		elif not jumping:
			animationPlayer.play("Jump", -1, 1.75, false)
			jumping = true
			
func CheckInvincible():
	if animationPlayer2.is_playing():
		invincible = true
	else:
		invincible = false
		
func SetSpawn():
	respawnPoint.x = position.x
	respawnPoint.z = position.z - 2
	originalCameraPos = Vector3($CameraBasis.global_position.x, $CameraBasis.global_position.y, $CameraBasis.global_position.z - 2)
	gotCheckpoint = true
		
func CheckFallen():
	if position.y < respawnPoint.y - 15 and not fallen:
		if gotCheckpoint:
			music.stop()
			fallen = true
			canvasAnimationPlayer.call_deferred("play", "fadeout")
		else:
			Die()
	elif fallen:
		if not canvasAnimationPlayer.is_playing():
			Respawn()

func Respawn():
	AudioServer.set_bus_effect_enabled(1, 0, false)
	get_parent().get_node("WorldEnvironment").call_deferred("set_environment", overworldEnvironment)
	music.play()
	ChangeSize(SIZE_SMALL)
	canvasAnimationPlayer.call_deferred("play", "fadein")
	position = respawnPoint
	$CameraBasis.global_position = originalCameraPos
	$CameraBasis.rotation_degrees.y = -90
	fallen = false
	
func TakeHit():
	if not invincible:
		if currentSize == SIZE_BIG:
			$ShrinkSound.play()
			ChangeSize(SIZE_SMALL)
		else:
			mario.visible = false
			if gotCheckpoint:
				canvasAnimationPlayer.call_deferred("play", "fadeout")
				fallen = true
			else:
				Die()
	
func Die():
	$DeathSound.play()
	$MarioBodyCollision.disabled = true
	$MarioHeadCollision.disabled = true
	$SmallMarioBodyCollision.disabled = true
	$SmallMarioHeadCollision.disabled = true
	headBox.disabled = true
	music.stop()
	canvasAnimationPlayer.call_deferred("play", "fadeout")
	fadeout = true
	
func Win():
	music.stop()
	canvasAnimationPlayer.call_deferred("play", "fadeout")
	fadeout = true
	
func CheckWin():
	if fadeout and not canvasAnimationPlayer.is_playing():
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func EnteredPipeZone(pipeBody, inZone):
	lastPipe = pipeBody
	inPipeZone = inZone

func TeleportToUnderground():
	gravMultiplier = 0.5
	AudioServer.set_bus_effect_enabled(1, 0, true)
	music.stop()
	undergroundMusic.play()
	var newPosition = get_parent().get_node("Underground Spawn").global_position
	position.x = newPosition.x
	position.y = newPosition.y - 4
	position.z = newPosition.z
	$CameraBasis.call_deferred("Teleport")
	get_parent().get_node("WorldEnvironment").call_deferred("set_environment", undergroundEnvironment)
	enteringPipe = false
	get_parent().call_deferred("HideMountains", true)
	
func TeleportToOverground():
	AudioServer.set_bus_effect_enabled(1, 0, false)
	undergroundMusic.stop()
	music.play()
	var newPosition = get_parent().get_node("Overground Spawn").global_position
	position.x = newPosition.x
	position.y = newPosition.y - 4
	position.z = newPosition.z
	$CameraBasis.call_deferred("Teleport")
	velocity = Vector3(0, 22, 33)
	get_parent().get_node("WorldEnvironment").call_deferred("set_environment", overworldEnvironment)
	enteringPipe = false
	get_parent().call_deferred("HideMountains", false)

func Bonk():
	$BonkSound.play()
	velocity.y = 0
	jumpReleased = true
	spinJumpReleased = true

func _on_spin_area_area_entered(area):
	if area.get_parent().is_in_group("BreakableBlocks") or area.name == "SquishArea":
		SpinBounce()

func _on_jump_area_area_entered(area):
	if area.name == "SquishArea":
		Bounce()

func _on_timer_2_timeout():
	var instance = fireBall.instantiate()
	instance.isReversed = true
	add_child(instance)

func _on_timer_timeout():
	animationTree.active = false
	
func _on_timer_3_timeout():
	$SpinArea/CollisionShape3D.call_deferred("set_disabled", false)

func _on_head_area_body_entered(body):
	if body != self and not is_on_floor():
		Bonk()
