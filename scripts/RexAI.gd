extends CharacterBody3D

var state
var state_factory

func _ready():
	state_factory = StateFactory.new()
	change_state("patrol")

func _physics_process(_delta):
	move()
	move_and_slide()
	
func move():
	state.move()
	
func change_state(new_state_name):
	if state != null:
		state.queue_free()
	state = state_factory.get_state(new_state_name).new()
	state.setup(Callable(self, "change_state"), $"../AnimationPlayer", self)
	state.name = "current_state"
	add_child(state)
