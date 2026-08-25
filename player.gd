extends CharacterBody3D

@onready var health_compoment: HealthComponent = $HealthCompoment
@onready var health_lbl: Label = $HealthLbl  # <- update path/name to match your scene

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var is_dead = false
signal died

func _ready() -> void:
	health_compoment.health = health_compoment.maxHealth
	health_compoment.died.connect(die)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if health_lbl:
		health_lbl.text = str(health_compoment.health)
	move_and_slide()

func on_damage(attack: Attack) -> void:
	if is_dead:
		return
	health_compoment.damage(attack)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	print("player dead")
	died.emit()
	# add respawn / game over logic here

func on_death() -> void:
	get_tree().quit()
