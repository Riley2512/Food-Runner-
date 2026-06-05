extends CharacterBody3D

## Enemy that chases the player and kills on touch.
## Attach to a CharacterBody3D node.
## Requires: NavigationAgent3D child node named "NavigationAgent3D"

@export var speed: float = 3.5
@export var gravity: float = 9.8

var player: Node3D = null
var nav_agent: NavigationAgent3D

func _ready() -> void:
	nav_agent = $NavigationAgent3D
	# Find the player by group — make sure your player is in the "player" group
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if player == null:
		return

	# Update navigation target
	nav_agent.target_position = player.global_position

	# Move toward next path point
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - global_position).normalized()
	direction.y = 0  # keep horizontal

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func _on_body_entered(body: Node3D) -> void:
	# Called when something enters the enemy's Area3D hitbox
	if body.is_in_group("player"):
		body.die()
