extends CharacterBody3D

# --- Nodes ---
@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D

# --- Movement ---
const WALK_SPEED    = 10.0
const JUMP_FORCE    = 5.0
const GRAVITY       = 9.8
const ACCEL         = 15.0
const DECEL         = 20.0

# --- Mouse Look ---
const MOUSE_SENSITIVITY = 0.002
var is_looking := false

# --- Camera Modes ---
const FOV_FIRST     = 75.0
const FOV_THIRD     = 65.0

# First person: inside the head
const CAM_FIRST_POS = Vector3(0, 0, 0)
const CAM_FIRST_ROT = Vector3(0, 0, 0)

# Third person: pull back and up behind player
const CAM_THIRD_POS = Vector3(0, 1.5, 4.0)
const CAM_THIRD_ROT = Vector3(-10, 0, 0)  # slight downward angle

var is_third_person := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_apply_camera_mode()

func _unhandled_input(event: InputEvent) -> void:
	# --- Z to toggle first / third person ---
	if event is InputEventKey and event.pressed and event.keycode == KEY_Z:
		is_third_person = !is_third_person
		_apply_camera_mode()

	# --- Right-click to look ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		is_looking = event.pressed
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if is_looking else Input.MOUSE_MODE_VISIBLE
		)

	# --- Mouse look ---
	if event is InputEventMouseMotion and is_looking:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		neck.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	# WASD + Arrows
	var move_x := Input.get_axis("move_left",    "move_right")
	var move_z := Input.get_axis("move_forward", "move_back")

	var forward := Vector3(-transform.basis.z.x, 0, -transform.basis.z.z).normalized()
	var right   := Vector3( transform.basis.x.x, 0,  transform.basis.x.z).normalized()

	var direction := (right * move_x - forward * move_z).normalized()

	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, ACCEL * delta)
		velocity.z = move_toward(velocity.z, direction.z * WALK_SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECEL * delta)
		velocity.z = move_toward(velocity.z, 0.0, DECEL * delta)

	move_and_slide()

func _apply_camera_mode() -> void:
	if is_third_person:
		# Reparent camera to CharacterBody3D so it sits behind the whole body
		if camera.get_parent() == neck:
			neck.remove_child(camera)
			add_child(camera)
		camera.position = CAM_THIRD_POS
		camera.rotation_degrees = CAM_THIRD_ROT
		camera.fov = FOV_THIRD
	else:
		# Reparent camera back into neck for first person
		if camera.get_parent() == self:
			remove_child(camera)
			neck.add_child(camera)
		camera.position = CAM_FIRST_POS
		camera.rotation_degrees = CAM_FIRST_ROT
		camera.fov = FOV_FIRST

func get_camera() -> Camera3D:
	return camera

func get_look_direction() -> Vector3:
	return -camera.global_transform.basis.z

func is_in_third_person() -> bool:
	return is_third_person
