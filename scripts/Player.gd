extends CharacterBody3D

const SPEED = 8
const TURN_SPEED = 1
const JUMP_VELOCITY = 8

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jumping = false

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
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		direction = direction.rotated(Vector3.UP, cameraBasis.rotation.y).normalized()
		if velocity.x < direction.x * SPEED:
			velocity.x += TURN_SPEED
			if velocity.x > direction.x * SPEED:
				velocity.x = direction.x * SPEED
		elif velocity.x > direction.x * SPEED:
			velocity.x -= TURN_SPEED
			if velocity.x < direction.x * SPEED:
				velocity.x = direction.x * SPEED
		if velocity.z < direction.z * SPEED:
			velocity.z += TURN_SPEED
			if velocity.z > direction.z * SPEED:
				velocity.z = direction.z * SPEED
		elif velocity.z > direction.z * SPEED:
			velocity.z -= TURN_SPEED
			if velocity.z < direction.z * SPEED:
				velocity.z = direction.z * SPEED
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
