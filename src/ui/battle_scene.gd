class_name BattleScene
extends Control

const PLAYER_NAMES := ["Player 1", "Player 2", "Player 3", "Player 4"]

@onready var label_region: Label = $TopPanel/HBoxContainer/LabelRegion
@onready var label_turn: Label = $TopPanel/HBoxContainer/LabelTurn
@onready var hand_container: HBoxContainer = $BottomPanel/VBoxContainer/HandContainer
@onready var button_pass: Button = $BottomPanel/VBoxContainer/ActionButtons/ButtonPass
@onready var button_faction: Button = $BottomPanel/VBoxContainer/ActionButtons/ButtonFaction
@onready var faction_popup: Control = $FactionPopup
@onready var popup_container: VBoxContainer = $FactionPopup/PanelContainer/VBoxContainer

var _battle: Battle
var _player_index: int = 0
var _bots: Array[BotPlayer] = []
var _line_containers: Array[HBoxContainer] = []
var _strength_labels: Array[Label] = []
var _is_player_turn: bool = false
var _processing_card: bool = false
var _handling_turn: bool = false

func _ready() -> void:
	print("BattleScene ready")
	print("GameState: ", GameState)
	print("Battle from GameState: ", GameState.get_battle())
	_battle = GameState.get_battle()
	print("Battle: ", _battle)
	_player_index = 0

	_battle.battle_ended.connect(_on_battle_ended)
	_battle.turn_changed.connect(_on_turn_changed)
	_battle.card_played.connect(_on_card_played)
	_battle.player_passed.connect(_on_player_passed)
	_battle.bishop_played.connect(_on_bishop_played)
	_battle.wales_pick_card.connect(_on_wales_pick_card)

	for i in PlayerHand.PLAYER_COUNT:
		if i == _player_index:
			_bots.append(null)
			continue
		var bot := BotPlayer.new(i, _battle, GameState.get_hand(i), GameState.get_faction(i))
		bot.action_taken.connect(_on_bot_action)
		_bots.append(bot)
	
	button_pass.pressed.connect(_on_pass_pressed)
	button_faction.pressed.connect(_on_faction_pressed)
	faction_popup.visible = false
	
	_setup_battle_lines()
	
	label_region.text = "Battle for: %s" % GameState._current_region
	_update_hand()
	_on_turn_changed(_battle.get_current_player())

func _setup_battle_lines() -> void:
	for i in PlayerHand.PLAYER_COUNT:
		var line := $BattleLines.get_child(i) as HBoxContainer
		_line_containers.append(line)
		var strength_label := Label.new()
		strength_label.name = "StrengthLabel"
		line.add_child(strength_label)
		_strength_labels.append(strength_label)
	_update_battle_lines()

func _update_battle_lines() -> void:
	for i in PlayerHand.PLAYER_COUNT:
		var line := _line_containers[i]
		for child in line.get_children():
			if child.name != "StrengthLabel":
				child.queue_free()
		var cards := _battle.get_line(i).get_cards()
		for card in cards:
			var label := Label.new()
			var display := card.display_name
			if GameState.get_faction(i) != null and GameState.get_faction(i).is_england() and card.is_mercenary():
				display = "???"
			label.text = display
			line.add_child(label)
		var strength_display := "???" if (GameState.get_faction(i) != null and GameState.get_faction(i).is_england()) else str(_battle.get_strength(i))
		_strength_labels[i].text = "%s: %s" % [PLAYER_NAMES[i], strength_display]

func _update_hand() -> void:
	print("Update hand, is_player_turn: ", _is_player_turn)
	for child in hand_container.get_children():
		child.queue_free()
	if not _is_player_turn:
		return
	var cards := GameState.get_hand(_player_index).get_cards()
	for i in cards.size():
		var btn := Button.new()
		btn.text = cards[i].display_name
		btn.focus_mode = Control.FOCUS_NONE
		var card := cards[i]
		btn.pressed.connect(func(): _on_card_selected(card))
		hand_container.add_child(btn)

func _on_card_selected(card: CardData) -> void:
	if not _is_player_turn or _processing_card:
		return
	_processing_card = true
	if card.card_type == CardData.CardType.SCARECROW:
		_battle.play_card(_player_index, card)
		_show_scarecrow_popup()
	elif card.card_type == CardData.CardType.BISHOP:
		_battle.play_card(_player_index, card)
		_show_bishop_popup()
	else:
		_battle.play_card(_player_index, card)
	_update_hand()
	_update_battle_lines()
	_processing_card = false

func _on_pass_pressed() -> void:
	if not _is_player_turn:
		return
	_battle.pass_turn(_player_index)
	_is_player_turn = false
	_update_hand()

func _on_faction_pressed() -> void:
	var faction := GameState.get_faction(_player_index)
	if faction == null or not faction.can_use_ability():
		return
	if faction.is_wales():
		_battle.use_wales_ability(_player_index)
		_update_battle_lines()
	elif faction.is_ireland():
		_show_ireland_popup()

func _on_turn_changed(player_index: int) -> void:
	if _handling_turn and player_index == _player_index:
		return
	print("Turn changed to player: ", player_index)
	label_turn.text = "Turn: %s" % PLAYER_NAMES[player_index]
	if player_index == _player_index:
		_is_player_turn = true
		_update_hand()
		_update_faction_button()
	else:
		_is_player_turn = false
		_update_hand()
		_run_bot_turn(player_index)

func _run_bot_turn(player_index: int) -> void:
	await get_tree().create_timer(0.8).timeout
	if not is_inside_tree():
		return
	if _battle == null:
		return
	if _bots[player_index] != null and not _battle.has_passed(player_index):
		_bots[player_index].take_turn()
		_update_battle_lines()
		if _battle.get_current_player() == player_index and not _battle.has_passed(player_index):
			_run_bot_turn(player_index)

func _update_faction_button() -> void:
	var faction := GameState.get_faction(_player_index)
	if faction == null:
		button_faction.visible = false
		return
	button_faction.visible = true
	button_faction.disabled = not faction.can_use_ability()
	button_faction.text = faction.get_display_name() + " ability"

func _on_card_played(player_index: int, card: CardData) -> void:
	_update_battle_lines()

func _on_player_passed(player_index: int) -> void:
	_strength_labels[player_index].text = "%s [passed]: %d" % [PLAYER_NAMES[player_index], _battle.get_strength(player_index)]

func _on_bishop_played(player_index: int) -> void:
	_show_bishop_popup()

func _on_wales_pick_card(player_index: int, available_cards: Array[CardData]) -> void:
	if player_index != _player_index:
		var best: CardData = available_cards[0]
		for card in available_cards:
			if card.strength > best.strength:
				best = card
		GameState.wales_confirm_card(player_index, best)
		return
	_show_wales_popup(available_cards)

func _show_scarecrow_popup() -> void:
	var line_cards := _battle.get_line(_player_index).get_cards().filter(
		func(c: CardData) -> bool: return c.is_mercenary()
	)
	if line_cards.is_empty():
		_battle.apply_scarecrow(_player_index, null)
		return
	_clear_popup()
	faction_popup.visible = true
	var label := Label.new()
	label.text = "Choose mercenary to retrieve (or skip):"
	popup_container.add_child(label)
	for card in line_cards:
		var btn := Button.new()
		btn.text = card.display_name
		var c: CardData = card
		btn.pressed.connect(func():
			_battle.apply_scarecrow(_player_index, c)
			faction_popup.visible = false
			_update_battle_lines()
			_update_hand()
		)
		popup_container.add_child(btn)
	var skip := Button.new()
	skip.text = "Skip"
	skip.pressed.connect(func():
		_battle.apply_scarecrow(_player_index, null)
		faction_popup.visible = false
		_update_hand()
	)
	popup_container.add_child(skip)

func _show_bishop_popup() -> void:
	_clear_popup()
	faction_popup.visible = true
	var label := Label.new()
	label.text = "Place Favor of Pontiff on region (or leave off board):"
	popup_container.add_child(label)
	for region in RegionData.REGIONS:
		if GameState.get_region_owner(region) == -1 and GameState.get_pontiff_region() != region:
			var btn := Button.new()
			btn.text = region
			var r := region
			btn.pressed.connect(func():
				GameState.set_pontiff_region(r)
				faction_popup.visible = false
			)
			popup_container.add_child(btn)
	var skip := Button.new()
	skip.text = "Leave off board"
	skip.pressed.connect(func():
		GameState.set_pontiff_region("")
		faction_popup.visible = false
	)
	popup_container.add_child(skip)

func _show_ireland_popup() -> void:
	_clear_popup()
	faction_popup.visible = true
	var label := Label.new()
	label.text = "Choose card to take from enemy line:"
	popup_container.add_child(label)
	for i in PlayerHand.PLAYER_COUNT:
		if i == _player_index:
			continue
		for card in _battle.get_line(i).get_cards():
			var btn := Button.new()
			btn.text = "%s (%s)" % [card.display_name, PLAYER_NAMES[i]]
			var c: CardData = card
			var owner: int = i
			btn.pressed.connect(func():
				_show_ireland_give_popup(c, owner)
			)
			popup_container.add_child(btn)
	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.pressed.connect(func(): faction_popup.visible = false)
	popup_container.add_child(cancel)

func _show_ireland_give_popup(target_card: CardData, target_player: int) -> void:
	_clear_popup()
	var label := Label.new()
	label.text = "Choose card from hand to give:"
	popup_container.add_child(label)
	for card in GameState.get_hand(_player_index).get_cards():
		var btn := Button.new()
		btn.text = card.display_name
		var c: CardData = card
		btn.pressed.connect(func():
			_battle.use_ireland_ability(_player_index, target_card, target_player, c)
			faction_popup.visible = false
			_update_battle_lines()
			_update_hand()
		)
		popup_container.add_child(btn)

func _show_wales_popup(available_cards: Array[CardData]) -> void:
	_clear_popup()
	faction_popup.visible = true
	var label := Label.new()
	label.text = "Choose card to keep for next round:"
	popup_container.add_child(label)
	for card in available_cards:
		var btn := Button.new()
		btn.text = card.display_name
		var c: CardData = card
		btn.pressed.connect(func():
			GameState.wales_confirm_card(_player_index, c)
			faction_popup.visible = false
		)
		popup_container.add_child(btn)

func _on_battle_ended(winner_index: int) -> void:
	print("Battle ended, winner: ", winner_index)
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree():
		return
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_bot_action(player_index: int, description: String) -> void:
	print("%s %s" % [PLAYER_NAMES[player_index], description])

func _clear_popup() -> void:
	for child in popup_container.get_children():
		child.queue_free()
