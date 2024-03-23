extends Control
@onready var sound_volume_label: Label = $Sound/SoundVolume
@onready var music_volume_label: Label = $Music/MusicVolume


func _ready() -> void:
	SoundManager.set_sound_volume(0.1)
	SoundManager.set_music_volume(0.1)
