tool
extends Container

class_name UIMenuItem

export(String) var title setget set_title, get_title
export(NodePath) var slot
export(bool) var click_confirm

onready var label_color = $ui_label.modulate
onready var rect_color = $ui_rect.color

signal action

func set_title(value):
	$ui_label.text = value

func get_title():
	return $ui_label.text

func exec_action():
	if slot:
		slot_change(false)
	else:
		if click_confirm:
			$anim.play("focus_enter")
			
		$snd_click.play()
		emit_signal("action")
		
func slot_change(to_low):
	if slot:
		var slot_node = get_node(slot)
		
		if to_low:
			slot_node.low()
		else:
			slot_node.high()
		
		$anim.play("focus_enter")
	
func _on_menu_item_input(event):
	if event is InputEventMouseMotion:
		if get_focus_owner() != self:
			grab_focus()
	
	if get_focus_owner() == self:
		if event.is_action_pressed("ui_accept"):
			exec_action()
		elif event.is_action_pressed("ui_left"):
			slot_change(true)
		elif event.is_action_pressed("ui_right"):
			slot_change(false)

func _on_menu_item_focus_entered():
	$anim.play("focus_enter")

func _on_menu_item_focus_exited():
	$anim.play("focus_exit")
