extends CanvasLayer

const REVEAL_SPEED = 3

func _ready():
	scale = Vector2(0.5, 0)

func _process(delta):
	if scale.y < 0.5:
		scale.y += delta * REVEAL_SPEED
	else:
		scale = Vector2(0.5, 0.5)
	
	var windowSize = get_viewport().get_visible_rect().size
	offset = Vector2(windowSize.x / 4, windowSize.y / 4)
	
	if Input.is_action_just_pressed("player_jump"):
		visible = false
		get_tree().paused = false
		scale = Vector2(0.5, 0)
