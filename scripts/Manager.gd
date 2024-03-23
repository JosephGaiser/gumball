extends Node

@export var blue_ball: PackedScene
@export var yellow_ball: PackedScene
@export var green_ball: PackedScene
@export var red_ball: PackedScene
@export var peg_scene: PackedScene
@export var spawn_count: int = 1

var active_peg: Node
var cooldown: SceneTreeTimer 
var cooldown_length: float = .01
var balls: Array = []
var ball_scenes: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	ball_scenes = [blue_ball, yellow_ball, red_ball, green_ball]
	cooldown = get_tree().create_timer(0)
	$SpawnCount.text = str(spawn_count)
	$Count.text = str(len(balls))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active_peg != null:
		active_peg.position = get_viewport().get_mouse_position()

func spawn_ball(event: InputEvent, scn: PackedScene):
	if cooldown.time_left != 0:
		pass
	cooldown = get_tree().create_timer(cooldown_length)
	await get_tree().create_timer(.01).timeout
	
	var ball = scn.instantiate()
	balls.append(ball)
	ball.position = event.position
	var body = ball.get_node("RigidBody2D") as RigidBody2D
	var max_x = 100
	var min_x = -100
	var max_y = 100
	var min_y = -100
	body.apply_impulse(Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y)), event.position)
	if event is InputEventMouseMotion:
		body.apply_impulse(event.velocity, Vector2(event.relative.x, -event.relative.y))
	add_child(ball)
	$Count.text = str(len(balls))

func _input(event):	
	if Input.is_action_just_pressed("increase_spawn"):
		spawn_count += 1
		$SpawnCount.text = str(spawn_count)
	if Input.is_action_just_pressed("decrease_spawn"):
		if spawn_count > 1:
			spawn_count -= 1
			$SpawnCount.text = str(spawn_count)
	
	if event is InputEventMouseMotion:
		# TODO FIX THIS 
		pass
			
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("spawn_ball"):
			for n in spawn_count:
				var random_scn = ball_scenes[randi() % ball_scenes.size()]
				spawn_ball(event, random_scn)
					
		if Input.is_action_just_pressed("spawn_peg"):
			if active_peg == null:
				active_peg = peg_scene.instantiate()
				add_child(active_peg)
			
		if Input.is_action_just_released("spawn_peg"):
			if active_peg != null:
				active_peg = null
