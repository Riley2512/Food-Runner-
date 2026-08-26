extends CharacterBody3D

@onready var health_compoment: HealthComponent = $HealthCompoment
@onready var health_lbl: Label = $HealthLbl
@onready var health_bar: ProgressBar = get_tree().current_scene.get_node_or_null("CanvasLayer/Healthbar")
@onready var inventory_label: Label = get_tree().current_scene.get_node_or_null("CanvasLayer/InventoryLabel")
@onready var knife_icon: TextureRect = get_tree().current_scene.get_node_or_null("CanvasLayer/InventoryBar/Slot1/KnifeIcon")
@onready var camera_pivot: Node3D = $SpringArmPivort

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var is_dead = false
var spawn_position := Vector3.ZERO
var knife_collected := false
var knife_equipped := false
var held_knife: Area3D = null
var attack_active := false
signal died

func _ready() -> void:
	spawn_position = global_position
	health_compoment.health = health_compoment.maxHealth
	health_compoment.died.connect(die)
	_update_health_display()
	_update_inventory_display()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	rotation.y = camera_pivot.global_rotation.y
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var camera_forward := -camera_pivot.global_transform.basis.z
	camera_forward.y = 0
	camera_forward = camera_forward.normalized()
	var camera_right := camera_pivot.global_transform.basis.x
	camera_right.y = 0
	camera_right = camera_right.normalized()
	var direction := (camera_right * input_dir.x - camera_forward * input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	_update_health_display()
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_1 and event.pressed and not event.echo:
		if knife_collected:
			knife_equipped = not knife_equipped
			_update_inventory_display()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_attack()

func pick_up_knife() -> void:
	knife_collected = true
	held_knife = preload("res://knife.tscn").instantiate()
	held_knife.name = "HeldKnife"
	add_child(held_knife)
	held_knife.position = Vector3(0.45, 0.65, -0.55)
	held_knife.rotation_degrees = Vector3(20.0, 0.0, -35.0)
	held_knife.monitoring = false
	held_knife.monitorable = false
	held_knife.collision_mask = 4
	held_knife.get_node("CollisionShape3D").disabled = true
	held_knife.body_entered.connect(_on_held_knife_body_entered)
	_update_inventory_display()

func _update_inventory_display() -> void:
	if inventory_label:
		inventory_label.text = "INVENTORY  |  PRESS 1 TO EQUIP" if knife_collected and not knife_equipped else "INVENTORY  |  KNIFE EQUIPPED" if knife_equipped else "INVENTORY"
	if knife_icon:
		knife_icon.modulate = Color(1.0, 0.8, 0.3, 1.0) if knife_equipped else Color.WHITE if knife_collected else Color(1.0, 1.0, 1.0, 0.35)

func _attack() -> void:
	if not knife_equipped or is_dead or attack_active or held_knife == null:
		return
	attack_active = true
	var collision_shape: CollisionShape3D = held_knife.get_node("CollisionShape3D")
	collision_shape.disabled = false
	held_knife.monitoring = true
	await get_tree().create_timer(0.18).timeout
	if is_instance_valid(held_knife):
		held_knife.monitoring = false
		collision_shape.disabled = true
	attack_active = false

func _on_held_knife_body_entered(body: Node3D) -> void:
	if attack_active and body.is_in_group("Enemies") and body.has_method("take_damage"):
		body.take_damage(25.0, self)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health_compoment.take_damage(amount)
	_update_health_display()

func _update_health_display() -> void:
	if health_lbl:
		health_lbl.text = str(snapped(health_compoment.health, 1))
	if health_bar:
		health_bar.value = health_compoment.health

func on_damage(attack: Attack) -> void:
	if is_dead:
		return
	health_compoment.damage(attack)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()

func on_death() -> void:
	return
