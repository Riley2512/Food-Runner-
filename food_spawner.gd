extends Node3D

@export var burger_scene: PackedScene
@export var meat_scene: PackedScene
@export var food_count: int = 6
@export var spawn_area_center := Vector3(0, 0.5, 0)
@export var spawn_area_size := Vector2(18, 18)

var random_generator := RandomNumberGenerator.new()

func _ready() -> void:
	random_generator.randomize()
	await get_tree().physics_frame
	var enemy := get_tree().get_first_node_in_group("Enemies") as Node3D
	if enemy != null:
		spawn_area_center = enemy.global_position
		spawn_area_center.y += 0.5
	else:
		var player := get_tree().get_first_node_in_group("player") as Node3D
		if player != null:
			spawn_area_center = player.global_position
			spawn_area_center.y += 0.5
	for index in food_count:
		_spawn_food(index % 2 == 0)

func _spawn_food(spawn_burger: bool) -> void:
	var scene := burger_scene if spawn_burger else meat_scene
	if scene == null:
		return

	var food := scene.instantiate()
	add_child(food)
	food.global_position = _random_spawn_position()
	food.picked_up.connect(_on_food_collected.bind(spawn_burger), CONNECT_ONE_SHOT)

func _random_spawn_position() -> Vector3:
	return spawn_area_center + Vector3(
		random_generator.randf_range(-spawn_area_size.x / 2.0, spawn_area_size.x / 2.0),
		0,
		random_generator.randf_range(-spawn_area_size.y / 2.0, spawn_area_size.y / 2.0)
	)

func _on_food_collected(spawn_burger: bool) -> void:
	_spawn_food(spawn_burger)
