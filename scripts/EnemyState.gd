extends Node

class_name EnemyState

const SPEED = 5.0

var change_state
var animation_player
var start_point
var end_point
var mid_point
var persistent_state
var velocity = Vector3(0,0,0)

func _physics_process(delta):	
	persistent_state.state.ApplyGravity(delta)

func Setup(_change_state, _animation_player, _start_point, _end_point, _persistent_state):
	self.change_state = _change_state
	self.animation_player = _animation_player
	self.start_point = _start_point
	self.end_point = _end_point
	self.mid_point = _start_point.transform.interpolate_with(end_point.transform, 0.5);
	self.persistent_state = _persistent_state

func ApplyGravity(_delta):
	pass

func Move(_delta):
	pass
