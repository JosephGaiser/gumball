extends Node2D

var center_position: Vector2
var amplitude: float = 100.0  # The maximum distance from the center position
var frequency: float = 1.0  # The speed of the movement
var time: float      = 0.0  # Time elapsed since the start


# Called when the node enters the scene tree for the first time.
func _ready():
	center_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	var offset: float = amplitude * sin(time * frequency)
	position.x = center_position.x + offset
