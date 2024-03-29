extends Node

@export var blue_ball: PackedScene
@export var yellow_ball: PackedScene
@export var green_ball: PackedScene
@export var red_ball: PackedScene
@export var round_peg: PackedScene
@export var cross_peg: PackedScene
@export var slider_peg: PackedScene
@export var spawns_per_click: int = 1
@export var cooldown_length: float = 1.0

@onready var peg_inventory: Dictionary = {
											 PegType.ROUND: {"scene": round_peg, "count": 5},
											 PegType.CROSS: {"scene": cross_peg, "count": 3},
											 PegType.SLIDER: {"scene": slider_peg, "count": 3}
										 }

@onready var active_ball_type: PackedScene = green_ball
@onready var active_peg_type: PegType = PegType.ROUND
@onready var cooldown: SceneTreeTimer = get_tree().create_timer(0)
@onready var ui_count: Label = %Count
@onready var ui_spawn_count: Label = %SpawnCount
@onready var level_collision: CollisionPolygon2D = %LevelCollision
@onready var select_peg: ItemList = %"Select Peg"
@onready var mouse: Node2D = %Mouse

var can_spawn_balls: bool = true
var spawn_count: int      = 0
var held_peg: Node
enum PegType {ROUND, CROSS, SLIDER}


# Called when the node enters the scene tree for the first time.
func _ready():
	ui_count.text = str(spawns_per_click)
	ui_spawn_count.text = str(spawn_count)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var pos: Vector2 = get_viewport().get_mouse_position()
	mouse.position = pos
	if held_peg != null:
		held_peg.position = pos

	for i in range(select_peg.get_item_count()):
		# TODO seems really inefficient to set every delta, use signal?
		var peg_type = PegType.values()[i]  # Assuming the order of items in select_peg matches the order of values in PegType
		var count    = peg_inventory[peg_type]["count"]
		select_peg.set_item_text(i, str(count))


func spawn_ball(position: Vector2, scn: PackedScene):
	var ball = scn.instantiate()
	scn.set_name(scn.get_name())
	spawn_count += 1

	# Add a random offset to the position
	var offset: Vector2 = Vector2(randi_range(-50, 50), randi_range(-50, 50))
	ball.position = position + offset

	var body: RigidBody2D = ball.get_node("RigidBody2D") as RigidBody2D
	var max_x: int        = 100
	var min_x: int        = -100
	var max_y: int        = 100
	var min_y: int        = -100
	if body != null:
		body.apply_impulse(Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y)), position)
	add_child(ball)
	ui_spawn_count.text = str(spawn_count)


func _on_SpawnBall_pressed(event: InputEventMouseButton) -> void:
	if can_spawn_balls == false:
		return
	# handle / reset cooldoown
	if cooldown.time_left != 0:
		return
	cooldown = get_tree().create_timer(cooldown_length)
	for n in spawns_per_click:
		spawn_ball(event.position, active_ball_type)


func _on_SpawnPeg_pressed(event: InputEventMouseButton) -> void:
	# handle / reset cooldown
	if cooldown.time_left != 0:
		return
	cooldown = get_tree().create_timer(cooldown_length)

	# Check if there are pegs in the inventory for the active peg type
	if peg_inventory[active_peg_type]["count"] <= 0:
		return

	# Spawn the peg at the event position
	if held_peg == null:
		held_peg = peg_inventory[active_peg_type]["scene"].instantiate()
		held_peg.position = event.position
		add_child(held_peg)
		# Decrement the peg inventory
		peg_inventory[active_peg_type]["count"] -= 1


func _input(event):
	if Input.is_action_just_pressed("increase_spawn"):
		spawns_per_click += 1
		ui_count.text = str(spawns_per_click)
	if Input.is_action_just_pressed("decrease_spawn"):
		if spawns_per_click > 1:
			spawns_per_click -= 1
			ui_count.text = str(spawns_per_click)

	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("spawn_ball"):
			_on_SpawnBall_pressed(event)

		if Input.is_action_just_pressed("spawn_peg"):
			_on_SpawnPeg_pressed(event)

		if Input.is_action_just_released("spawn_peg"):
			if held_peg != null:
				held_peg = null


func _on_drop_pressed():
	can_spawn_balls = false
	level_collision.disabled = !level_collision.disabled


func _on_select_peg_item_selected(index):
	match index:
		0:
			active_peg_type = PegType.ROUND
		1:
			active_peg_type = PegType.CROSS
		2:
			active_peg_type = PegType.SLIDER


func _on_select_ball_item_selected(index):
	match index:
		0:
			active_ball_type = green_ball
		1:
			active_ball_type = red_ball
		2:
			active_ball_type = blue_ball
		3:
			active_ball_type = yellow_ball


func _on_disable_spawn_mouse_entered():
	can_spawn_balls = true


func _on_disable_spawn_mouse_exited():
	can_spawn_balls = false
