class_name RegionData

const REGIONS: Array[String] = [
	"Highlands", "Grampian", "Strathclyde", "Northumbria",
	"Yorkshire", "Mercia", "Wales", "East Anglia",
	"Somerset", "Wessex", "Essex", "Cornwall",
	"Kent", "Dunwall", "Tirconnell", "Velen"
]

const NEIGHBORS: Dictionary = {
	"Highlands":   ["Grampian", "Strathclyde"],
	"Grampian":    ["Highlands", "Strathclyde", "Dunwall"],
	"Strathclyde": ["Grampian", "Highlands", "Northumbria"],
	"Northumbria": ["Strathclyde", "Yorkshire", "Mercia"],
	"Yorkshire":   ["Northumbria", "Mercia", "East Anglia"],
	"Mercia":      ["Northumbria", "Yorkshire", "Wales", "East Anglia"],
	"Wales":       ["Mercia", "East Anglia", "Somerset", "Wessex"],
	"East Anglia": ["Yorkshire", "Mercia", "Wales", "Wessex", "Essex"],
	"Somerset":    ["Wales", "Wessex"],
	"Wessex":      ["Wales", "East Anglia", "Somerset", "Essex", "Cornwall", "Kent"],
	"Essex":       ["East Anglia", "Wessex", "Kent"],
	"Cornwall":    ["Wessex", "Kent"],
	"Kent":        ["Wessex", "Essex", "Cornwall"],
	"Dunwall":     ["Tirconnell", "Velen", "Grampian"],
	"Tirconnell":  ["Dunwall", "Velen"],
	"Velen":       ["Dunwall", "Tirconnell"],
}
