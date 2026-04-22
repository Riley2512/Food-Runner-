extends CharacterBody3D

# --- Nodes ---
@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D

# --- Movement ---
const WALK_SPEED  = 5.0
const JUMP_FORCE  = 5.0
const GRAVITY     = 9.8

# --- Mouse Look ---
const MOUSE_SENSITIVITY = 0.002
var is_looking := false

# --- Camera Zoom ---
const ZOOM_MIN    = 0.0   # First person
const ZOOM_MAX    = 6.0   # Max third person distance
const ZOOM_STEP   = 0.5
var zoom_distance := 0.0


func _ready() -> void:
	_apply_zoom()


func _unhandled_input(event: InputEvent) -> void:
	# Right-click to look
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		is_looking = event.pressed
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if is_looking else Input.MOUSE_MODE_VISIBLE
		)

	# Mouse look
	if event is InputEventMouseMotion and is_looking:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		neck.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	# Scroll wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_distance = clamp(zoom_distance + ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
			_apply_zoom()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_distance = clamp(zoom_distance - ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
			_apply_zoom()


func _apply_zoom() -> void:
	# Slide camera back along local Z
	camera.position.z = zoom_distance

	# Hide body mesh in first person, show in third person
	var mesh := get_node_or_null("MeshInstance3D")
	if mesh:
		mesh.visible = zoom_distance > 0.2


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	# WASD
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_back")
	)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = direction.x * WALK_SPEED
	velocity.z = direction.z * WALK_SPEED

	move_and_slide()


# --- Hooks for other systems ---
func get_camera() -> Camera3D:
	return camera

func get_look_direction() -> Vector3:
	return -camera.global_transform.basis.z

func is_first_person() -> bool:
	return zoom_distance <= 0.2
	velocity.z = direction.z * WALK_SPEED

	move_and_slide()


# --- Switch camera position & FOV ---
func _apply_camera_mode() -> void:
	if is_third_person:
		camera.position = CAM_THIRD_POS
		camera.fov = FOV_THIRD
	else:
		camera.position = CAM_FIRST_POS
		camera.fov = FOV_FIRST


# --- Hooks for other systems ---
func get_camera() -> Camera3D:
	return camera

func get_look_direction() -> Vector3:
	return -camera.global_transform.basis.z

func is_in_third_person() -> bool:
	return is_third_person
