extends Node

const CONFIG_FILE_NAME = "user://conf.k1"
const DEFAULT_SOUNDS_VOLUME = 100
const DEFAULT_MUSIC_VOLUME = 100
const DEFAULT_RESOLUTION_IDX = 2
const DEFAULT_FULLSCREEN = false

const BUS_SOUNDS = 1
const BUS_MUSIC = 2

var sounds_volume: int = DEFAULT_SOUNDS_VOLUME
var music_volume: int = DEFAULT_MUSIC_VOLUME
var resolution: int = DEFAULT_RESOLUTION_IDX
var fullscreen: bool = DEFAULT_FULLSCREEN

const resolution_list = [Vector2(800, 600),
						 Vector2(1024, 768),
						 Vector2(1280, 720),
						 Vector2(1280, 800),
						 Vector2(1280, 1024),
						 Vector2(1360, 768),
						 Vector2(1366, 768),
						 Vector2(1440, 900),
						 Vector2(1600, 900),
						 Vector2(1680, 1050),
						 Vector2(1920, 1080)]

func _ready():
	read_config()

func set_sounds_volume(value):
	AudioServer.set_bus_volume_db(BUS_SOUNDS, linear2db(value / 100.0))

func set_music_volume(value):
	AudioServer.set_bus_volume_db(BUS_MUSIC, linear2db(value / 100.0))

func get_resolution():
	var res = resolution_list[resolution]
	var ws = OS.window_size
	
	if fullscreen:
		if res.x > ws.x or res.y > ws.y:
			return ws
		
		return res
	else:
		return ws

func get_resolution_list():
	var list = []
	
	for res in resolution_list:
		var s = "%dX%d" % [int(res.x), int(res.y)]
		list.append(s)
		
	return list

func write_config():
	var f = File.new()
	
	f.open(CONFIG_FILE_NAME, File.WRITE)
	f.store_32(sounds_volume)
	f.store_32(music_volume)
	f.store_32(resolution)
	f.store_8(fullscreen)
	f.close()
	
	apply_config()
	
func read_config():
	var f = File.new()
	
	if not f.file_exists(CONFIG_FILE_NAME):
		return
	
	f.open(CONFIG_FILE_NAME, File.READ)
	sounds_volume = f.get_32()
	music_volume = f.get_32()
	resolution = f.get_32()
	fullscreen = bool(f.get_8())
	f.close()
	
	apply_config()

func apply_config():
	set_sounds_volume(sounds_volume)
	set_music_volume(music_volume)
	
	if OS.window_size != resolution_list[resolution]:
		OS.window_size = resolution_list[resolution]
		OS.center_window()
	
	if OS.window_fullscreen != fullscreen:
		OS.window_fullscreen = fullscreen
	
func apply_config_default():
	sounds_volume = DEFAULT_SOUNDS_VOLUME
	music_volume = DEFAULT_MUSIC_VOLUME
	resolution = DEFAULT_RESOLUTION_IDX
	fullscreen = DEFAULT_FULLSCREEN

	write_config()
