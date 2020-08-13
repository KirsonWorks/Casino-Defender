extends "res://scripts/scene_base.gd"

const BLURRING_INTENSITY = 1.5

onready var battle_area = get_node("3d/vp/battle_area")
onready var button_turret1 = $ui/layout/turret_panel/hb/btn_turret1
onready var button_turret2 = $ui/layout/turret_panel/hb/btn_turret2
onready var button_turret3 = $ui/layout/turret_panel/hb/btn_turret3
onready var buttons_turret = [button_turret1, button_turret2, button_turret3]

var paused = false
var blocked_toggle = false

func _ready():
	randomize()
	get_node("3d/vp").size = global.get_resolution()
	
func _process(delta):
	if not leaving_scene and Input.is_action_just_released("ui_cancel"):
		show_exit_menu()

func _input(event):
	get_viewport().unhandled_input(event)

func show_exit_menu():
	if not $confirm/menu_exit.visible and not $confirm/menu_game_over.visible:
		$confirm/menu_exit.show()
		set_pause(true)

func set_pause(paused):
	self.paused = paused
	$post_effect.enabled(paused)
	$post_effect.blur(BLURRING_INTENSITY if paused else 0.0)
	get_tree().paused = paused

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		get_tree().paused = true
	
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		if not paused:
			get_tree().paused = false
	 
func _on_game_over_no_action():
	$confirm/menu_game_over.hide()
	set_pause(false)
	change_scene("res://scenes/game/scene_menu.tscn")

func _on_game_over_yes_action():
	set_pause(false)
	get_tree().reload_current_scene()

func _on_menu_exit_no_action():
	$confirm/menu_exit.hide()
	set_pause(false)

func _on_exit_menu_yes_action():
	$confirm/menu_exit.hide()
	set_pause(false)
	change_scene("res://scenes/game/scene_menu.tscn")
	
func button_disable(button, flag):
	button.disabled = flag
	
	if flag:
		button.pressed = false

func _on_change_money(value):
	$ui/layout/cash.text = str(value)
	
	var area = get_node("3d/vp/battle_area")
	button_disable($ui/layout/turret_panel/hb/btn_turret1, !area.can_build_turret(area.TURRET_TYPE_GUN))
	button_disable($ui/layout/turret_panel/hb/btn_turret2, !area.can_build_turret(area.TURRET_TYPE_FLAME))
	button_disable($ui/layout/turret_panel/hb/btn_turret3, !area.can_build_turret(area.TURRET_TYPE_ROCKET))
	$ui/layout/turret_panel/hb/btn_upgrade.disabled = !area.can_upgrade_turret()

func _on_change_health(value):
	$ui/layout/health.text = str(value)

func _on_change_wave(value):
	$ui/layout/waves.text = str(value)
	
func battle_end_wave():
	if battle_area.health > 0:
		$ui/layout/control_panel/btn_play.disabled = false
	else:
		$confirm/menu_game_over.show()
		set_pause(true)

func show_info_panel(text):
	$ui/layout/info_panel/label.text = text
	$ui/layout/info_panel.show()

func get_info_text(cost, radius, damage, speed):
	var text = "%s: %d\r\n%s: %0.1f\r\n%s: %0.1f\r\n%s: %0.1f\r\n"
	return text % [tr("PRICE"), cost, tr("RADIUS"), radius, tr("DAMAGE"), damage,
		tr("FIRERATE"), speed]
	
func show_turret_info_panel(type):
	var info = battle_area.get_turret_buy_info(type)
	var text = get_info_text(int(info.cost), info.radius, info.damage, info.speed)
	show_info_panel(text)

func turret_prebuild(type):
	blocked_toggle = false
	var prebuild_type = battle_area.turret_prebuild_type
	
	battle_area.turret_prebuild(type)
	
	if prebuild_type > 0 and prebuild_type != type:
		blocked_toggle = true
		buttons_turret[prebuild_type - 1].pressed = false

func turret_prebuild_toggle(type, on):
	if on:
		turret_prebuild(type)
	else:
		if not blocked_toggle:
			turret_prebuild(battle_area.TURRET_TYPE_NONE)

func _on_battle_area_change_tool_mode():
	if battle_area.tool_mode == battle_area.TOOL_MODE_NONE:
		turret_prebuild(battle_area.TURRET_TYPE_NONE)
	elif battle_area.tool_mode == battle_area.TOOL_MODE_DETAILS:
		blocked_toggle = true
		
		for btn in buttons_turret:
			btn.pressed = false
			
func _on_btn_turret1_toggled(button_pressed):
	turret_prebuild_toggle(battle_area.TURRET_TYPE_GUN, button_pressed)
	
func _on_btn_turret2_toggled(button_pressed):
	turret_prebuild_toggle(battle_area.TURRET_TYPE_FLAME, button_pressed)

func _on_btn_turret3_toggled(button_pressed):
	turret_prebuild_toggle(battle_area.TURRET_TYPE_ROCKET, button_pressed)
	
func _on_btn_upgrade_up():
	battle_area.turret_upgrade()
	_on_btn_upgrade_mouse_entered()

func _on_btn_delete_up():
	battle_area.turret_delete()
	$ui/layout/info_panel.hide()

func _on_btn_mouse_entered():
	battle_area.click_locked = true

func _on_btn_mouse_exited():
	$ui/layout/info_panel.hide()
	battle_area.click_locked = false

func _on_btn_play_up():
	battle_area.next_wave()
	$anim.play("start_wave")
	$ui/layout/control_panel/btn_play.disabled = true
	
func _on_battle_area_end_wave():
	$anim.play("end_wave")

func _on_btn_turret1_mouse_entered():
	show_turret_info_panel(battle_area.TURRET_TYPE_GUN)

func _on_btn_turret2_mouse_entered():
	show_turret_info_panel(battle_area.TURRET_TYPE_FLAME)

func _on_btn_turret3_mouse_entered():
	show_turret_info_panel(battle_area.TURRET_TYPE_ROCKET)

func _on_btn_upgrade_mouse_entered():
	var info = battle_area.get_selected_turret_upgrade_info()
	
	if info:
		var text = get_info_text(int(info.upgrade_cost), info.radius, info.damage, info.speed)
		show_info_panel(text)
	else:
		$ui/layout/info_panel.hide()

func _on_btn_delete_mouse_entered():
	var info = battle_area.get_selected_turret_delete_info()
	
	if info:
		var text = "%s: %d" % [tr("SELL_FOR"), int(info.refund)]
		show_info_panel(text)

func _on_battle_area_change_selected_turret():
	$ui/layout/turret_panel/hb/btn_upgrade.disabled = !battle_area.can_upgrade_turret()
	$ui/layout/turret_panel/hb/btn_delete.disabled = !battle_area.can_delete_turret()
		
func _on_btn_menu_up():
	show_exit_menu()
