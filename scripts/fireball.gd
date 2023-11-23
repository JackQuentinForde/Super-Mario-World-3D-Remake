extends CharacterBody3D

const SPEED = 21
const BOUNCE_VELOCITY = 7

var gravity = 40
var destroyed = false
var isReversed = false

func _ready():
	$CollisionShape3D.disabled = false
	var parent = get_parent()
	var parentPos = parent.global_position
	global_position = Vector3(parentPos.x, parentPos.y + 5, parentPos.z)
	var speed = SPEED
	if isReversed:
		speed = -SPEED
	velocity = parent.target_velocity.normalized() * speed
	$Timer.start()
	
func _physics_process(delta):
	if not destroyed:
		ApplyGravity(delta)
		if is_on_floor():
			Bounce()
		if is_on_wall():
			Destroy()
		move_and_slide()
	elif $GPUParticles3D.emitting == false:
		queue_free()
	
func ApplyGravity(delta):
	velocity.y -= gravity * delta
	
func Bounce():
	velocity.y = BOUNCE_VELOCITY
	
func _on_timer_timeout():
	Destroy()
	
func Destroy():
	$GPUParticles3D.emitting = true
	$Fireball2.visible = false
	$CollisionShape3D.disabled = true
	destroyed = true
