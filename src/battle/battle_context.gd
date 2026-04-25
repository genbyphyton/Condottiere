class_name BattleContext
extends RefCounted

signal season_changed

var _has_winter: bool = false
var _has_spring: bool = false

func set_winter(active: bool = true) -> void:
	_has_winter = active
	_has_spring = false if active else _has_spring
	season_changed.emit()
	
func set_spring(active: bool = true) -> void:
	_has_spring = active
	_has_winter = false if active else _has_winter
	season_changed.emit()
	
func has_winter() -> bool:
	return _has_winter
	
func has_spring() -> bool:
	return _has_spring
	
func reset() -> void:
	_has_winter = false
	_has_spring = false
	season_changed.emit()
