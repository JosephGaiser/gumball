extends Node2D
class_name YellowBall

@export var collision_sound: AudioStream
@export var collision_pitch: float = 10

func _ready():
    var body: RigidBody2D = $RigidBody2D
    body.contact_monitor = true
    body.max_contacts_reported = 5

func _on_rigid_body_2d_body_entered(body):
    print("yellow ball collided with", body)
    SoundManager.play_sound_with_pitch(collision_sound, collision_pitch)
