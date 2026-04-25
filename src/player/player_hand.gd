class_name PlayerHand
extends RefCounted

signal card_added(card: CardData)
signal card_played(card: CardData)
signal card_discarded(card: CardData)

const BASE_HAND_SIZE := 10
const PLAYER_COUNT := 4

var max_hand_size := BASE_HAND_SIZE

func set_regions_controlled(count: int) -> void:
	max_hand_size = BASE_HAND_SIZE + count

var _cards: Array[CardData] = []

func add_card(card: CardData) -> void:
	_cards.append(card)
	card_added.emit(card)
	
func add_cards(cards: Array[CardData]) -> void:
	for card in cards:
		add_card(card)
		
func play_card(card: CardData, battle_line: BattleLine) -> bool:
	var index := _cards.find(card)
	if index == -1:
		return false
	_cards.remove_at(index)
	battle_line.add_card(card)
	card_played.emit(card)
	return true
	
func play_card_at(index: int, battle_line: BattleLine) -> bool:
	if index < 0 or index > _cards.size():
		return false
	return play_card(_cards[index], battle_line)
	
func discard_card(card: CardData, deck: Deck) -> bool:
	var index := _cards.find(card)
	if index == -1:
		return false
	_cards.remove_at(index)
	deck.discard(card)
	card_discarded.emit(card)
	return true
	
func discard_all(deck: Deck) -> void:
	for card in _cards.duplicate():
		discard_card(card, deck)
		
func get_cards() -> Array[CardData]:
	return _cards.duplicate()

func size() -> int:
	return _cards.size()

func is_empty() -> bool:
	return _cards.is_empty()

func is_full() -> bool:
	return _cards.size() >= max_hand_size

func has_card(card: CardData) -> bool:
	return _cards.has(card)

func get_by_type(type: CardData.CardType) -> Array[CardData]:
	return _cards.filter(func(c: CardData) -> bool: return c.card_type == type)

func has_any_mercenary() -> bool:
	return not get_by_type(CardData.CardType.MERCENARY).is_empty()
