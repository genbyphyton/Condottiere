class_name MapUI
extends Control

@onready var label_player: Label = $PlayerPanel/VBoxContainer/LabelPlayer
@onready var label_faction: Label = $PlayerPanel/VBoxContainer/LabelFaction
@onready var label_regions: Label = $PlayerPanel/VBoxContainer/LabelRegions
@onready var action_label: Label = $ActionPanel/HBoxContainer/LabelAction
@onready var battle_button: Button = $ActionPanel/HBoxContainer/ButtonBattle
@onready var stats_container: VBoxContainer = $StatsPanel/VBoxContainer

var _selected_region: String = ""

func _ready() -> void:
	battle_button.pressed.connect(_on_battle_button_pressed)
	if GameState.is_game_over():
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/victory_scene.tscn")
		return
	GameState.game_over.connect(_on_game_over)
	GameState.region_captured.connect(_on_region_captured)
	GameState.battle_started.connect(_on_battle_started)
	GameState.round_ended.connect(_on_round_ended)
	battle_button.disabled = true
	_update_ui()
	_create_stats_labels()

func _create_stats_labels() -> void:
	for i in PlayerHand.PLAYER_COUNT:
		var label := Label.new()
		label.name = "LabelStats%d" % i
		stats_container.add_child(label)
	_update_ui()

func _update_stats() -> void:
	for i in PlayerHand.PLAYER_COUNT:
		var label := stats_container.get_node_or_null("LabelStats%d" % i) as Label
		if label == null:
			continue
		var faction := GameState.get_faction(i)
		var faction_name := faction.get_display_name() if faction != null else "?"
		var regions := _count_regions(i)
		label.text = "P%d [%s]: %d" % [i + 1, faction_name, regions]

func set_selected_region(region_name: String) -> void:
	_selected_region = region_name
	if region_name == "":
		action_label.text = "Select a region to attack"
		battle_button.disabled = true
		return
	if GameState.get_hand(0).is_empty():
		action_label.text = "No cards left this round"
		battle_button.disabled = true
		return
	if not GameState.can_attack(region_name):
		action_label.text = "%s — cannot attack" % region_name
		battle_button.disabled = true
		return
	action_label.text = "Attack: %s" % region_name
	battle_button.disabled = false

func _on_battle_button_pressed() -> void:
	if _selected_region == "":
		return
	if GameState.get_hand(0).is_empty():
		action_label.text = "No cards left this round!"
		return
	var success := GameState.start_battle(_selected_region, 0)
	if success:
		get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")
	else:
		action_label.text = "Cannot attack this region"

func _on_region_captured(region_name: String, player_index: int) -> void:
	_update_ui()

func _on_battle_started(region_name: String) -> void:
	action_label.text = "Battle: %s" % region_name

func _on_round_ended() -> void:
	_update_ui()
	if _selected_region != "":
		set_selected_region(_selected_region)
	else:
		action_label.text = "Select a region to attack"

func _on_game_over(winner_index: int) -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/victory_scene.tscn")

func _update_ui() -> void:
	var condottiere := GameState.get_condottiere_player()
	var faction := GameState.get_faction(condottiere)
	var faction_name := faction.get_display_name() if faction != null else "None"
	var regions := _count_regions(condottiere)

	label_player.text = "Player %d" % (condottiere + 1)
	label_faction.text = "Faction: %s" % faction_name
	label_regions.text = "Regions: %d" % regions
	_update_stats()

func _count_regions(player_index: int) -> int:
	var count := 0
	for region in RegionData.REGIONS:
		if GameState.get_region_owner(region) == player_index:
			count += 1
	return count
