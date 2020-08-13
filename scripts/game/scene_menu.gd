extends "res://scripts/scene_base.gd"

const MENU_CHANGE_DURATION = 0.6
const SMOKE_MOTION = Vector2(0.05, 0.02)

var smoke_offset = Vector2()

func set_options():
	$ui_options_menu/ui_resolution.data = global.get_resolution_list()
	$ui_options_menu/ui_resolution.data_index = global.resolution
	$ui_options_menu/ui_fullscreen.data_index = int(global.fullscreen)
	$ui_options_menu/ui_range_sounds.value = global.sounds_volume
	$ui_options_menu/ui_range_music.value = global.music_volume
	
func _ready():
	set_options()

func _process(delta):
	smoke_offset.x =  fmod(smoke_offset.x + SMOKE_MOTION.x  * delta, 1.0)
	smoke_offset.y =  fmod(smoke_offset.y + SMOKE_MOTION.y  * delta, 1.0)
	$smoke.material.set_shader_param("offset", smoke_offset);
	
func change_menu(next_menu):
	$post_effect.flash_blur(MENU_CHANGE_DURATION)
	yield($post_effect, "completed")
	next_menu.show()

func _on_menu_main_new_action():
	change_scene("res://scenes/game/scene_game.tscn")
		
func _on_ui_item_exit_action():
	change_menu($ui_exit_menu)

func _on_menu_main_options_action():
	change_menu($ui_options_menu)

func _on_menu_credits_action():
	change_menu($ui_credits_menu)

func _on_menu_exit_yes_action():
	get_tree().quit()

func _on_menu_custom_close(menu):
	assert(menu != null)
	
	if not $post_effect.completed():
		return
		
	$post_effect.flash_blur(MENU_CHANGE_DURATION)
	yield($post_effect, "completed")
	menu.hide()

func _on_menu_options_apply_action():
	global.sounds_volume = $ui_options_menu/ui_range_sounds.as_int
	global.music_volume = $ui_options_menu/ui_range_music.as_int
	global.resolution = $ui_options_menu/ui_resolution.data_index
	global.fullscreen = bool($ui_options_menu/ui_fullscreen.data_index)
	global.write_config()

func _on_menu_options_default_action():
	global.apply_config_default()
	set_options()

func _on_menu_options_visibility_changed():
	if $ui_options_menu.visible:
		set_options()
