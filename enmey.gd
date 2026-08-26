extends CharacterBody3D

@export var move_speed: float = 4.0
@export var attack_range: float = 2.5
@export var attack_cooldown: float = 0.5
@export var attack_damage: int = 10
@export var gravity: float = 9.8

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health_component: HealthComponent = get_node_or_null("HealthCompoment")
@onready var health_label: Label3D = get_node_or_null("HealthBar")

var player: CharacterBody3D = null
var attack_timer: float = 0.0
var is_dead := false

func _ready() -> void:
	if health_component:
		health_component.died.connect(on_death)
		_update_health_bar()
	# Wait a couple frames so the nav map is ready, not just one frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	var players = get_tree().get_nodes_in_group("player")  # match case used below
	if players.size() > 0:
		player = players[0]
	else:
		push_error("No node found in group 'player'")


func _physics_process(delta: float) -> void:
	if is_dead or player == null or not is_instance_valid(player):
		return

	# Apply gravity so the enemy doesn't float
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var horizontal_distance := Vector2(
		global_position.x - player.global_position.x,
		global_position.z - player.global_position.z
	).length()
	var vertical_distance := absf(global_position.y - player.global_position.y)

	if horizontal_distance <= attack_range and vertical_distance <= 3.0:
		# Close enough — stop moving and attack
		velocity.x = 0
		velocity.y = velocity.y # keep gravity
		velocity.z = 0
		_try_attack(delta)
	else:
		var direction: Vector3 = player.global_position - global_position
		direction.y = 0
		if direction.length() > 0.01:
			direction = direction.normalized()
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			look_at(global_position + direction, Vector3.UP)

	move_and_slide()


func _try_attack(delta: float) -> void:
	attack_timer -= delta
	if attack_timer <= 0.0:
		attack_timer = attack_cooldown
		_do_attack()


func _do_attack() -> void:
	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
		return

	var health_component := player.get_node_or_null("HealthCompoment") as HealthComponent
	if health_component != null:
		health_component.take_damage(attack_damage)

func take_damage(amount: float, attacker: Node3D = null) -> void:
	if is_dead or health_component == null:
		return
	health_component.damage(Attack.new(amount, attacker))
	_update_health_bar()
	if health_component.health <= 0:
		on_death()

func _update_health_bar() -> void:
	if health_label == null or health_component == null:
		return
	var filled: int = clampi(ceili(health_component.health / health_component.maxHealth * 10.0), 0, 10)
	health_label.text = "%d / %d\n[%s%s]" % [int(health_component.health), int(health_component.maxHealth), "|".repeat(filled), ".".repeat(10 - filled)]

func on_death() -> void:
	if is_dead:
		return
	is_dead = true
	set_physics_process(false)
	queue_free()
