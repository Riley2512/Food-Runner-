extends Control

@onready var volume_slider: HSlider = $Panel/VBoxContainer/VolumeSlider
@onready var fullscreen_check: CheckButton = $Panel/VBoxContainer/FullscreenCheck

func _ready() -> void:
	volume_slider.value = AudioServer.get_bus_volume_db(0)
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
	AudioServer.set_bus_mute(0, value <= volume_slider.min_value)

func _on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_pressed() -> void:
	visible = false
	var owner := get_parent()
	var game_over := owner.get_node_or_null("GameOver")
	if game_over:
		game_over.visible = true
		game_over.get_node("Panel/VBoxContainer/PlayAgain").grab_focus()
		return
	var pause_menu := owner.get_node_or_null("PanelContainer")
	if pause_menu:
		pause_menu.visible = true
		owner._open = true
		get_tree().paused = true
		pause_menu.get_node("VBoxContainer/Resume").grab_focus()
		return
	var main_buttons := owner.get_node_or_null("Main buttons")
	if main_buttons:
		main_buttons.visible = true
		main_buttons.get_node("Button2").grab_focus()
