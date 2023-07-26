extends Node

class_name EnemyState

const SPEED = 5.0

var change_state
var animation_player
var persistent_state
var velocity = 0

func _physics_process(delta):	
	persistent_state.ApplyGravity(delta)

func Setup(change_state, animation_player, persistent_state):
	self.change_state = change_state
	self.animation_player = animation_player
	self.persistent_state = persistent_state

func ApplyGravity(delta):
	pass

func Move():
	pass
