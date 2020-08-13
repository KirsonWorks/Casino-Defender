extends Spatial

enum {CELL_TYPE_UNKNOWN = -1, CELL_TYPE_EMPTY, CELL_TYPE_WAY, CELL_TYPE_TURRET}

var current_cell_pos = Vector3()

signal mouse_change_cell(cell_pos)
signal on_cell_click(cell_pos)

var map = []
var map_width = 0
var map_height = 0

func _ready():
	var map_texture = preload("res://textures/map/roadways.png")
	var data = map_texture.get_data()

	map_width = data.get_width()
	map_height = data.get_height()
	
	map.resize(map_width)
	data.lock()
	
	for i in map_width:
		map[i] = []
		map[i].resize(map_height)
		
		for j in map_height:
			var pixel = data.get_pixel(i, j)
			map[i][j] = ceil(pixel.a)
	
	data.unlock()

func get_cell_by_vector(v):
	var x = int(v.x) + map_width / 2
	var y = int(v.z) + map_height / 2
	
	if x < 0 or x >= map_width:
		x = CELL_TYPE_UNKNOWN
	
	if y < 0 or y >= map_height:
		y = CELL_TYPE_UNKNOWN	
	
	return Vector2(x, y)

func get_cell_type(v):
	var cell = get_cell_by_vector(v)
	
	if cell.x < 0 or cell.y < 0: 
		return CELL_TYPE_UNKNOWN
	
	return map[cell.x][cell.y]

func set_cell_type(v, type):
	var cell = get_cell_by_vector(v)
	
	if cell.x < 0 or cell.y < 0:
		return
	
	map[cell.x][cell.y] = type
	emit_signal("mouse_change_cell", v)

func get_next_cell(current_cell, sides, ignore_side):
	var result = {"position" : Vector3(), "side": Vector2()}
	
	for side in sides:
		if side == ignore_side:
			continue
			
		var v = Vector3(current_cell.x + side.x, 0, current_cell.z + side.y)
		var cell = get_cell_type(v)
		
		if cell == CELL_TYPE_WAY:
			result.position = v
			result.side = side
			return result
	
	return result

func _on_body_input_event(camera, event, click_position, click_normal, shape_idx):
	var cell_pos = click_position.round()
	
	if cell_pos != current_cell_pos:
		emit_signal("mouse_change_cell", cell_pos)
		current_cell_pos = cell_pos
	
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("on_cell_click", cell_pos)
