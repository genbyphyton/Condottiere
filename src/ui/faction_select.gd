extends Control

const FACTION_DATA := [
	{"name": "Scotland", "type": Faction.FactionType.SCOTLAND, "icon": "res://assets/covenant.png"},
	{"name": "Wales",    "type": Faction.FactionType.WALES,    "icon": "res://assets/crown.png"},
	{"name": "Ireland",  "type": Faction.FactionType.IRELAND,  "icon": "res://assets/harp.png"},
	{"name": "England",  "type": Faction.FactionType.ENGLAND,  "icon": "res://assets/cross.png"},
]

var _selected: Faction.FactionType = Faction.FactionType.SCOTLAND

func _ready() -> void:
	find_child("ButtonConfirm", true, false).disabled = true
	var btn_scotland := find_child("FactionButton_Scotland", true, false) as Button
	var btn_wales := find_child("FactionButton_Wales", true, false) as Button
	var btn_ireland := find_child("FactionButton_Ireland", true, false) as Button
	var btn_england := find_child("FactionButton_England", true, false) as Button
	var btn_confirm := find_child("ButtonConfirm", true, false) as Button
	
	print("Scotland btn: ", btn_scotland)
	print("Confirm btn: ", btn_confirm)
	
	if btn_scotland: btn_scotland.pressed.connect(func(): _select(Faction.FactionType.SCOTLAND))
	if btn_wales: btn_wales.pressed.connect(func(): _select(Faction.FactionType.WALES))
	if btn_ireland: btn_ireland.pressed.connect(func(): _select(Faction.FactionType.IRELAND))
	if btn_england: btn_england.pressed.connect(func(): _select(Faction.FactionType.ENGLAND))
	if btn_confirm: btn_confirm.pressed.connect(_on_confirm)

func _select(type: Faction.FactionType) -> void:
	_selected = type
	find_child("ButtonConfirm", true, false).disabled = false
	var name_str := Faction.new(type).get_display_name()
	find_child("LabelSelected", true, false).text = "Selected: %s" % name_str

func _on_confirm() -> void:
	var all_types := [
		Faction.FactionType.SCOTLAND,
		Faction.FactionType.WALES,
		Faction.FactionType.IRELAND,
		Faction.FactionType.ENGLAND,
	]
	for i in all_types.size():
		if all_types[i] == _selected:
			all_types.remove_at(i)
			break
	all_types.shuffle()

	var factions: Array[Faction] = []
	factions.append(Faction.new(_selected))
	for type in all_types:
		factions.append(Faction.new(type))
		
	print("Factions: ")
	for f in factions:
		print("  ", f.get_display_name())
		
	GameState.start_game(factions)
	get_tree().change_scene_to_file("res://scenes/map.tscn")
