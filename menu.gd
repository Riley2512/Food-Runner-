extends Node3D
@onready var camera_pivot = $CameraPivot

var rotation_speed = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera_pivot.rotation_degrees.y += delta * rotation_speed
