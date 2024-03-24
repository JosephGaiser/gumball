extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	set_process(true)

@export var rotation_speed: float = 90.0  # Speed of rotation in degrees per second


func _process(delta: float) -> void:
	rotation_degrees += rotation_speed * delta
