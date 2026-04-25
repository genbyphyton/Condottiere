class_name BattleContext
extends RefCounted

signal season_changed

var _has_winter: bool = false
var _has_spring: bool = false
var _has_autumn: bool = false

func set_winter() -> void:
	_has_winter = true
	_has_autumn = false
	season_changed.emit()
	
func set_spring() -> void:
	_has_spring = true
	_has_winter = false
	season_changed.emit()
	
func set_autumn() -> void:
	_has_autumn = true
	_has_spring = false
	season_changed.emit()
	
func has_winter() -> bool:
	return _has_winter
	
func has_spring() -> bool:
	return _has_spring
	
func has_autumn() -> bool:
	return _has_autumn
	
func reset() -> void:
	_has_winter = false
	_has_spring = false
	_has_autumn = false
