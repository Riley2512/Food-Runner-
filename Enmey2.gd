extends CharacterBody3D

@onready var nav
var speed = 3.5 
var gravity = 9.8
func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y -=2
		var next_location = nav.get_next_path_postiton()
		var current_location = global_transform.origin
		var new_velocity = (new_loaction - current_location).normlized()* speed
