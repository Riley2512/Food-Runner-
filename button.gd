extends Button

@export var hover_scale : Vector2 = Vector2(1.1, 1.1)
@export var normal_scale : Vector2 = Vector2(1.0, 1.0)
@export var duration : float = 0.1

func _ready() -> void:
	# Connect UI signals to functions programmatically
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	create_tween().tween_property(self, "scale", hover_scale, duration).set_trans(Tween.TRANS_SINE)

func _on_mouse_exited() -> void:
	create_tween().tween_property(self, "scale", normal_scale, duration).set_trans(Tween.TRANS_SINE)

func _on_button_down() -> void:
	create_tween().tween_property(self, "scale", hover_scale * 0.95, duration).set_trans(Tween.TRANS_SINE)

func _on_button_up() -> void:
	# Return to hover scale if mouse is still over the button, otherwise normal
	var target = hover_scale if is_hovered() else normal_scale
	create_tween().tween_property(self, "scale", target, duration).set_trans(Tween.TRANS_SINE)
