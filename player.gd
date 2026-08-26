extends CharacterBody3D

@onready var health_compoment: HealthComponent = $HealthCompoment
@onready var health_lbl: Label = $HealthLbl
@onready var health_bar: ProgressBar = get_tree().current_scene.get_node_or_null("CanvasLayer/Healthbar")
@onready var camera_pivot: Node3D = $SpringArmPivort

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const RESPAWN_DELAY := 2.0

var is_dead = false
var spawn_position := Vector3.ZERO
signal died

func _ready() -> void:
	spawn_position = global_position
	health_compoment.health = health_compoment.maxHealth
	health_compoment.died.connect(die)
	_update_health_display()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var camera_forward := -camera_pivot.global_transform.basis.z
	camera_forward.y = 0
	camera_forward = camera_forward.normalized()
	var camera_right := camera_pivot.global_transform.basis.x
	camera_right.y = 0
	camera_right = camera_right.normalized()
	var direction := (camera_right * input_dir.x - camera_forward * input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	_update_health_display()
	move_and_slide()

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health_compoment.take_damage(amount)
	_update_health_display()

func _update_health_display() -> void:
	if health_lbl:
		health_lbl.text = str(snapped(health_compoment.health, 1))
	if health_bar:
		health_bar.value = health_compoment.health

func on_damage(attack: Attack) -> void:
	if is_dead:
		return
	health_compoment.damage(attack)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()
	_respawn_after_delay()

func _respawn_after_delay() -> void:
	await get_tree().create_timer(RESPAWN_DELAY).timeout
	if not is_inside_tree():
		return
	health_compoment.health = health_compoment.maxHealth
	global_position = spawn_position
	velocity = Vector3.ZERO
	is_dead = false
	_update_health_display()

func on_death() -> void:
	return
