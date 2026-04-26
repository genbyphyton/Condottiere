extends Node

var first_song = preload("res://audio/Percival Schuttenbach - Cloak And Dagger.mp3")
var second_song = preload("res://audio/Percival Schuttenbach - The Nightingale.mp3")
var victory_sound = preload("res://audio/victory_sound.mp3")

var audio_stream_player: AudioStreamPlayer

func _ready():
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)

func first_play():
	if audio_stream_player == null:
		return
	audio_stream_player.stream = first_song
	audio_stream_player.volume_db = -30.00
	audio_stream_player.play()
	
func second_play():
	if audio_stream_player == null:
		return
	audio_stream_player.stream = second_song
	audio_stream_player.volume_db = -30.00
	audio_stream_player.play()
	
func victory_play():
	if audio_stream_player == null:
		return
	audio_stream_player.stream = victory_sound
	audio_stream_player.volume_db = -25.00
	audio_stream_player.play()
