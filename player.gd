extends CharacterBody3D

@onready var first_person_camera: Camera3D = $FirstPersonCamera
@onready var third_person_camera: Node3D = $ThirdPersonCamera

# Movement settings
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

# Camera rotation tracking
var camera_pitch := 0.0  # Up/down rotation (clamped)

var is_right_click_held := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	# Toggle camera view
	if Input.is_action_just_pressed("shift"):
		_change_camera()

	# Track right mouse button hold
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		is_right_click_held = event.pressed
		if is_right_click_held:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Mouse look — only when right click is held
	if event is InputEventMouseMotion and is_right_click_held:
		# Rotate the whole character left/right (yaw)
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

		# Rotate the active camera up/down (pitch), clamped to avoid flipping
		camera_pitch -= event.relative.y * MOUSE_SENSITIVITY
		camera_pitch = clamp(camera_pitch, deg_to_rad(-80), deg_to_rad(80))

		if first_person_camera.current:
			first_person_camera.rotation.x = camera_pitch
		else:
			third_person_camera.rotation.x = camera_pitch

func _change_camera():
	if first_person_camera.current:
		first_person_camera.current = false
		third_person_camera.get_node("Camera3D").current = true  # adjust path if needed
	else:
		first_person_camera.current = true
		third_person_camera.get_node("Camera3D").current = false

# Get gravity from project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction (WASD + Arrow Keys)
	var input_dir := Vector2.ZERO

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# Move relative to where the player is facing
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _get_camera_transform():
	if first_person_camera.current:
		return first_person_camera.global_transform.basis
	else:
		return third_person_camera.global_transform.basis
