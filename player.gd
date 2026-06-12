extends CharacterBody3D

@onready var camera: Camera3D = $FirstPersonCamera

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

var camera_pitch := 0.0
var is_right_click_held := false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		is_right_click_held = event.pressed
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if is_right_click_held else Input.MOUSE_MODE_VISIBLE
		)
	if event is InputEventMouseMotion and is_right_click_held:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pitch = clamp(
			camera_pitch - event.relative.y * MOUSE_SENSITIVITY,
			deg_to_rad(-80), deg_to_rad(80)
		)

func _physics_process(delta: float) -> void:
	# Apply camera pitch every frame

	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 60)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 60)
	move_and_slide()
