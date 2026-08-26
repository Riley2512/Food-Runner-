extends Control

const CLOSED_OFFSET := Vector2(-500, 0)
const SLIDE_TIME := 0.4
const STAGGER := 0.06

@onready var panel_container: PanelContainer = $PanelContainer
@onready var v_box_container: VBoxContainer = $PanelContainer/VBoxContainer

var _buttons: Array[AnimatedButton] = []
var _tween: Tween = null
var _open := false


func _ready() -> void:
	get_tree().paused = false
	for child in v_box_container.get_children():
		if child is AnimatedButton: 
			_buttons.append(child)
	_restart()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"Escape"):
		_toggle(not _open)
		get_viewport().set_input_as_handled()
		return

	if _open and event.is_action_pressed(&"ui_down"):
		_move_focus(1)
		get_viewport().set_input_as_handled()
	elif _open and event.is_action_pressed(&"ui_up"):
		_move_focus(-1)
		get_viewport().set_input_as_handled()



func _toggle(should_open: bool) -> void:
	_open = should_open
	panel_container.visible = should_open
	get_tree().paused = should_open
	panel_container.modulate = Color.WHITE if should_open else Color.TRANSPARENT
	for button in _buttons:
		button.offset_transform_position = Vector2.ZERO if should_open else CLOSED_OFFSET
	if should_open:
		call_deferred("_focus_first_button")

func _focus_first_button() -> void:
	if _open and not _buttons.is_empty():
		_buttons[0].grab_focus()

func _move_focus(direction: int) -> void:
	if _buttons.is_empty():
		return
	var current_index := _buttons.find(get_viewport().gui_get_focus_owner())
	if current_index < 0:
		current_index = 0
	var next_index := wrapi(current_index + direction, 0, _buttons.size())
	_buttons[next_index].grab_focus()

func _on_resume_pressed() -> void:
	_toggle(false)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()

func _restart() -> void:
	panel_container.visible = false
	panel_container.modulate = Color.TRANSPARENT
	_open = false
	for Button in _buttons:
		Button.offset_transform_position = CLOSED_OFFSET
