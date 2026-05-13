extends CharacterBody3D
@onready var first_person_camera: Camera3D = $FirstPersonCamera
@onready var third_person_camera: Node3D = $ThirdPersonCamera
# Movement settings
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shift"):
		_change_camera()

		
# Get gravity from project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Head/FirstPerson
var is_right_click_held := false

func _ready():
	# Keep mouse visible until right click is held
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction (WASD + Arrow Keys)
	var input_dir := Vector2.ZERO

	# Forward / Back
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1

	# Left / Right
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1

	# Normalize to prevent faster diagonal movement
	input_dir = input_dir.normalized()

	# Move relative to where the player is facing
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		# Smoothly stop
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
func _get_camera_transform():
	if first_person_camera.current:
		return first_person_camera.global_transform.basis
	else:
			return third_person_camera.global_transform.basis
