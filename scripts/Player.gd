extends CharacterBody3D

const WALK_SPEED = 8
const RUN_SPEED = 12
const TURN_SPEED = 1
const AIR_TURN_SPEED = 0.2
const ACCEL = 0.2
const JUMP_ACCEL = 1
const JUMP_MIN_VELOCITY = 3
const JUMP_MAX_VELOCITY = 9
const ANIMATION_RUN_SPEED = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jumping = false
var jumpReleased = true
var speed
var turnSpeed

# variables that are set in the ready function
var cameraBasis
var mario
var animationPlayer

func _ready():
	cameraBasis = $CameraBasis
	mario = $Mario
	animationPlayer = $Mario/AnimationPlayer
	cameraBasis.rotation_degrees.y = -90
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _physics_process(delta):
	JumpLogic()
	
	# apply gravity
	velocity.y -= gravity * delta
	
	if not is_on_floor():
		speed = WALK_SPEED
		turnSpeed = AIR_TURN_SPEED
	else:
		turnSpeed = TURN_SPEED
		if Input.is_action_pressed("player_sprint"):
			if speed < RUN_SPEED:
				speed += ACCEL
				if speed > RUN_SPEED:
					speed = RUN_SPEED
			animationPlayer.speed_scale = ANIMATION_RUN_SPEED
		else:
			if speed > WALK_SPEED:
				speed -= ACCEL
				if speed < WALK_SPEED:
					speed = WALK_SPEED
			elif speed < WALK_SPEED:
				speed += ACCEL
				if speed > WALK_SPEED:
					speed = WALK_SPEED
			animationPlayer.speed_scale = 1
			
	# Handle Jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_MIN_VELOCITY
		$AudioStreamPlayer.play()
		jumpReleased = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		direction = direction.rotated(Vector3.UP, cameraBasis.rotation.y).normalized()
		if velocity.x < direction.x * speed:
			velocity.x += turnSpeed
			if velocity.x > direction.x * speed:
				velocity.x = direction.x * speed
		elif velocity.x > direction.x * speed:
			velocity.x -= turnSpeed
			if velocity.x < direction.x * speed:
				velocity.x = direction.x * speed
		if velocity.z < direction.z * speed:
			velocity.z += turnSpeed
			if velocity.z > direction.z * speed:
				velocity.z = direction.z * speed
		elif velocity.z > direction.z * speed:
			velocity.z -= turnSpeed
			if velocity.z < direction.z * speed:
				velocity.z = direction.z * speed
		
		var lookDirection = Vector2(velocity.z, velocity.x)
		mario.rotation.y = lookDirection.angle()
	else:
		velocity.x = move_toward(velocity.x, 0, turnSpeed)
		velocity.z = move_toward(velocity.z, 0, turnSpeed)

	move_and_slide()
	
	if is_on_floor():
		jumping = false
		if velocity.x != 0 or velocity.z != 0:
			animationPlayer.play("Walk")
		else:
			animationPlayer.play("Idle")
	else:
		if !jumping:
			animationPlayer.play("Jump")
		jumping = true
		
func JumpLogic():
	if Input.is_action_pressed("player_jump") and !jumpReleased:
		if velocity.y < JUMP_MAX_VELOCITY:
			velocity.y += JUMP_ACCEL
			if velocity.y >= JUMP_MAX_VELOCITY:
				velocity.y = JUMP_MAX_VELOCITY
				jumpReleased = true
		else:
			jumpReleased = true
	else:
		jumpReleased = true
