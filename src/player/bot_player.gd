class_name BotPlayer
extends RefCounted

signal action_taken(player_index: int, description: String)

var _player_index: int
var _battle: Battle
var _hand: PlayerHand

func _init(player_index: int, battle: Battle, hand: PlayerHand) -> void:
	_player_index = player_index
	_battle = battle
	_hand = hand
	
func take_turn() -> void:
	var cards := _hand.get_cards()
	if cards.is_empty():
		action_taken.emit(_player_index, "passes (no cards)")
		_battle.pass_turn(_player_index)
		return
		
	var my_strength := _battle.get_strength(_player_index)
	var max_enemy_strength := _get_max_enemy_strength()
	
	if my_strength > max_enemy_strength + 5 and my_strength > 0:
		action_taken.emit(_player_index, "passes (winning)")
		_battle.pass_turn(_player_index)
		return
		
	var card := pick_card(my_strength, max_enemy_strength)
	if card == null:
		action_taken.emit(_player_index, "passes (no good card)")
		_battle.pass_turn(_player_index)
		return
		
	match card.card_type:
		CardData.CardType.SCARECROW:
			action_taken.emit(_player_index, "plays: %s" % card.display_name)
			_battle.play_card(_player_index, card)
			_handle_scarecrow()
		CardData.CardType.BISHOP:
			if _should_play_bishop(_get_all_lines()):
				action_taken.emit(_player_index, "plays: %s" % card.display_name)
				_battle.play_card(_player_index, card)
			else:
				action_taken.emit(_player_index, "passes (bishop not useful)")
				_battle.pass_turn(_player_index)
		_:
			action_taken.emit(_player_index, "plays: %s" % card.display_name)
			_battle.play_card(_player_index, card)
	
func pick_card(my_strength: int, max_enemy_strength: int) -> CardData:
	var cards := _hand.get_cards()
	var gap := max_enemy_strength - my_strength
	
	for card in cards:
		if card.card_type == CardData.CardType.SURRENDER:
			if my_strength > max_enemy_strength:
				return card
	
	if gap >= 0:
		for card in cards:
			match card.card_type:
				CardData.CardType.WINTER:
					if _should_play_winter():
						return card
				CardData.CardType.DRUMMER:
					if _has_mercenaries_in_line() and not _battle.get_line(_player_index).has_drummer():
						return card
				CardData.CardType.SPRING:
					if _has_highest_mercenary() and not _battle.has_spring():
						return card
				CardData.CardType.HEROINE:
					if gap > 0:
						return card
						
		var best: CardData = null
		for card in cards:
			if card.is_mercenary():
				if best == null or card.strength > best.strength:
					best = card
		if best != null and best.strength >= gap:
			return best
			
		for card in cards:
			if card.card_type == CardData.CardType.COURTESAN:
				if _should_play_courtesan():
					return card
		return best
	
	var weakest: CardData = null
	for card in cards:
		if card.is_mercenary():
			if weakest == null or card.strength < weakest.strength:
				weakest = card
	return weakest
					
func _has_mercenaries_in_line() -> bool:
	return _battle.get_line(_player_index).get_cards().any(
		func(c: CardData) -> bool: return c.is_mercenary()
	)
	
func _has_highest_mercenary() -> bool:
	var my_max := 0
	var global_max := 0
	for i in PlayerHand.PLAYER_COUNT:
		for card in _battle.get_line(i).get_cards():
			if card.is_mercenary():
				global_max = max(global_max, card.strength)
				if i == _player_index:
					my_max = max(my_max, card.strength)
	return my_max == global_max and my_max > 0

func _handle_scarecrow() -> void:
	var line_cards := _battle.get_line(_player_index).get_cards().filter(
		func(c: CardData) -> bool: return c.is_mercenary()
	)
	if line_cards.is_empty():
		_battle.apply_scarecrow(_player_index, null)
		return
	var strongest: CardData = null
	for card in line_cards:
		if strongest == null or card.strength > strongest.strength:
			strongest = card
	_battle.apply_scarecrow(_player_index, strongest)
	
func _should_play_bishop(lines: Array[BattleLine]) -> bool:
	var max_strength := 0
	var max_owner := -1
	for i in lines.size():
		for card in lines[i].get_cards():
			if card.is_mercenary() and card.strength > max_strength:
				max_strength = card.strength
				max_owner = i
	return max_owner != _player_index and max_strength > 0
	
func _get_max_enemy_strength() -> int:
	var max_strength := 0
	for i in PlayerHand.PLAYER_COUNT:
		if i != _player_index:
			max_strength = max(max_strength, _battle.get_strength(i))
	return max_strength

func _get_all_lines() -> Array[BattleLine]:
	var lines: Array[BattleLine] = []
	for i in PlayerHand.PLAYER_COUNT:
		lines.append(_battle.get_line(i))
	return lines
	
func _should_play_courtesan() -> bool:
	var my_count := _battle.get_line(_player_index).get_cards().filter(
		func(c: CardData) -> bool: return c.card_type == CardData.CardType.COURTESAN
	).size()
	my_count += 1
	var max_enemy_count := 0
	for i in PlayerHand.PLAYER_COUNT:
		if i != _player_index:
			var count := _battle.get_line(i).get_cards().filter(
				func(c: CardData) -> bool: return c.card_type == CardData.CardType.COURTESAN
			).size()
			max_enemy_count = max(max_enemy_count, count)
	return my_count > max_enemy_count

func _should_play_winter() -> bool:
	var my_mercenary_count := _battle.get_line(_player_index).get_cards().filter(
		func(c: CardData) -> bool: return c.is_mercenary()
	).size()
	var enemy_mercenary_count := 0
	for i in PlayerHand.PLAYER_COUNT:
		if i != _player_index:
			enemy_mercenary_count += _battle.get_line(i).get_cards().filter(
				func(c: CardData) -> bool: return c.is_mercenary()
			).size()
	var max_enemy := _get_max_enemy_strength()
	return max_enemy > 10 and not _battle.has_winter() and enemy_mercenary_count > my_mercenary_count
