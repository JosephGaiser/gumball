extends Node

@export var blue_ball: PackedScene
@export var yellow_ball: PackedScene
@export var green_ball: PackedScene
@export var red_ball: PackedScene
@export var peg_scene: PackedScene
@export var spawn_count: int = 1
@export var cooldown_length: float = .01

@onready var floor_collision: CollisionShape2D = $Floor/CollisionShape2D
@onready var peg_inventory: Dictionary = {"default_peg": {"scene": peg_scene, "count": 10}}
@onready var active_ball_type: PackedScene = blue_ball
@onready var cooldown: SceneTreeTimer = get_tree().create_timer(0)

@onready var ui_count = $"../Control/Count"
@onready var ui_spawn_count = $"../Control/SpawnCount"

static var can_spawn_balls: bool = true
var balls_count: int             = 0
var active_peg: Node
var active_peg_type: String      = "default_peg"


# Called when the node enters the scene tree for the first time.
func _ready():
	ui_count.text = str(spawn_count)
	ui_spawn_count.text = str(balls_count)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active_peg != null:
		active_peg.position = get_viewport().get_mouse_position()


func spawn_ball(position: Vector2, scn: PackedScene):
	var ball = scn.instantiate()
	balls_count += 1

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
	ui_spawn_count.text = str(balls_count)


func _on_SpawnBall_pressed(event: InputEventMouseButton) -> void:
	if can_spawn_balls == false:
		return
	# handle / reset cooldoown
	if cooldown.time_left != 0:
		return
	cooldown = get_tree().create_timer(cooldown_length)
	for n in spawn_count:
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
	if active_peg == null:
		active_peg = peg_inventory[active_peg_type]["scene"].instantiate()
		active_peg.position = event.position
		add_child(active_peg)
		# Decrement the peg inventory
		peg_inventory[active_peg_type]["count"] -= 1


func _input(event):
	if Input.is_action_just_pressed("increase_spawn"):
		spawn_count += 1
		ui_count.text = str(spawn_count)
	if Input.is_action_just_pressed("decrease_spawn"):
		if spawn_count > 1:
			spawn_count -= 1
			ui_count.text = str(spawn_count)

	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("spawn_ball"):
			_on_SpawnBall_pressed(event)

		if Input.is_action_just_pressed("spawn_peg"):
			_on_SpawnPeg_pressed(event)

		if Input.is_action_just_released("spawn_peg"):
			if active_peg != null:
				active_peg = null


func _on_drop_pressed():
	for child in get_children():
		if child is StaticBody2D:
			child.get_node("CollisionShape2D").disabled = !child.get_node("CollisionShape2D").disabled


func _on_select_peg_item_selected(index):
	match index:
		0:
			active_peg_type = "default_peg"
		1:
			active_peg_type = "cross_peg"


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
	can_spawn_balls = false


func _on_disable_spawn_mouse_exited():
	can_spawn_balls = true
