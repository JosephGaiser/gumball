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
var balls_count: int       = 0
var ball_scenes: Array


# Called when the node enters the scene tree for the first time.
func _ready():
    ball_scenes = [blue_ball, yellow_ball, red_ball, green_ball]
    cooldown = get_tree().create_timer(0)
    $SpawnCount.text = str(spawn_count)
    $Count.text = str(balls_count)


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
    body.apply_impulse(Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y)), position)
    add_child(ball)
    $Count.text = str(balls_count)

func _on_SpawnBall_pressed(event: InputEventMouseButton):
    # handle / reset cooldoown
    if cooldown.time_left != 0:
        pass
    cooldown = get_tree().create_timer(cooldown_length)
    await get_tree().create_timer(.01).timeout
    for n in spawn_count:
        var random_scn = ball_scenes[randi() % ball_scenes.size()]
        spawn_ball(event.position, random_scn)


func _input(event):
    if Input.is_action_just_pressed("increase_spawn"):
        spawn_count += 1
        $SpawnCount.text = str(spawn_count)
    if Input.is_action_just_pressed("decrease_spawn"):
        if spawn_count > 1:
            spawn_count -= 1
            $SpawnCount.text = str(spawn_count)

    if event is InputEventMouseButton:
        if Input.is_action_just_pressed("spawn_ball"):
            _on_SpawnBall_pressed(event)

        if Input.is_action_just_pressed("spawn_peg"):
            if active_peg == null:
                active_peg = peg_scene.instantiate()
                active_peg.position = get_viewport().get_mouse_position()
                add_child(active_peg)

        if Input.is_action_just_released("spawn_peg"):
            if active_peg != null:
                active_peg = null
