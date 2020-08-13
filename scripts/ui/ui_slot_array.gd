tool
extends "res://scripts/ui/ui_slot_base.gd"

export(Color) var frontcolor setget set_frontcolor, get_frontcolor
export(int) var data_index setget set_data_index
export(Array, String) var data
export(bool) var cycle

func _ready():
	$ui_label.text = tr(data[data_index])

func set_frontcolor(value):
	frontcolor = value
	
	if has_node("ui_label"):
		$ui_label.modulate = frontcolor

func get_frontcolor():
	return $ui_label.modulate

func set_data_index(value):
	if value >= 0 and value < data.size():
		data_index = value
		$ui_label.text = tr(data[data_index])
		$anim.play("change")

func low():
	if self.data_index > 0:
		self.data_index -= 1
	elif cycle:
		self.data_index = data.size() - 1

func high():
	if self.data_index < data.size() - 1:
		self.data_index += 1
	elif cycle:
		self.data_index = 0

func checked():
	return data_index > 0
