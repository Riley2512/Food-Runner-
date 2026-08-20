extends Node3D

@export var mouse_sensibilty: float = 0.005
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle: float = -PI/2
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var max_vertical_angle: float = PI/4

@onready var spring_arm := $SpringArm3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensibilty
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		
		rotation.z -= event.relative.y * mouse_sensibilty
		rotation.z = clamp(rotation.z, min_vertical_angle, max_vertical_angle)
		
	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event.is_action_pressed("wheel_up"):
		$SpringArm3D.spring_length -= 1
	if event.is_action_pressed("wheel_down"):
		$SpringArm3D.spring_length += 1
		
func _process(_delta : float) -> void:
	global_position = $ "..".global_position
	
