extends Spatial

var enemy_params
var enemy_quantity = 0

var spawn_time = 0.0
var spawn_time_delay = 1.5

signal create_enemy(params)

func create_queue(pos, type, quantity, speed, health, cost, delay):
	enemy_params = {"type": type, "spawn_pos": translation, "target_pos": pos, 
		"speed": speed, "health": health, "cost": cost }
		
	enemy_quantity = quantity
	spawn_time_delay = delay

func _process(delta):
	spawn_time -= delta
	
	if enemy_quantity > 0 and spawn_time <= 0:
		emit_signal("create_enemy", enemy_params)
		spawn_time = spawn_time_delay
		enemy_quantity -= 1
