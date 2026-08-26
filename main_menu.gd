extends Control

@onready var main_buttons: VBoxContainer = $"Main buttons"
@onready var options: Panel = $Options
@onready var settings_menu: Control = $SettingsMenu


func _ready():
	main_buttons.visible = true
	options.visible = false
	settings_menu.visible = false


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://MY Game.tscn")


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	settings_menu.visible = true
	settings_menu.get_node("Panel/VBoxContainer/Back").grab_focus()

func _on_settings_2_pressed() -> void:
	_on_settings_pressed()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	_ready()
