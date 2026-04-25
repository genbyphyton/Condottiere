# test_battle.gd
# run: godot --headless --script test_battle.gd

extends SceneTree

const PLAYER_NAMES := ["Player 1", "Player 2", "Player 3", "Player 4"]
const BOT_INDICES := [1, 2, 3]

const PLAYER_FACTIONS := [
	Faction.FactionType.ENGLAND,
	Faction.FactionType.SCOTLAND,
	Faction.FactionType.IRELAND,
	Faction.FactionType.WALES,
]

var _deck: Deck
var _hands: Array[PlayerHand] = []
var _factions: Array[Faction] = []
var _battle: Battle
var _bots: Dictionary = {}
var _condottiere_player := 0
var _battle_over := false

func _init() -> void:
	_deck = Deck.new()

	for i in PlayerHand.PLAYER_COUNT:
		var hand := PlayerHand.new()
		hand.add_cards(_deck.draw_many(10))
		_hands.append(hand)
		_factions.append(Faction.new(PLAYER_FACTIONS[i]))

	_battle = Battle.new(_hands, _deck, _condottiere_player, _factions)
	_battle.battle_ended.connect(_on_battle_ended)
	_battle.bishop_played.connect(_on_bishop_played)
	_battle.wales_pick_card.connect(_on_wales_pick_card)
	_battle.wales_ability_used.connect(_on_wales_ability_used)
	_battle.ireland_ability_used.connect(_on_ireland_ability_used)

	for i in BOT_INDICES:
		_bots[i] = BotPlayer.new(i, _battle, _hands[i], _factions[i])
		_bots[i].action_taken.connect(_on_bot_action)

	print("=== CONDOTTIERE — test round ===")
	print("First turn: %s\n" % PLAYER_NAMES[_condottiere_player])
	_print_factions()

	_game_loop()

func _is_bot(player_index: int) -> bool:
	return player_index in _bots

func _print_factions() -> void:
	print("Factions:")
	for i in PlayerHand.PLAYER_COUNT:
		var label := "[BOT]" if _is_bot(i) else "[YOU]"
		print("  %s %s: %s" % [PLAYER_NAMES[i], label, _factions[i].get_display_name()])
	print("")

func _game_loop() -> void:
	while not _battle_over:
		var current := _battle.get_current_player()
		_print_state(current)
		if _battle_over:
			break

		if _is_bot(current):
			_bots[current].take_turn()
			if not _battle_over:
				_print_strengths()
			if _battle_over:
				break

		else:
			var faction := _factions[current]
			print("Enter card number, 'p' to pass, 'w' for Wales ability, 'i' for Ireland ability, 'q' to quit:")
			var input := _read_line().strip_edges()

			if input == "q":
				quit()
				return
			elif input == "p":
				_battle.pass_turn(current)
				if not _battle_over:
					print("%s passes.\n" % PLAYER_NAMES[current])
			elif input == "w":
				if not faction.is_wales():
					print("You are not Wales.\n")
				elif not faction.can_use_ability():
					print("Wales ability already used this round.\n")
				elif not _battle.use_wales_ability(current):
					print("No active weather to clear.\n")
			elif input == "i":
				if not faction.is_ireland():
					print("You are not Ireland.\n")
				elif not faction.can_use_ability():
					print("Ireland ability already used this round.\n")
				else:
					_handle_ireland(current)
			elif input.is_valid_int():
				var idx := input.to_int() - 1
				var cards := _hands[current].get_cards()
				if idx < 0 or idx >= cards.size():
					print("Invalid card number.\n")
					continue
				var card := cards[idx]

				if card.card_type == CardData.CardType.SCARECROW:
					if not _battle.play_card(current, card):
						print("Cannot play this card (Autumn is active).\n")
						continue
					if not _battle_over:
						_handle_scarecrow(current)
				else:
					if not _battle.play_card(current, card):
						print("Cannot play this card.\n")
						continue
				if not _battle_over:
					_print_strengths()
			else:
				print("Invalid input.\n")

func _handle_scarecrow(player_index: int) -> void:
	var line_cards := _battle.get_line(player_index).get_cards().filter(
		func(c: CardData) -> bool: return c.is_mercenary()
	)
	if line_cards.is_empty():
		print("No mercenaries to retrieve.\n")
		_battle.apply_scarecrow(player_index, null)
		return

	print("Choose a mercenary to retrieve (or 'n' to skip):")
	for i in line_cards.size():
		print("  %d. %s" % [i + 1, line_cards[i].display_name])

	var input := _read_line().strip_edges()
	if input == "n":
		_battle.apply_scarecrow(player_index, null)
	elif input.is_valid_int():
		var idx := input.to_int() - 1
		if idx >= 0 and idx < line_cards.size():
			_battle.apply_scarecrow(player_index, line_cards[idx])
		else:
			print("Invalid number, skipping.\n")
			_battle.apply_scarecrow(player_index, null)

func _handle_ireland(player_index: int) -> void:
	var all_enemy_cards: Array[CardData] = []
	var card_owners: Array[int] = []
	for i in PlayerHand.PLAYER_COUNT:
		if i == player_index:
			continue
		for card in _battle.get_line(i).get_cards():
			all_enemy_cards.append(card)
			card_owners.append(i)

	if all_enemy_cards.is_empty():
		print("No cards on enemy battle lines.\n")
		return

	print("Choose a card to take from enemy line:")
	for i in all_enemy_cards.size():
		print("  %d. %s (from %s)" % [i + 1, all_enemy_cards[i].display_name, PLAYER_NAMES[card_owners[i]]])

	var input := _read_line().strip_edges()
	if not input.is_valid_int():
		print("Cancelled.\n")
		return
	var target_idx := input.to_int() - 1
	if target_idx < 0 or target_idx >= all_enemy_cards.size():
		print("Invalid number.\n")
		return

	var target_card := all_enemy_cards[target_idx]
	var target_player := card_owners[target_idx]

	var hand_cards := _hands[player_index].get_cards()
	print("Choose a card from your hand to give:")
	for i in hand_cards.size():
		print("  %d. %s" % [i + 1, hand_cards[i].display_name])

	input = _read_line().strip_edges()
	if not input.is_valid_int():
		print("Cancelled.\n")
		return
	var hand_idx := input.to_int() - 1
	if hand_idx < 0 or hand_idx >= hand_cards.size():
		print("Invalid number.\n")
		return

	var hand_card := hand_cards[hand_idx]
	if not _battle.use_ireland_ability(player_index, target_card, target_player, hand_card):
		print("Ireland ability failed.\n")
	else:
		if not _battle_over:
			_print_strengths()

func _print_state(current: int) -> void:
	var label := "[BOT]" if _is_bot(current) else "[YOU]"
	var faction_name := _factions[current].get_display_name()
	print("--- Turn: %s %s [%s] ---" % [PLAYER_NAMES[current], label, faction_name])

	var weather := ""
	if _battle.has_winter(): weather += "❄ Winter "
	if _battle.has_spring(): weather += "🌸 Spring "
	if _battle.has_autumn(): weather += "🍂 Autumn "
	if weather != "":
		print("Weather: %s" % weather)

	if not _is_bot(current):
		print("Hand:")
		var cards := _hands[current].get_cards()
		for i in cards.size():
			print("  %d. %s" % [i + 1, cards[i].display_name])

	print("Battle lines:")
	for i in PlayerHand.PLAYER_COUNT:
		var passed_str := " [passed]" if _battle.has_passed(i) else ""
		var bot_str := " [BOT]" if _is_bot(i) else ""
		var f_str := " (%s)" % _factions[i].get_display_name()
		print("  %s%s%s%s: strength %d" % [PLAYER_NAMES[i], bot_str, f_str, passed_str, _battle.get_strength(i)])
	print("")

func _print_strengths() -> void:
	print("Current strengths:")
	for i in PlayerHand.PLAYER_COUNT:
		print("  %s: %d" % [PLAYER_NAMES[i], _battle.get_strength(i)])
	print("")

func _on_battle_ended(winner_index: int) -> void:
	_battle_over = true
	print("\n=== BATTLE ENDED ===")
	if winner_index == -1:
		print("Draw — no province is captured.")
	else:
		var token_receiver := _battle.get_condottiere_token_receiver(winner_index)
		print("Winner: %s" % PLAYER_NAMES[winner_index])
		if token_receiver != winner_index:
			print("Condottiere token goes to: %s (most courtesans)" % PLAYER_NAMES[token_receiver])
		else:
			print("Condottiere token goes to: %s" % PLAYER_NAMES[token_receiver])

	print("\nFinal strengths:")
	for i in PlayerHand.PLAYER_COUNT:
		print("  %s: %d" % [PLAYER_NAMES[i], _battle.get_strength(i)])

	_battle.end_battle()
	quit()

func _read_line() -> String:
	var line := ""
	while true:
		var byte := OS.read_string_from_stdin(1)
		if byte == "\n" or byte == "":
			break
		if byte != "\r":
			line += byte
	return line

func _on_bishop_played(player_index: int) -> void:
	if _is_bot(player_index):
		print("Auto: leaving off board.")
		return
	print("%s played Bishop. Enter region number (or 'n' to leave off board):" % PLAYER_NAMES[player_index])
	var input := _read_line().strip_edges()
	if input == "n" or input == "":
		print("Favor of the Pope left off the board.")
	else:
		print("Favor of the Pope placed on region %s." % input)

func _on_wales_pick_card(player_index: int, available_cards: Array[CardData]) -> void:
	if _is_bot(player_index):
		var best: CardData = null
		for card in available_cards:
			if card.is_mercenary():
				if best == null or card.strength > best.strength:
					best = card
		if best != null:
			_battle.wales_save_card(player_index, best)
			print("%s (Wales) saves: %s" % [PLAYER_NAMES[player_index], best.display_name])
		return

	print("\n%s (Wales): choose a card to keep for next round (or 'n' to skip):" % PLAYER_NAMES[player_index])
	for i in available_cards.size():
		print("  %d. %s" % [i + 1, available_cards[i].display_name])

	var input := _read_line().strip_edges()
	if input == "n":
		return
	elif input.is_valid_int():
		var idx := input.to_int() - 1
		if idx >= 0 and idx < available_cards.size():
			_battle.wales_save_card(player_index, available_cards[idx])
			print("Saved: %s" % available_cards[idx].display_name)
		else:
			print("Invalid number, skipping.\n")

func _on_wales_ability_used(player_index: int) -> void:
	print("%s (Wales) clears all weather cards!\n" % PLAYER_NAMES[player_index])

func _on_ireland_ability_used(player_index: int) -> void:
	print("%s (Ireland) swaps a card!\n" % PLAYER_NAMES[player_index])

func _on_bot_action(player_index: int, description: String) -> void:
	print("%s %s" % [PLAYER_NAMES[player_index], description])
