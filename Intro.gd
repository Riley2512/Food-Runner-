extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():

	$AnimationPlayer.play("Fade In")
	await get_tree().create_timer(6).timeout
	get_tree().change_scene_to_file("res://main menu.tscn")
