extends SpringArm3D

@export var mouse_sensibilty: float = 0.005
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle: float = -PI/2
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var max_vertical_angle: float = -PI/4


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("wheel_up"):
		spring_length -= 1
	if event.is_action_pressed("wheel_down"):
		spring_length += 1
