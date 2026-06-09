extends CharacterBody3D

@onready var MoveSpeed:float = 4.0
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var player: CharacterBody3D = null

func _ready() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	else:
		push_error("no node found in group  'player'")
func _physics_process(delta : float) -> void:
	if player == null:
		return

	navigation_agent.set_target_position(player.global_position)
	
	if navigation_agent.is_navigation_finished():
		return
	var next_position: Vector3 = navigation_agent.get_next_path_position()
	velocity = (next_position - global_position).normalized() * MoveSpeed
	move_and_slide()
