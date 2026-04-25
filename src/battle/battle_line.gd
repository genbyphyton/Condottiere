class_name BattleLine
extends RefCounted

signal card_added(card: CardData)
signal card_removed(card: CardData)
signal strength_changed(new_strength: int)

var _cards: Array[CardData] = []
var _has_drummer: bool = false
var _context: BattleContext

func _init(context: BattleContext) -> void:
	_context = context
	_context.season_changed.connect(_on_season_changed)

func _on_season_changed() -> void:
	strength_changed.emit(calculate_strength())
	
func add_card(card: CardData) -> void:
	_cards.append(card)
	match card.card_type:
		CardData.CardType.WINTER:
			_context.set_winter()
		CardData.CardType.SPRING:
			_context.set_spring()
		CardData.CardType.DRUMMER:
			_has_drummer = true
	card_added.emit(card)
	strength_changed.emit(calculate_strength())
	
func remove_card(card: CardData) -> bool:
	var index := _cards.find(card)
	if index == -1:
		return false
	_cards.remove_at(index)
	card_removed.emit(card)
	strength_changed.emit(calculate_strength())
	return true

func apply_bishop(lines: Array[BattleLine]) -> void:
	var max_strength := 0
	for line in lines:
		for card in line._cards:
			if card.is_mercenary():
				max_strength = max(max_strength, card.strength)
	if max_strength == 0:
		return
	for line in lines:
		var to_remove := line._cards.filter(
			func(c: CardData) -> bool:
				return c.is_mercenary() and c.strength == max_strength
		)
		for card in to_remove:
			line.remove_card(card)
			
func apply_scarecrow(card_to_retrieve: CardData, hand: PlayerHand) -> bool:
	if card_to_retrieve == null:
		return true
	if not card_to_retrieve.is_mercenary():
		return false
	if not remove_card(card_to_retrieve):
		return false
	hand.add_card(card_to_retrieve)
	return true
	
func calculate_strength(all_lines: Array[BattleLine] = []) -> int:
	var mercenary_strength := 0
	var special_strength := 0
	
	for card in _cards:
		if card.is_mercenary():
			if _context.has_winter():
				mercenary_strength += 1
			else:
				mercenary_strength += card.strength
		elif card.is_special_unit():
			special_strength += card.strength
			
	if _has_drummer:
		mercenary_strength *= 2	
	
	if _context.has_spring() and not all_lines.is_empty():
		var global_max := 0
		for line in all_lines:
			for card in line._cards:
				if card.is_mercenary():
					global_max = max(global_max, card.strength)
		for card in _cards:
			if card.is_mercenary() and card.strength == global_max:
				mercenary_strength += 3
		
	return mercenary_strength + special_strength

func clear() -> Array[CardData]:
	var all := _cards.duplicate()
	_cards.clear()
	_has_drummer = false
	return all

func get_cards() -> Array[CardData]:
	return _cards.duplicate()

func is_empty() -> bool:
	return _cards.is_empty()

func size() -> int:
	return _cards.size()
	
func has_drummer() -> bool:
	return _has_drummer
