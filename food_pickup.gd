extends Area3D

@export var heal_amount: float = 25.0

var collected := false
signal picked_up

func _on_body_entered(body: Node3D) -> void:
	if collected or not (body.is_in_group("player") or body.is_in_group("Player")):
		return

	var health_component := body.get_node_or_null("HealthCompoment") as HealthComponent
	if health_component == null:
		return

	collected = true
	if health_component.health < health_component.maxHealth:
		health_component.heal(heal_amount)
	picked_up.emit()
	queue_free()
