extends Node3D

@export var enemies: Array [PackedScene]
@export var nextWaveTime: float = 2.5 
@export var enmemiesPerWave: int = 4
@export var maxWaves := -1

@onready var timer: Timer = $Timer

var currentWave = 0 
var randomGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	timer.wait_time = nextWaveTime
	timer.start()

func _on_timer_timeout() -> void:
	for i in enmemiesPerWave:
		var randomEnmeyNode = enemies.pick_random().instantiate()
		get_tree().current_scene.add_child(randomEnmeyNode)
		randomEnmeyNode.global_position = _get_random_point()

	currentWave += 1
	
	if currentWave == maxWaves:
		timer.stop()

func _get_random_point():
	var collisionShape: CollisionObject3D = get_child(-1)
	
	if collisionShape.shape is BoxShape3D:
		var halfSize = collisionShape.shape.size/ 2
		return collisionShape.global_position + _get_random_point_box_shape(halfSize)
	 elif collisionShape.shape is CylinderShape3D:
		var radius = collisionShape.shape.radius
		return collisionShape.global_position + _get_random_point_cylinder_shape(radius)


	func _get_random_point_box_shape(halfSize):

func_get_random_point_cylinder_shape(radius):
	var randomAngle
