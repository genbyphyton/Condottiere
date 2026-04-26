extends Control

func setup(winner_index: int) -> void:
	var is_human_winner := winner_index == 0
	$VBoxContainer/LabelResult.text = "Victory!" if is_human_winner else "Defeat!"
	$VBoxContainer/LabelWinner.text = "Player %d wins the war!" % (winner_index + 1)
	find_child("ButtonPlayAgain").pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	find_child("ButtonQuit").pressed.connect(func():
		get_tree().quit()
	)

func _ready() -> void:
	MusicController.victory_play()
	var winner := GameState.get_last_winner()
	setup(winner)	
