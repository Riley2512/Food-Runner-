extends Control

@onready var main_buttons: VBoxContainer = $"Main buttons"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://3DLevel.tscn")


func _on_settings_pressed() -> void:
	print("Settings pressed")


func _on_exit_pressed() -> void:
	get_tree().quit()
