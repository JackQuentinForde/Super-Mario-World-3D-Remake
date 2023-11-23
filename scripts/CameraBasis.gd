extends Node3D

const FOLLOW_SPEED = 3.0
const ROT_SPEED = 1.25
const Y_OFFSET = 9.0

var player
var minY

func _ready():
	player = get_parent()
	minY = global_position.y

func _physics_process(delta):
	RotateLogic(delta)
	var playerPos = player.global_transform.origin
	var targetPos = Vector3(playerPos.x, playerPos.y, playerPos.z)
	targetPos.y += Y_OFFSET
	if targetPos.y <= minY:
		targetPos.y = minY
	
	global_transform.origin = global_transform.origin.lerp(targetPos, FOLLOW_SPEED * delta)
	
func RotateLogic(delta):
	if Input.is_action_pressed("camera_left"):
		rotate_y(ROT_SPEED * delta)
	elif Input.is_action_pressed("camera_right"):
		rotate_y(-ROT_SPEED * delta)

	if Input.is_action_pressed("camera_center"):
		rotation_degrees.y = -90		

func Teleport():
	var playerPos = player.global_transform.origin
	var targetPos = Vector3(playerPos.x, playerPos.y, playerPos.z)
	targetPos.y += Y_OFFSET
	global_transform.origin = targetPos
