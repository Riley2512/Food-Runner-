extends Control

@onready var main_buttons: VBoxContainer = $"Main buttons"
@onready var options: Panel = $Options


func _ready():
	main_buttons.visible = true
	options.visible = false


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://3DLevel.tscn")


func _on_settings_pressed() -> void:
	print("Settings pressed")
	main_buttons.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	_ready()
