extends Control

class_name UIMenu

export(bool) var vertical = true
export(NodePath) var parent_menu = null
export(bool) var hide_parent_menu = true
export(NodePath) var return_item = null

var first_item = null

signal custom_close(menu)

func _ready():
	focus_mode = Control.FOCUS_NONE
	
	connect("visibility_changed", self, "visible_changed")
	
	if return_item:
		get_node(return_item).connect("action", self, "self_close")
	
	var items = []
	
	for item in get_children():
		if item is UIMenuItem and item.visible:
			items.append(item)
	
	var item_count = items.size()
	
	if item_count > 0:
		first_item = items[0]

		if item_count > 1:
			for i in item_count:
				var item = items[i] as UIMenuItem
				
				var prev_item = null
				var next_item = null
				
				if i == 0:
					prev_item = items.back()
				else:
					prev_item = items[i - 1]
				
				if i == item_count - 1:
					next_item = items.front()
				else:
					next_item = items[i + 1]
				
				if vertical:
					item.focus_neighbour_top = prev_item.get_path()
					item.focus_neighbour_bottom = next_item.get_path()
				else:
					item.focus_neighbour_left = prev_item.get_path()
					item.focus_neighbour_right = next_item.get_path()
				
				item.focus_previous = prev_item.get_path()
				item.focus_next = next_item.get_path()

func self_close():
	if get_signal_connection_list("custom_close"):
		emit_signal("custom_close", self)
	else:
		hide()

func set_focus():
	if first_item:
		first_item.grab_focus()

func _input(event):
	if visible and parent_menu and event.is_action_pressed("ui_cancel"):
		self_close()
		
func visible_changed():
	if visible:
		if hide_parent_menu and parent_menu:
			get_node(parent_menu).hide()
		
		set_focus()
	else:
		if parent_menu:
			var menu = get_node(parent_menu)
			
			if hide_parent_menu:
				menu.show()
				
			menu.set_focus()
