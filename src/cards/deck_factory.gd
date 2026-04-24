class_name DeckFactory

const  MERCENARY_COUNTS: Dictionary = {
	1: 10,
	2: 8,
	3: 8,
	4: 8,
	5: 8,
	6: 8,
	10: 8,
}

const SPECIAL_COUNTS: Dictionary = {
	CardData.CardType.WINTER: 3,
	CardData.CardType.SPRING: 3,
	CardData.CardType.HEROINE: 3,
	CardData.CardType.SURRENDER: 3,
	CardData.CardType.BISHOP: 6,
	CardData.CardType.DRUMMER: 6,
	CardData.CardType.COURTESAN: 12,
	CardData.CardType.SCARECROW: 16,
}

static func build() -> Array[CardData]:
	var deck: Array[CardData] = []
	
	for strength in MERCENARY_COUNTS:
		var count: int = MERCENARY_COUNTS[strength]
		for i in count:
			deck.append(CardData.new(
				CardData.CardType.MERCENARY,
				strength,
				"Mercenary %d" % strength
			))
		
	var names: Dictionary = {
		CardData.CardType.WINTER: "Winter",
		CardData.CardType.SPRING: "Spring",
		CardData.CardType.HEROINE: "Heroine",
		CardData.CardType.SURRENDER: "Scarecrow",
		CardData.CardType.BISHOP: "Bishop",
		CardData.CardType.DRUMMER: "Drummer",
		CardData.CardType.COURTESAN: "Courtesan",
		CardData.CardType.SCARECROW: "Scarecrow",
	}
	
	for type in SPECIAL_COUNTS:
		var count: int = SPECIAL_COUNTS[type]
		for i in count:
			deck.append(CardData.new(
				type,
				0,
				names[type]
			))
			
	return deck
