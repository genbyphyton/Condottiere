class_name MapController
extends Node2D

const PLAYER_COLORS: Array[Color] = [
	Color(0.2, 0.5, 1.0, 0.45),
	Color(0.816, 0.0, 0.031, 0.451),
	Color(0.2, 0.8, 0.2, 0.45),
	Color(0.91, 0.961, 0.102, 0.451),
]
const PONTIFF_COLOR := Color(1.0, 1.0, 1.0, 0.6)
const NEUTRAL_COLOR := Color(0.3, 0.3, 0.3, 0.5)

signal region_clicked(region_name: String)

var _polygons: Dictionary = {}
var _selected_region_name: String = ""

@onready var map_ui: MapUI = $"../UILayer/UI"

func _ready() -> void:
	MusicController.first_play()
	_create_visual_polygons()
	GameState.region_captured.connect(_on_region_captured)
	GameState.pontiff_moved.connect(_on_pontiff_moved)
	region_clicked.connect(_on_region_clicked)
	for region in RegionData.REGIONS:
		var owner := GameState.get_region_owner(region)
		if owner != -1:
			highlight_region(region, owner)
	var pontiff := GameState.get_pontiff_region()
	if pontiff != "":
		show_pontiff(pontiff)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return

	var mouse_pos := get_global_mouse_position()
	for region_name in RegionData.REGIONS:
		var area := get_node_or_null(region_name) as Area2D
		if area == null:
			continue
		var collision := area.get_node_or_null(region_name) as CollisionPolygon2D
		if collision == null:
			continue
		var local_pos := collision.to_local(mouse_pos)
		if Geometry2D.is_point_in_polygon(local_pos, collision.polygon):
			region_clicked.emit(region_name)
			return

func _create_visual_polygons() -> void:
	for region_name in RegionData.REGIONS:
		var area := get_node_or_null(region_name) as Area2D
		if area == null:
			continue
		var collision := area.get_node_or_null(region_name)
		if collision == null:
			continue
		var poly := Polygon2D.new()
		poly.name = "Polygon2D"
		poly.polygon = collision.polygon
		poly.color = NEUTRAL_COLOR
		area.add_child(poly)
		_polygons[region_name] = poly

func _on_area_2d_input_event(_viewport, event, _shape_idx, region_name: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		region_clicked.emit(region_name)

func highlight_region(region_name: String, player_index: int) -> void:
	var polygon := _get_polygon(region_name)
	if polygon == null:
		return
	var target_color := PLAYER_COLORS[player_index] if player_index >= 0 else NEUTRAL_COLOR
	_animate_color(polygon, target_color)

func show_pontiff(region_name: String) -> void:
	var polygon := _get_polygon(region_name)
	if polygon == null:
		return
	_animate_color(polygon, PONTIFF_COLOR)

func clear_pontiff(region_name: String) -> void:
	var owner := GameState.get_region_owner(region_name)
	highlight_region(region_name, owner)

func _on_region_captured(region_name: String, player_index: int) -> void:
	highlight_region(region_name, player_index)

func _on_region_clicked(region_name: String) -> void:
	if _selected_region_name != "":
		var prev := _get_polygon(_selected_region_name)
		if prev != null:
			var owner := GameState.get_region_owner(_selected_region_name)
			if owner != -1:
				_animate_color(prev, PLAYER_COLORS[owner])
			else:
				_animate_color(prev, NEUTRAL_COLOR)
	_selected_region_name = region_name
	var poly := _get_polygon(region_name)
	if poly != null:
		_animate_color(poly, Color(0.0, 0.418, 0.117, 0.6))
	map_ui.set_selected_region(region_name)

func _on_pontiff_moved(region_name: String) -> void:
	if region_name == "":
		return
	show_pontiff(region_name)

func _get_polygon(region_name: String) -> Polygon2D:
	return _polygons.get(region_name, null)

func _animate_color(polygon: Polygon2D, target_color: Color) -> void:
	polygon.color = Color(target_color.r, target_color.g, target_color.b, 0.0)
	var tween := create_tween()
	tween.tween_property(polygon, "color:a", target_color.a, 1.2)
