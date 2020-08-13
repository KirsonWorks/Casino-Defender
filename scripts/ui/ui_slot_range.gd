tool
extends "res://scripts/ui/ui_slot_base.gd"

export(int) var minimum setget set_minimum
export(int) var maximum setget set_maximum
export(float) var value setget set_value, get_value
export(float) var step setget set_step

var as_int setget ,get_as_int

func _ready():
	pass

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		var width = get_rect().size.x
		self.value = event.position.x / width * 100.0

func set_minimum(value):
	minimum = value
	
	if has_node("ui_progress"):
		$ui_progress.min_value = minimum
	
func set_maximum(value):
	maximum = value
	
	if has_node("ui_progress"):
		$ui_progress.max_value = maximum
	
func set_value(val):
	value = val

	if has_node("ui_progress"):
		$ui_progress.value = value
	
func get_value():
	return $ui_progress.value
	
func set_step(value):
	step = clamp(value, 1, maximum - minimum)
	
	if has_node("ui_progress"):
		$ui_progress.step = step

func low():
	if self.value > minimum:
		self.value -= step

func high():
	if self.value < maximum:
		self.value += step

func get_as_int():
	return int(self.value)
