tool
extends Control

class_name UISlot

export (Color) var backcolor setget set_backcolor, get_backcolor
export (bool) var updownAtClick = false

func set_backcolor(value):
	backcolor = value
	$ui_rect.color = value

func get_backcolor():
	return $ui_rect.color

func _gui_input(event):
	if event is InputEventMouseMotion:
		return

	var mouse_left_pressed = updownAtClick and event.is_action_pressed("mouse_left_button");
	var mouse_right_pressed = updownAtClick and event.is_action_pressed("mouse_right_button");
	
	if event.is_action_pressed("ui_left") or mouse_left_pressed:
		low()
		
	if event.is_action_pressed("ui_right") or mouse_right_pressed:
		high()

func low():
	pass

func high():
	pass
