class_name Battle
extends RefCounted

signal battle_ended(winner_index: int)
signal turn_changed(player_index: int)
signal card_played(player_index: int, card: CardData)
signal player_passed(player_index: int)

const PLAYER_COUNT := PlayerHand.PLAYER_COUNT

var _context: BattleContext
var _lines: Array[BattleLine] = []
var _hands: Array[PlayerHand] = []
var _passed: Array[bool] = []
var _current_player: int = 0
var _deck: Deck

func _init(hands: Array[PlayerHand], deck: Deck, condottiere_player: int) -> void:
	_context = BattleContext.new()
	_hands = hands
	_deck = deck
	_current_player = condottiere_player
	_context.season_changed.connect(_on_season)
	for i in PLAYER_COUNT:
		_lines.append(BattleLine.new(_context))
		_passed.append(false)
		
func play_card(player_index: int, card: CardData) -> bool:
	if not _can_act(player_index):
		return false
	if not _hands[player_index].has_card(card):
		return false
	
	match card.card_type:
		CardData.CardType.SURRENDER:
			_hands[player_index].discard_card(card, _deck)
			_resolve_battle(true)
		CardData.CardType.BISHOP:
			_hands[player_index].play_card(card, _lines[player_index])
			_lines[player_index].apply_bishop(_lines)
			card_played.emit(player_index, card)
			_recalculate_all()
			_advance_turn()
		CardData.CardType.SCARECROW:
			_hands[player_index].play_card(card, _lines[player_index])
			card_played.emit(player_index, card)
			_advance_turn()
		_:
			_hands[player_index].play_card(card, _lines[player_index])
			card_played.emit(player_index, card)
			_recalculate_all()
			_advance_turn()
		
	return true
	
func apply_scarecrow(player_index: int, card_to_retrieve: CardData) -> bool:
	return _lines[player_index].apply_scarecrow(card_to_retrieve, _hands[player_index])
	
func pass_turn(player_index: int) -> void:
	if player_index != _current_player or _passed[player_index]:
		return
	_passed[player_index] = true
	player_passed.emit(player_index)
	if _all_passed():
		_resolve_battle(false)
	else:
		_advance_turn()
		
func _can_act(player_index: int) -> bool:
	return (
		player_index == _current_player
		and not _passed[player_index]
		and not _hands[player_index].is_empty()
	)
	
func _advance_turn() -> void:
	var next := _current_player
	for i in PLAYER_COUNT:
		next = (next + 1) % PLAYER_COUNT
		if not _passed[next] and not _hands[next].is_empty():
			_current_player = next
			turn_changed.emit(_current_player)
			return
	_resolve_battle(false)
	
func _all_passed() -> bool:
	return _passed.all(func(p: bool) -> bool: return p)
	
func _recalculate_all() -> void:
	for line in _lines:
		line.strength_changed.emit(line.calculate_strength(_lines))
		
func _resolve_battle(surrender: bool) -> void:
	var strengths: Array[int] = []
	for line in _lines:
		strengths.append(line.calculate_strength(_lines))
	
	var max_strength: int = strengths.max()
	var winners: Array[int] = []
	for i in PLAYER_COUNT:
		if strengths[i] == max_strength:
			winners.append(i)
			
	var winner_index := -1
	if winners.size() == 1:
		winner_index = winners[0]
		
	battle_ended.emit(winner_index)
	
func get_condottiere_token_receiver(winner_index: int) -> int:
	if winner_index == -1:
		return -1

	var courtesan_counts: Array[int] = []
	for line in _lines:
		var count := line.get_cards().filter(
			func(c: CardData) -> bool:
				return c.card_type == CardData.CardType.COURTESAN
		).size()
		courtesan_counts.append(count)
		
	var max_courtesans: int = courtesan_counts.max()
	if max_courtesans == 0:
		return winner_index

	var courtesan_winners: Array[int] = []
	for i in PLAYER_COUNT:
		if courtesan_counts[i] == max_courtesans:
			courtesan_winners.append(i)

	if courtesan_winners.size() > 1:
		return winner_index

	return courtesan_winners[0]
	
func end_battle() -> void:
	for line in _lines:
		var cards := line.clear()
		_deck.discard_many(cards)
	_context.reset()
	
func get_line(player_index: int) -> BattleLine:
	return _lines[player_index]
	
func get_current_player() -> int:
	return _current_player
	
func has_passed(player_index: int) -> bool:
	return _passed[player_index]
	
func get_strength(player_index: int) -> int:
	return _lines[player_index].calculate_strength(_lines)
