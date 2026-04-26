extends Node

signal game_over(winner_index: int)
signal battle_started(region: String)
signal region_captured(region: String, player_index: int)
signal pontiff_moved(region: String)
signal round_ended
signal round_end_discard_requested(player_index: int, cards: Array[CardData])
signal hand_sizes_updated

const PLAYER_COUNT := PlayerHand.PLAYER_COUNT
const WIN_REGIONS_ANY := 5
const WIN_REGIONS_ADJACENT := 3

var _deck: Deck
var _hands: Array[PlayerHand] = []
var _factions: Array[Faction] = []
var _region_owners: Dictionary = {}
var _pontiff_region: String = ""
var _condottiere_player: int = 0
var _current_battle: Battle = null
var _current_region: String = ""
var _game_over: bool = false
var _waiting_for_discard: bool = false
var _last_winner: int = -1


func _ready() -> void:
	_init_regions()

func _init_regions() -> void:
	for region in RegionData.REGIONS:
		_region_owners[region] = -1
		
func start_game(factions: Array[Faction]) -> void:
	_factions = factions
	_deck = Deck.new()
	_hands.clear()
	for i in PLAYER_COUNT:
		var hand := PlayerHand.new()
		_hands.append(hand)
	_deal_initial_hands()
	_condottiere_player = 0
	
func _deal_initial_hands() -> void:
	print("Dealing hands")
	for i in PLAYER_COUNT:
		_hands[i].discard_all(_deck)
		var regions_owned := _count_owned(i)
		var card_count := PlayerHand.BASE_HAND_SIZE + regions_owned
		print("P%d gets %d cards, hand before: %d" % [i, card_count, _hands[i].size()])
		_hands[i].add_cards(_deck.draw_many(card_count))
		print("P%d hand after: %d" % [i, _hands[i].size()])
		var faction := _factions[i] if i < _factions.size() else null
		if faction != null and faction.is_wales() and faction.has_saved_card():
			_hands[i].add_card(faction.take_saved_card())
			
func start_battle(region: String) -> bool:
	print("start_battle: game_over=", _game_over, " waiting=", _waiting_for_discard, " battle=", _current_battle)
	if _game_over or _waiting_for_discard:
		return false
	if _current_battle != null:
		push_error("Battle already in progress!")
		return false
	print("Hands sizes: ")
	for i in PLAYER_COUNT:
		print("  P%d: %d cards" % [i, _hands[i].size()])
	if _game_over:
		return false
	if not _can_battle(region):
		return false
	_current_region = region
	_current_battle = Battle.new(_hands, _deck, _condottiere_player, _factions)
	_current_battle.battle_ended.connect(_on_battle_ended)
	_current_battle.bishop_played.connect(_on_bishop_played)
	_current_battle.wales_pick_card.connect(_on_wales_pick_card)
	for faction in _factions:
		faction.reset()
	battle_started.emit(region)
	return true
	
func _can_battle(region: String) -> bool:
	if not region in RegionData.REGIONS:
		return false
	if _pontiff_region == region:
		return false
	return true
	
func get_battle() -> Battle:
	return _current_battle
	
func _on_battle_ended(winner_index: int) -> void:
	if _current_battle == null:
		return
	if winner_index != -1:
		_region_owners[_current_region] = winner_index
		region_captured.emit(_current_region, winner_index)
		
	var token_receiver := -1
	if winner_index != -1:
		token_receiver = _current_battle.get_condottiere_token_receiver(winner_index)
	else:
		token_receiver = (_condottiere_player + 1) % PLAYER_COUNT
	_condottiere_player = token_receiver
	
	_current_battle.end_battle()
	_current_battle = null
	
	if winner_index != -1 and _check_win(winner_index):
		_game_over = true
		_last_winner = winner_index
		game_over.emit(winner_index)
		return
		
	_check_round_end()
		
func _check_round_end() -> void:
	print("Check round end")
	var player_with_card := 0
	var last_player := -1
	for i in PLAYER_COUNT:
		print("P%d hand: %d" % [i, _hands[i].size()])
		if not _hands[i].is_empty():
			player_with_card += 1
			last_player = i
	print("Players with cards: ", player_with_card)
	
	if _hands[0].is_empty():
		_finish_round()
		return
	
	if player_with_card == 0:
		_finish_round()
	elif player_with_card <= 1:
		if last_player != -1 and _hands[last_player].size() > 2:
			_waiting_for_discard = true
			round_end_discard_requested.emit(last_player, _hands[last_player].get_cards())
			return
		_finish_round()
		
func confirm_round_end_discard(player_index: int, cards_to_keep: Array[CardData]) -> void:
	if not _waiting_for_discard:
		return
	_waiting_for_discard = false
	var all_cards := _hands[player_index].get_cards()
	for card in all_cards:
		if not cards_to_keep.has(card):
			_hands[player_index].discard_card(card, _deck)
	_finish_round()
	
func _finish_round() -> void:
	_deck.reshuffle_discard()
	_deal_initial_hands()
	round_ended.emit()
	hand_sizes_updated.emit()

func _on_bishop_played(player_index: int) -> void:
	pass

func set_pontiff_region(region: String) -> void:
	if region == "" or not region in RegionData.REGIONS:
		_pontiff_region = ""
	elif _region_owners[region] == -1:
		_pontiff_region = region
	else:
		_pontiff_region = ""
	pontiff_moved.emit(_pontiff_region)

func get_pontiff_region() -> String:
	return _pontiff_region

func _on_wales_pick_card(player_index: int, available_cards: Array[CardData]) -> void:
	pass

func wales_confirm_card(player_index: int, card: CardData) -> void:
	if _current_battle != null:
		_current_battle.wales_save_card(player_index, card)

func _check_win(player_index: int) -> bool:
	if _count_owned(player_index) >= WIN_REGIONS_ANY:
		return true
	if _count_adjacent(player_index) >= WIN_REGIONS_ADJACENT:
		return true
	return false

func _count_owned(player_index: int) -> int:
	var count := 0
	for region in _region_owners:
		if _region_owners[region] == player_index:
			count += 1
	return count

func _count_adjacent(player_index: int) -> int:
	var visited: Dictionary = {}
	var max_connected := 0
	for region in _region_owners:
		if _region_owners[region] == player_index and not visited.has(region):
			var connected := _flood_fill(region, player_index, visited)
			max_connected = max(max_connected, connected)
	return max_connected

func _flood_fill(region: String, player_index: int, visited: Dictionary) -> int:
	if visited.has(region):
		return 0
	if _region_owners[region] != player_index:
		return 0
	visited[region] = true
	var count := 1
	for neighbor in RegionData.NEIGHBORS[region]:
		count += _flood_fill(neighbor, player_index, visited)
	return count

func get_region_owner(region: String) -> int:
	return _region_owners.get(region, -1)

func get_hand(player_index: int) -> PlayerHand:
	return _hands[player_index]

func get_faction(player_index: int) -> Faction:
	return _factions[player_index] if player_index < _factions.size() else null

func get_condottiere_player() -> int:
	return _condottiere_player
	
func get_last_winner() -> int:
	return _last_winner

func is_game_over() -> bool:
	return _game_over

func can_attack(region: String) -> bool:
	return _can_battle(region)
