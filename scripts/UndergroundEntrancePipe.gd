extends Node3D

var player

func DisableCollisions():
	$"@Pipe001@24189/CollisionShape3D".call_deferred("set_disabled", true)
	$Timer.start()

func _on_timer_timeout():
	player.call_deferred("TeleportToUnderground")
	$"@Pipe001@24189/CollisionShape3D".call_deferred("set_disabled", false)

func _on_trigger_body_entered(body):
	if body.name == "Player":
		player = body
		player.call_deferred("EnteredPipeZone", self, true)

func _on_trigger_body_exited(body):
	if body.name == "Player":
		player = body
		player.call_deferred("EnteredPipeZone", self, false)
