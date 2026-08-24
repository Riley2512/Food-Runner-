extends Node

@export var maxHealth: float = 100.0

var health: float = maxHealth

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func damage(attack: Attack) -> void:
	health -= attack.damage

	var parent: Node3D = get_parent()
	if parent.has_method("on_damage"):
		parent.on_damage(attack)

	if health <= 0:
		get_parent().on_death()
