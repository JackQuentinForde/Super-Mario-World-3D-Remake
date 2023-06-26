extends StaticBody3D

func _ready():
	$BreakableBlock.visible = true

func Break():
	$CollisionShape3D.disabled = true
	$AnimationPlayer.play("break")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "break":
		queue_free()
