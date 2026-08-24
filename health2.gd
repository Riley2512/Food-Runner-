extends Area3D
@onready var health_bar: ProgressBar = $/root/Main/CanvasLayer/Healthbar



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("playable") and body.heal < 100:
		body.health = min(body.health + 5, 100)
		health_bar.text = "Health: " + str(snapped(body.health, 1))
		queue_free()
