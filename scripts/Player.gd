extends CharacterBody3D

const WALK_SPEED = 8
const RUN_SPEED = 12
const TURN_SPEED = 1
const JUMP_ACCEL = 1
const JUMP_MAX_VELOCITY = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jumping = false
var jumpReleased = true
var speed

# variables that are set in the ready function
var cameraBasis
var mario
var animationPlayer

func _ready():
	cameraBasis = $CameraBasis
	mario = $Mario
	animationPlayer = $Mario/AnimationPlayer
	cameraBasis.rotation_degrees.y = -90

func _physics_process(delta):
	JumpLogic()
	
	if not is_on_floor():
		speed = WALK_SPEED
		# apply gravity
		velocity.y -= gravity * delta
	else:
		if Input.is_action_pressed("player_sprint"):
			speed = RUN_SPEED
		else:
			speed = WALK_SPEED
			
	# Handle Jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_MAX_VELOCITY / 2
		jumpReleased = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		direction = direction.rotated(Vector3.UP, cameraBasis.rotation.y).normalized()
		if velocity.x < direction.x * speed:
			velocity.x += TURN_SPEED
			if velocity.x > direction.x * speed:
				velocity.x = direction.x * speed
		elif velocity.x > direction.x * speed:
			velocity.x -= TURN_SPEED
			if velocity.x < direction.x * speed:
				velocity.x = direction.x * speed
		if velocity.z < direction.z * speed:
			velocity.z += TURN_SPEED
			if velocity.z > direction.z * speed:
				velocity.z = direction.z * speed
		elif velocity.z > direction.z * speed:
			velocity.z -= TURN_SPEED
			if velocity.z < direction.z * speed:
				velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, TURN_SPEED)
		velocity.z = move_toward(velocity.z, 0, TURN_SPEED)

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
	
	if velocity.length() > 0.2:
		var lookDirection = Vector2(velocity.z, velocity.x)
		mario.rotation.y = lookDirection.angle()
		
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
