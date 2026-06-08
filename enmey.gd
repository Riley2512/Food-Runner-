extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

var SPEED = 3.0

func _physics_process(delta):
	var current_loacation = global_transform.origin
	var next_loacation = nav_agent.get_next_path_position()
	var new_velocity = (next_loacation - current_loacation).normalized() * SPEED

	velocity = new_velocity
	move_and_slide()

func update_target_location(target_loactaion):
	nav_agent.set_target_position(target_loactaion)
