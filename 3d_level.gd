extends Node3D

@onready var player = $Player
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var game_over: Control = $CanvasLayer/GameOver
@onready var settings_menu: Control = $CanvasLayer/SettingsMenu
@onready var final_time_label: Label = $CanvasLayer/GameOver/Panel/VBoxContainer/FinalTime

var elapsed_time := 0.0
var run_finished := false


func _ready() -> void:
	player.died.connect(_on_player_died)
	game_over.visible = false
	settings_menu.visible = false

func _process(delta: float) -> void:
	if run_finished:
		return
	elapsed_time += delta
	timer_label.text = "TIME  %s" % _format_time(elapsed_time)

func _on_player_died() -> void:
	run_finished = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	final_time_label.text = "FINAL TIME  %s" % _format_time(elapsed_time)
	game_over.visible = true
	game_over.get_node("Panel/VBoxContainer/PlayAgain").grab_focus()

func _format_time(seconds: float) -> String:
	var total_seconds := int(seconds)
	return "%02d:%02d" % [total_seconds / 60, total_seconds % 60]

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_settings_pressed() -> void:
	game_over.visible = false
	settings_menu.visible = true
	settings_menu.get_node("Panel/VBoxContainer/Back").grab_focus()

func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	pass # Replace with function body.
