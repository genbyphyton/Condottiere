class_name Deck
extends RefCounted

signal card_drawn(card: CardData)
signal deck_empty

var _draw_pile: Array[CardData] = []
var _discard_pile: Array[CardData] = []

func _init() -> void:
	_draw_pile = DeckFactory.build()
	shuffle()
	
func shuffle() -> void:
	_draw_pile.shuffle()
	
func draw() -> CardData:
	if _draw_pile.is_empty():
		deck_empty.emit()
		return null
	var card: CardData = _draw_pile.pop_back()
	card_drawn.emit()
	return card
	
func draw_many(count: int) -> Array[CardData]:
	var result: Array[CardData] = []
	for i in count:
		if is_empty():
			break
		var card: CardData = draw()
		result.append(card)
	return result
	
func discard(card: CardData) -> void:
	_discard_pile.append(card)
	
func discard_many(cards: Array[CardData]) -> void:
	for card in cards:
		discard(card)
		
func reshuffle_discard() -> void:
	_draw_pile.append_array(_discard_pile)
	_discard_pile.clear()
	shuffle()
	
func draw_pile_size() -> int:
	return _draw_pile.size()
	
func discard_pile_size() -> int:
	return _discard_pile.size()

func is_empty() -> bool:
	return _draw_pile.is_empty()
