extends CharacterBody3D

const SPEED = 7.5
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# variables that are set in the ready function
var springArm
var mario

func _ready():
	springArm = $SpringArm3D
	mario = $Mario

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		direction = direction.rotated(Vector3.UP, springArm.rotation.y).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if velocity.x != 0 or velocity.z != 0:
		mario.get_node("AnimationPlayer").play("Walk")
	else:
		mario.get_node("AnimationPlayer").play("Idle")
	
	if velocity.length() > 0.2:
		var lookDirection = Vector2(velocity.z, velocity.x)
		mario.rotation.y = lookDirection.angle()
	
func _process(delta):
	springArm.position = position
