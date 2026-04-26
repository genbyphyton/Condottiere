extends Control

func _ready() -> void:
	call_deferred("_connect_buttons")

func _connect_buttons() -> void:
	for child in get_children():
		print(child.name)
	var vbox := find_child("VBoxContainer") as VBoxContainer
	if vbox:
		var play := vbox.find_child("ButtonPlay") as Button
		var quit := vbox.find_child("ButtonQuit") as Button
		if play:
			play.pressed.connect(_on_play)
		if quit:
			quit.pressed.connect(_on_quit)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/faction_select.tscn")

func _on_quit() -> void:
	get_tree().quit()
