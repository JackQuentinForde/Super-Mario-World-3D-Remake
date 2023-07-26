extends CharacterBody3D

var state
var state_factory

func _ready():
	state_factory = StateFactory.new()
	change_state("patrol")

func _physics_process(delta):
	action(delta)
	velocity = state.velocity
	print(velocity)
	move_and_slide()
	
func action(delta):
	state.Move(delta)
	
func change_state(new_state_name):
	if state != null:
		state.queue_free()
	state = state_factory.get_state(new_state_name).new()
	state.Setup(Callable(self, "change_state"), $"../AnimationPlayer", $StartPoint, $EndPoint, self)
	state.name = "current_state"
	add_child(state)
