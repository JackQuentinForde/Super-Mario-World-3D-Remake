extends CharacterBody3D

const SPEED = 18
const BOUNCE_VELOCITY = 6

var gravity = 40
var destroyed = false

func _ready():
	var parent = get_parent()
	var parentPos = parent.global_position
	global_position = Vector3(parentPos.x, parentPos.y + 5, parentPos.z)
	velocity = parent.target_velocity.normalized() * SPEED
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
	$FireArea/CollisionShape3D.disabled = true
	destroyed = true

func _on_fire_area_body_exited(body):
	if body.name == "Player":
		$CollisionShape3D.call_deferred("set_disabled", false)
