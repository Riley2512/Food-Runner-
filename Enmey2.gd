extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var progress_bar: ProgressBar = $"../EnmeySpawner/CollisionShape3D/CanvasLayer/ProgressBar"
@onready var timer = $"../Timer"

var speed = 3.5
var gravity = 9.8
var is_dead = false

var attack_damage = 10
var target_player: Node3D = null   # set when player enters the Area3D (attack range)

func _ready():
	if progress_bar == null:
		push_error("progress_bar not found! Check the node path: " +
			"../EnmeySpawner/CollisionShape3D/CanvasLayer/ProgressBar")
	if timer == null:
		push_error("timer not found! Check the node path: ../Timer")

	# Find the player and start chasing them
	var player = get_tree().get_first_node_in_group("player")
	if player:
		set_target(player.global_transform.origin)
	else:
		push_error("No node in group 'player' found! Add the Player to the 'player' group.")

func _physics_process(delta):
	if is_dead:
		return

	if progress_bar and progress_bar.value <= 0:
		die()
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -2

	# Keep re-targeting the player every frame so we chase them as they move
	var player = get_tree().get_first_node_in_group("player")
	if player:
		nav.target_position = player.global_transform.origin

	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var direction = next_location - current_location
	direction.y = 0

	if direction.length() > 0.01:
		var new_velocity = direction.normalized() * speed
		velocity.x = move_toward(velocity.x, new_velocity.x, 0.25)
		velocity.z = move_toward(velocity.z, new_velocity.z, 0.25)
	else:
		velocity.x = move_toward(velocity.x, 0, 0.25)
		velocity.z = move_toward(velocity.z, 0, 0.25)

	move_and_slide()

func die():
	if is_dead:
		return
	is_dead = true
	print("dead")
	set_physics_process(false)
	queue_free()

func set_target(target):
	nav.target_position = target

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and timer:
		target_player = body
		timer.start()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and timer:
		target_player = null
		timer.stop()

func _on_timer_timeout():
	if target_player and not is_dead and is_instance_valid(target_player):
		target_player.take_damage(attack_damage)
