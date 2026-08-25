extends Node

class_name HealthComponent
@export var maxHealth: float = 100.0

signal died

var health: float = maxHealth

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func damage(attack: Attack) -> void:
	health -= attack.damage

	if health <= 0:
		died.emit()
		var parent := get_parent()
		if parent.has_method("on_death"):
			parent.on_death()

func take_damage(amount: float) -> void:
	damage(Attack.new(amount, null))

func heal(amount: float) -> void:
	health = min(health + amount, maxHealth)
