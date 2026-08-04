extends CharacterBody3D

@export var move_speed: float = 4.0
@export var attack_range: float = 1.5
@export var attack_cooldown: float = 1.0
@export var attack_damage: int = 10
@export var gravity: float = 9.8

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var player: CharacterBody3D = null
var attack_timer: float = 0.0

func _ready() -> void:
	# Wait a couple frames so the nav map is ready, not just one frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	var players = get_tree().get_nodes_in_group("player")  # match case used below
	if players.size() > 0:
		player = players[0]
	else:
		push_error("No node found in group 'player'")


func _physics_process(delta: float) -> void:
	if player == null:
		return

	# Apply gravity so the enemy doesn't float
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var distance_to_player: float = global_position.distance_to(player.global_position)

	if distance_to_player <= attack_range:
		# Close enough — stop moving and attack
		velocity.x = 0
		velocity.y = velocity.y # keep gravity
		velocity.z = 0
		_try_attack(delta)
	else:
		navigation_agent.target_position = player.global_position

		if not navigation_agent.is_navigation_finished():
			var next_position: Vector3 = navigation_agent.get_next_path_position()
			var direction: Vector3 = (next_position - global_position)
			direction.y = 0
			direction = direction.normalized()

			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed

			# Face the direction of movement
			if direction.length() > 0.01:
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
	else:
		print("Enemy attacked player!")
