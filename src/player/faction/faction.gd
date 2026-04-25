class_name Faction
extends RefCounted

enum FactionType {
	SCOTLAND,
	WALES,
	IRELAND,
	ENGLAND,
}

var type: FactionType
var _ability_used: bool = false
var _saved_card: CardData = null

func _init(p_type: FactionType) -> void:
	type = p_type
	
func reset() -> void:
	_ability_used = false
	
func can_use_ability() -> bool:
	if is_scotland():
		return true
	return not _ability_used
	
func mark_ability_used() -> void:
	_ability_used = true

#for Wales
func save_card(card: CardData) -> void:
	_saved_card = card
	
func take_saved_card() -> CardData:
	var card := _saved_card
	_saved_card = null
	return card
	
func has_saved_card() -> bool:
	return _saved_card != null
	
func is_scotland() -> bool:
	return type == FactionType.SCOTLAND
	
func is_wales() -> bool:
	return type == FactionType.WALES
	
func is_ireland() -> bool:
	return type == FactionType.IRELAND
	
func is_england() -> bool:
	return type == FactionType.ENGLAND
	
func get_display_name() -> String:
	match type:
		FactionType.SCOTLAND: return "Scotland"
		FactionType.WALES:    return "Wales"
		FactionType.IRELAND:  return "Ireland"
		FactionType.ENGLAND:  return "England"
	return ""
	
func get_ability_description() -> String:
	match type:
		FactionType.SCOTLAND: return "+1 to each Mercenary (applied before all other effects)"
		FactionType.WALES:    return "After battle: take one card from the battlefield into next round"
		FactionType.IRELAND:  return "Once per round: take any card from enemy line, give one from hand"
		FactionType.ENGLAND:  return "Mercenaries are placed face down until Counting Phase"
	return ""
