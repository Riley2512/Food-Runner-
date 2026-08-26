extends Node3D

@export var enemies: Array[PackedScene]
@export var nextWaveTime: float = 2.5
@export var enmemiesPerWave: int = 4
@export var maxWaves := -1
@export var spawn_area_size := Vector2(18, 18)
@onready var timer: Timer = $Timer

var currentWave = 0
var randomGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	randomGenerator.randomize()
	timer.wait_time = nextWaveTime
	timer.start()


func _on_timer_timeout() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	for i in enmemiesPerWave:
		var randomEnmeyNode = enemies.pick_random().instantiate()
		get_tree().current_scene.add_child(randomEnmeyNode)
		if player:
			randomEnmeyNode.scale = player.scale
		randomEnmeyNode.global_position = _get_random_point()
	currentWave += 1

	if currentWave == maxWaves:
		timer.stop()


func _get_random_point():
	var player := get_tree().get_first_node_in_group("player") as Node3D
	var center := global_position
	if player != null:
		center = player.global_position
	return center + Vector3(
		randomGenerator.randf_range(-spawn_area_size.x / 2.0, spawn_area_size.x / 2.0),
		0,
		randomGenerator.randf_range(-spawn_area_size.y / 2.0, spawn_area_size.y / 2.0)
	)


func _get_random_point_box_shape(halfSize):
	var x = randomGenerator.randf_range(-halfSize.x, halfSize.x)
	var y = randomGenerator.randf_range(-halfSize.y, halfSize.y)
	var z = randomGenerator.randf_range(-halfSize.z, halfSize.z)
	return Vector3(x, y, z)


func _get_random_point_cylinder_shape(radius):
	var randomAngle1 = randomGenerator.randf_range(0, 2 * PI)
	var randomAngle2 = randomGenerator.randf_range(0, 2 * PI)
	var randomLength = radius * sqrt(randomGenerator.randf())
	var direction = Vector3.RIGHT.rotated(Vector3.UP, randomAngle1)
	direction = direction.rotated(Vector3.RIGHT, randomAngle2)

	return direction * randomLength


func _get_random_point_sphere_shape(radius):
	var randomDirection = Vector3(
		randomGenerator.randf_range(-1, 1),
		randomGenerator.randf_range(-1, 1),
		randomGenerator.randf_range(-1, 1)
	).normalized()
	var randomLength = radius * pow(randomGenerator.randf(), 1.0 / 3.0)

	return randomDirection * randomLength
