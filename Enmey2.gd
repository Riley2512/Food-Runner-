extends CharacterBody3D

var detect = false
@onready var nav = $NavigationAgent3D
var speed = 3.5
var gravity = 9.8
var is_dead = false

## HEALTH BAR --
@onready var progress_bar: ProgressBar = $"../EnmeySpawner/CollisionShape3D/CanvasLayer/ProgressBar"
@onready var timer = $"../Timer"

func _physics_process(delta):
	if is_dead:
		return

	if progress_bar.value <= 0:
		die()
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -2

	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin

	# Only steer on the horizontal plane so we don't fight gravity
	# or normalize() a (near) zero vector.
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
	if body.is_in_group("player"):
		timer.start()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		timer.stop()

func _on_timer_timeout():
	progress_bar.value -= 10
