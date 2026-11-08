extends Node2D


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if audio_stream_player.playing == false:
		audio_stream_player.play()
	pass
