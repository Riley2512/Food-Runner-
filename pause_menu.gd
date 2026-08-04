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
	for child in v_box_container.get_children():
		if child is AnimatedButton: 
			_buttons.append(child)
	_restart()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action(&"esc"):
		_toggle(not _open)



func _toggle(should_open: bool) -> void:
	_open = not _open
	panel_container.visible = should_open
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel()
	
	if should_open:
		panel_container.visible = true
	
	var count := _buttons.size()
	for i in count:
		var step := i if should_open else count -1 - i
		var target := Vector2.ZERO if should_open else CLOSED_OFFSET
		_tween.tweem_property(_buttons[i], ^"offset_transform_position", target, SLIDE_TIME)\
		.set_delay(step * STAGGER).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		
	_tween.tween_property(panel_container, ^"modulate", Color.WHITE if should_open else Color.TRANSPARENT, SLIDE_TIME)
		
	_tween.chain().tween_callback(func() -> void: panel_container.visible = false)

func _restart() -> void:
	panel_container.visible = false
	panel_container.modulate = Color.TRANSPARENT
	_open = false
	for Button in _buttons:
		Button.offset_transform_position = CLOSED_OFFSET
