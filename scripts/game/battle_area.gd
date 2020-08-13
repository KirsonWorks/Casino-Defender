extends Spatial

const SIDE_TOP = Vector2(0, -1)
const SIDE_LEFT = Vector2(-1, 0)
const SIDE_BOTTOM = Vector2(0, 1)
const SIDE_RIGHT = Vector2(1, 0)

const PRIORITY_SIDES_1 = [SIDE_BOTTOM, SIDE_RIGHT, SIDE_LEFT, SIDE_TOP]
const PRIORITY_SIDES_2 = [SIDE_TOP, SIDE_RIGHT, SIDE_LEFT, SIDE_BOTTOM]

const scene_turret1 = preload("res://scenes/actors/turrets/turret_01.tscn")
const scene_turret2 = preload("res://scenes/actors/turrets/turret_02.tscn")
const scene_turret3 = preload("res://scenes/actors/turrets/turret_03.tscn")
const scenes_turret = [scene_turret1, scene_turret2, scene_turret3]

const script_enemy = preload("res://scripts/actors/enemy.gd")
const scene_enemy_01 = preload("res://models/emenies/enemy01.dae")
const scene_enemy_02 = preload("res://models/emenies/enemy02.dae")
const scene_enemy_03 = preload("res://models/emenies/enemy03.dae")
const scene_enemy_04 = preload("res://models/emenies/enemy04.dae")
const scenes_enemy = [scene_enemy_01, scene_enemy_02, scene_enemy_03, scene_enemy_04]

const explosion = preload("res://scenes/actors/particles/explosion.tscn")
const scene_bullet = preload("res://scenes/actors/shots/bullet.tscn")
const scene_flame = preload("res://scenes/actors/shots/flame.tscn")

const TURRET_COST = [100, 200, 300]
const TURRET_UPGRADE_COST = [[0, 50, 75], [0, 75, 100], [0, 170, 220]]
const TURRET_RADIUS = [[2, 3, 4], [1, 1.5, 2], [4, 5, 6]]
const TURRET_SPEED = [[1.8, 1.6, 1.3], [1.6, 1.4, 1.3], [4.5, 3.8, 3.4]]
const TURRET_DAMAGE = [[10, 13, 17], [20, 27, 35], [50, 80, 100]]
const TURRET_REFUND = [[40, 65, 90], [80, 110, 140], [200, 250, 300]]

const CELL_LEFT = Vector3(-14, 0, 10)
const CELL_RIGHT = Vector3(-14, 0, -10)

enum {TURRET_TYPE_NONE = 0, TURRET_TYPE_GUN, TURRET_TYPE_FLAME, TURRET_TYPE_ROCKET}
enum {TOOL_MODE_NONE, TOOL_MODE_PREBUILD, TOOL_MODE_DETAILS}

var wave_list = []

var money = 0
var health = 0
var waves = 0
var enemy_count = 0

var tool_mode = TOOL_MODE_NONE
var turret_prebuild_type = 0
var turret_selected = null setget set_selected_turret
var click_locked = false

signal change_money(value)
signal change_health(value)
signal change_wave(value)
signal change_tool_mode()
signal change_selected_turret()
signal end_wave()

func _ready():
	add_money(500)
	add_health(16)
	add_waves(0)
	
	#type, quantity, speed, health, cost, spawn_delay
	reg_wave(0, 2, 1.0, 30, 25, 5.0)
	reg_wave(0, 2, 1.0, 30, 25, 5.0)
	
	reg_wave(0, 5, 1.0, 20, 5, 3.0)
	reg_wave(0, 5, 1.0, 20, 5, 3.0)
	
	reg_wave(0, 3, 1.2, 35, 10, 2.7)
	reg_wave(0, 3, 1.2, 35, 10, 2.7)
	
	reg_wave(1, 3, 1.5, 40, 15, 1.5)
	reg_wave(1, 3, 1.5, 40, 15, 1.5)
	
	reg_wave(0, 6, 1.2, 40, 10, 1.5)
	reg_wave(0, 6, 1.2, 40, 10, 1.5)
	
	reg_wave(2, 4, 1.0, 85, 20, 1)
	reg_wave(2, 4, 1.0, 85, 20, 1)
	
	reg_wave(0, 10, 2.0, 50, 10, 2.5)
	reg_wave(1, 5, 2.0, 50, 25, 1.5)
	
	reg_wave(3, 1, 2.0, 200, 50, 2.5)
	reg_wave(3, 1, 2.0, 200, 50, 2.5)

	reg_wave(1, 7, 1.6, 50, 20, 2.2)
	reg_wave(0, 7, 1.6, 65, 10, 3.2)
	
	reg_wave(2, 5, 1.7, 75, 10, 2.0)
	reg_wave(2, 12, 1.7, 45, 10, 2.0)
	
	# 10 ---

	reg_wave(1, 8, 2, 80, 15, 2.2)
	reg_wave(3, 2, 2, 200, 70, 4.0)
	
	reg_wave(2, 8, 2, 85, 15, 2.2)
	reg_wave(0, 20, 2, 50, 10, 1.0)
	
	reg_wave(1, 15, 1.8, 85, 10, 2.0)
	reg_wave(1, 15, 1.8, 85, 10, 2.0)
	
	reg_wave(2, 12, 2.3, 120, 15, 2.2)
	reg_wave(2, 12, 2.3, 120, 15, 3.0)
	
	reg_wave(3, 3, 2.3, 250, 70, 3.0)
	reg_wave(3, 3, 2.3, 250, 70, 3.0)
	
	reg_wave(1, 20, 1.8, 85, 10, 2.0)
	reg_wave(1, 20, 1.8, 85, 10, 2.0)
	
	pass

func _input(event):
	if event.is_action_released("mouse_right_button"):
		change_tool_mode(TOOL_MODE_NONE)

func change_tool_mode(new_mode):
	if tool_mode == new_mode:
		return
	
	match (new_mode):
		TOOL_MODE_NONE:
			self.turret_selected = null
			$cursor.hide()
		
		TOOL_MODE_PREBUILD:
			self.turret_selected = null
			$cursor/marker.show()
			pass
		
		TOOL_MODE_DETAILS:
			$cursor.show()
			$cursor/marker.hide()
	
	tool_mode = new_mode
	emit_signal("change_tool_mode")

func reg_wave(type, quantity = 0, speed = 1, health = 10, cost = 10 , spawn_delay = 2):
	var wave = {"type": type, "quantity": quantity, "speed": speed, 
		"health": health, "cost": cost, "spawn_delay": spawn_delay}
	
	wave_list.append(wave)

func create_wave(num):
	num *= 2
	var portals = [$portal, $portal2]
	var spawns = [CELL_LEFT, CELL_RIGHT]
	var enemy_quantity = 0
	
	for i in 2:
		var w = wave_list[num + i]
		enemy_quantity += w.quantity
		portals[i].create_queue(spawns[i], w.type, w.quantity, w.speed, w.health, w.cost, w.spawn_delay)
	
	return enemy_quantity
	
func next_wave():
	var wave = waves % (wave_list.size() / 2)
	enemy_count = create_wave(wave)
	add_waves(1)
	
func add_money(value):
	money += value
	emit_signal("change_money", money)

func add_health(value):
	health += value
	emit_signal("change_health", health)

func add_waves(value):
	waves += value
	emit_signal("change_wave", waves)

func dec_enemy():
	enemy_count -= 1
	
	if enemy_count == 0:
		emit_signal("end_wave")

func set_selected_turret(value):
	if turret_selected == value:
		return
		
	turret_selected = value
	emit_signal("change_selected_turret")

func can_build_turret(type):
	return money >= TURRET_COST[type - 1]

func can_upgrade_turret():
	if not turret_selected:
		return false
	
	var index = turret_selected.type - 1
	var level = turret_selected.level + 1
	
	if level >= TURRET_UPGRADE_COST[index].size():
		return false
	
	var cost = TURRET_UPGRADE_COST[index][level]
	return  cost != 0 and cost <= money

func can_delete_turret():
	return turret_selected

func update_cursor(turret, radius = 0):
	if turret:
		radius = turret.radius
		$cursor.translation = turret.translation
	
	$cursor/radius.scale = Vector3(radius + 0.5, 1, radius + 0.5)
	
func turret_prebuild(type):
	turret_prebuild_type = type
	
	var params = get_turret_params(type - 1, 0)
	update_cursor(null, params.radius)
	
	if type != TURRET_TYPE_NONE:
		change_tool_mode(TOOL_MODE_PREBUILD)
	else:
		change_tool_mode(TOOL_MODE_NONE)

func turret_build(pos):
	if turret_prebuild_type == TURRET_TYPE_NONE:
		return
	
	var index = turret_prebuild_type - 1
	var turret = scenes_turret[index].instance()
	var params = get_turret_params(index, 0)
		
	$turrets.add_child(turret)
	
	turret.translation = pos
	turret.set_params(params)
	turret.look_at_targets([$portal, $portal2])
	turret.enemies = $enemies.get_path()
	turret.connect("shot", self, "_on_turret_shot")
	
	$snd_turret_build.play()
	$map.set_cell_type(pos, $map.CELL_TYPE_TURRET)
	add_money(-params.cost)
	return turret
	
func turret_upgrade():
	if turret_selected:
		var index = turret_selected.type - 1
		var level = turret_selected.level + 1
		var params = get_turret_params(index, level)
		turret_selected.set_params(params)
		update_cursor(turret_selected)
		add_money(-TURRET_UPGRADE_COST[index][level])
		$snd_turret_upgrade.play()
		
func turret_delete():
	if turret_selected:
		var refund = TURRET_REFUND[turret_selected.type - 1][turret_selected.level]
		$map.set_cell_type(turret_selected.translation, $map.CELL_TYPE_EMPTY)
		create_explosion(turret_selected.translation)
		turret_selected.queue_free()
		add_money(refund)
		change_tool_mode(TOOL_MODE_NONE)
	
func find_turret(cursor_pos):
	for turret in $turrets.get_children():
		if turret.translation == cursor_pos:
			return turret

func get_turret_params(index, level):
	return {
		"type": index + 1,
		"level": level,
		"cost": TURRET_COST[index],
		"upgrade_cost": TURRET_UPGRADE_COST[index][level],
		"refund": TURRET_REFUND[index][level],
		"radius": TURRET_RADIUS[index][level],
		"speed": TURRET_SPEED[index][level],
		"damage": TURRET_DAMAGE[index][level]
	}

func get_turret_buy_info(type):
	return get_turret_params(type - 1, 0)

func get_selected_turret_upgrade_info():
	if can_upgrade_turret():
		return get_turret_params(turret_selected.type - 1, turret_selected.level + 1)
	else:
		return null

func get_selected_turret_delete_info():
	if turret_selected:
		return get_turret_params(turret_selected.type - 1, turret_selected.level)
	else:
		return null
		
func try_select_turret(cursor_pos):
	if $map.get_cell_type(cursor_pos) == $map.CELL_TYPE_TURRET:
		self.turret_selected = find_turret(cursor_pos)
		
		if turret_selected:
			update_cursor(turret_selected)
			change_tool_mode(TOOL_MODE_DETAILS)

func create_explosion(pos):
	var expl = explosion.instance()
	expl.translation = pos
	$fx.add_child(expl)
	expl.emit()
		
func _on_map_mouse_change_cell(cursor_pos):
	if tool_mode == TOOL_MODE_PREBUILD:
		var cell_value = $map.get_cell_type(cursor_pos)
		
		if cell_value == $map.CELL_TYPE_EMPTY:
			if !$cursor.visible:
				$cursor.show()
			
			$cursor/marker.allowed = true
		else:
			$cursor/marker.allowed = false
		
		$cursor.translation = cursor_pos

func _on_map_cell_click(cursor_pos):
	if click_locked:
		return
		
	match tool_mode:
		TOOL_MODE_PREBUILD:
			if $map.get_cell_type(cursor_pos) == $map.CELL_TYPE_EMPTY:
				turret_build(cursor_pos)
				
				if not can_build_turret(turret_prebuild_type):
					turret_prebuild(TURRET_TYPE_NONE)
			else:
				try_select_turret(cursor_pos)
		_:
			try_select_turret(cursor_pos)

func _on_portal_create_enemy(params):
	var enemy = scenes_enemy[params.type].instance()
	enemy.set_script(script_enemy)
	
	enemy.map = $map
	enemy.speed = params.speed
	enemy.health = params.health
	enemy.cost = params.cost
	enemy.translation = Vector3(params.spawn_pos.x, 0.5, params.spawn_pos.z)
	enemy.priority_sides = PRIORITY_SIDES_1 if translation.z < 0 else PRIORITY_SIDES_2
	enemy.connect("cell_changed", self, "_on_enemy_cell_changed")
	enemy.connect("dead", self, "_on_enemy_dead")
	
	$enemies.add_child(enemy)
	enemy.move_to(params.target_pos)

func _on_enemy_cell_changed(sender, cell_pos):
	if cell_pos.x == 17 and (cell_pos.z == 0 or cell_pos.z == 1):
		add_health(-1)
		sender.cost = 0
		sender.kill()

func _on_enemy_dead(pos, cost):
	add_money(cost)
	create_explosion(pos)
	dec_enemy()

func _on_turret_shot(type, pos, angle):
	var shot = null
	
	match type:
		TURRET_TYPE_GUN:
			shot = scene_bullet.instance()
			
		TURRET_TYPE_FLAME:
			shot = scene_flame.instance()
		_:
			return
			
	shot.translation = pos
	$fx.add_child(shot)
	shot.shot(angle)
	
