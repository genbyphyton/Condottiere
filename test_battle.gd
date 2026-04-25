# test_battle.gd
# run: godot --headless --script test_battle.gd

extends SceneTree

const PLAYER_NAMES := ["Player 1", "Player 2", "Player 3", "Player 4"]
const BOT_INDICES := [1, 2, 3]

var _deck: Deck
var _hands: Array[PlayerHand] = []
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

	_battle = Battle.new(_hands, _deck, _condottiere_player)
	_battle.battle_ended.connect(_on_battle_ended)
	_battle.bishop_played.connect(_on_bishop_played)
	
	for i in BOT_INDICES:
		_bots[i] = BotPlayer.new(i, _battle, _hands[i])
		_bots[i].action_taken.connect(_on_bot_action)

	print("=== CONDOTTIERE — test round ===")
	print("First turn: %s\n" % PLAYER_NAMES[_condottiere_player])

	_game_loop()

func _is_bot(player_index: int) -> bool:
	return player_index in _bots

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
			print("Enter card number to play, 'p' to pass, 'q' to quit:")
			var input := _read_line().strip_edges()

			if input == "q":
				quit()
				return
			elif input == "p":
				_battle.pass_turn(current)
				print("%s passes.\n" % PLAYER_NAMES[current])
			elif input.is_valid_int():
				var idx := input.to_int() - 1
				var cards := _hands[current].get_cards()
				if idx < 0 or idx >= cards.size():
					print("Invalid card number.\n")
					continue
				var card := cards[idx]

				if card.card_type == CardData.CardType.SCARECROW:
					if not _battle.play_card(current, card):
						print("Cannot play this card.\n")
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

func _print_state(current: int) -> void:
	var label := "[BOT]" if _is_bot(current) else "[YOU]"
	print("--- Turn: %s %s ---" % [PLAYER_NAMES[current], label])
	if not _is_bot(current):
		print("Hand:")
		var cards := _hands[current].get_cards()
		for i in cards.size():
			print("  %d. %s" % [i + 1, cards[i].display_name])
	print("Battle lines:")
	for i in PlayerHand.PLAYER_COUNT:
		var passed_str := " [passed]" if _battle.has_passed(i) else ""
		var bot_str := " [BOT]" if _is_bot(i) else ""
		print("  %s%s%s: strength %d" % [PLAYER_NAMES[i], bot_str, passed_str, _battle.get_strength(i)])
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
	if input == "n":
		print("Favor of the Pope left off the board.")
	else:
		print("Favor of the Pope placed on region %s." % input)
		
func _on_bot_action(player_index: int, description: String) -> void:
	print("%s %s" % [PLAYER_NAMES[player_index], description])	
