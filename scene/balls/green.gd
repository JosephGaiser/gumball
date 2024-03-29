extends Node2D
class_name Green

@export var collision_sound: AudioStream
@export var collision_pitch: float = 1.2
@export var max_sounds: int = 3
@export var max_health: int = 5
@export var health: int = max_health
@export var max_scale: Vector2 = Vector2(2, 2)  # Set the maximum scale

@onready var damage: GPUParticles2D = $Green/damage
@onready var sprite_2d: Sprite2D = $Green/Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Green/CollisionShape2D

static var sounds_playing: int = 0


func _ready():
	var body: RigidBody2D = $Green
	body.contact_monitor = true
	body.max_contacts_reported = 5


func take_damage(amount: int):
	if health > 0:
		health -= amount
		damage.emitting = true


func heal(amount: int):
	if health < max_health:
		health += amount


func grow(amount: float):
	if health == max_health:
		if sprite_2d.scale.x > max_scale.x:
			# TODO queue_free particles and += score
			pass
		else:
			sprite_2d.scale += Vector2(0.25, 0.25)
			collision_shape_2d.scale += Vector2(0.25, 0.25)


func touched_by_red():
	take_damage(1)


func touched_by_green():
	heal(1)


func touched_by_blue():
	grow(1)


func touched_by_yellow():
	pass


func _on_rigid_body_2d_body_entered(body) -> void:
	if body == null:
		return
	match body.get_name():
		"Yellow": touched_by_yellow()
		"Red": touched_by_red()
		"Green": touched_by_green()
		"Blue": touched_by_blue()
	if health <= 0:
		queue_free()
	if sounds_playing <= max_sounds:
		sounds_playing += 1
		var player: AudioStreamPlayer = SoundManager.play_sound_with_pitch(collision_sound, collision_pitch)
		await player.finished
		sounds_playing -= 1
