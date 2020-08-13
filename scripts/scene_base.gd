extends Node

enum FadeType { NONE = -1, FADE, HOLE, CURTAIN, CURTAIN_REVERSE }

export (float) var scene_fade_duration = 0.5
export (float) var scene_fade_delay = 0.5
export (FadeType) var scene_start_fade_type = FadeType.NONE
export (FadeType) var scene_finish_fade_type = FadeType.NONE

var tween = null
var leaving_scene = false

func _ready():
	tween = Tween.new()
	add_child(tween)
	interpolate_volume(true)
	
	if scene_start_fade_type != FadeType.NONE:
		$post_effect.fade(scene_start_fade_type, scene_fade_duration, scene_fade_delay, true)

func interpolate_volume(out):
	var sounds = [0.0, global.sounds_volume]
	var music = [0.0, global.music_volume]
	var from = int(!out)
	var to = int(out)
	
	tween.interpolate_method(global, "set_sounds_volume", sounds[from], sounds[to], scene_fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_method(global, "set_music_volume", music[from], music[to], scene_fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func change_scene(path):
	if has_node("post_effect") and not $post_effect.completed():
		yield($post_effect, "completed")
	
	leaving_scene = true
	interpolate_volume(false)
	
	if scene_finish_fade_type != FadeType.NONE:
		$post_effect.fade(scene_finish_fade_type, scene_fade_duration, 0.0, false)
		yield($post_effect, "completed")
		
	if path is String:
		assert(not path.empty())
		get_tree().change_scene(path)
	elif path is PackedScene:
		get_tree().change_scene_to(path)
