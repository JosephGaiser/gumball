extends Node

@export var ball_scene: PackedScene
@export var peg_scene: PackedScene

var active_peg: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active_peg != null:
		print("doing delta stuff")
		active_peg.position = get_viewport().get_mouse_position()
	

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("spawn_ball"):
			var ball = ball_scene.instantiate()
			ball.position = event.position
			add_child(ball)
		if Input.is_action_just_pressed("spawn_peg"):
			if active_peg == null:
				active_peg = peg_scene.instantiate()
				add_child(active_peg)
			
		if Input.is_action_just_released("spawn_peg"):
			if active_peg != null:
				active_peg = null
