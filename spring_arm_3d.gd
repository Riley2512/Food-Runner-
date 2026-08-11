extends SpringArm3D

@export var mouse_sensibilty: float = 0.005
@export_range(-90.0, 0.0, 0.1 "radians_as_degress") var min vertical_angle float = -PI/2
@export_range(-90.0, 0.0, 0.1 "radians_as_degress") var max vertical_angle float = -PI/4


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensibilty
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		
		rotation.x -= event.relative.y * mouse_sensibilty
		rotation.x = clamp(rotation.x, -PI/2, PI/4)
