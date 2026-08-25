extends Node3D

var player_scene = preload("res://player.tscn")
var player = null

func _process(_delta):
	if player == null:
		var existing_players := get_tree().get_nodes_in_group("player")
		if not existing_players.is_empty():
			player = existing_players[0]
			return
		var new_obj = player_scene.instantiate()
		new_obj.position = position 
		get_parent().add_child(new_obj)
		player = new_obj
