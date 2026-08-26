extends Area3D

var collected := false

func _on_body_entered(body: Node3D) -> void:
	if collected or not body.is_in_group("player"):
		return
	if not body.has_method("pick_up_knife"):
		return
	collected = true
	body.pick_up_knife()
	queue_free()
