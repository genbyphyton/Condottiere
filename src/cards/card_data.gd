class_name CardData
extends Resource

enum CardType {
	MERCENARY,
	DRUMMER,
	COURTESAN,
	HEROINE,
	BISHOP,
	WINTER,
	SPRING,
	AUTUMN,
	SCARECROW,
	SURRENDER,
}

@export var card_type: CardType
@export var strength: int = 0
@export var display_name: String = ""

func _init(p_type: CardType = CardType.MERCENARY, p_strength: int = 0, p_name: String = "") -> void:
	card_type = p_type
	strength = p_strength
	display_name = p_name
	
func is_mercenary() -> bool:
	return card_type == CardType.MERCENARY
	
func is_special_card() -> bool:
	return card_type != CardType.MERCENARY
	
func is_special_unit() -> bool:
	return card_type in [CardType.HEROINE, CardType.COURTESAN]
