tool
extends "res://scripts/ui/ui_slot_base.gd"

export (String) var text setget set_text, get_text
export (Color) var frontcolor setget set_frontcolor, get_frontcolor

func set_text(value):
	text = value
	
	if has_node("ui_label"):
		$ui_label.text = text

func get_text():
	return $ui_label.text

func set_frontcolor(value):
	frontcolor = value
	
	if has_node("ui_label"):
		$ui_label.modulate = frontcolor

func get_frontcolor():
	return $ui_label.modulate

func low():
	pass

func high():
	pass
