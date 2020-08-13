extends Spatial

export (float) var speed = 1.0
export (float) var health = 100.0 setget set_health
export (float) var rotation_speed = TAU
export (int) var cost = 0

const scene_particle_smoke = preload("res://scenes/actors/particles/particle_smoke.tscn")
const scene_particle_fire = preload("res://scenes/actors/particles/particle_fire.tscn")

enum {STATE_NONE, STATE_ROTATE, STATE_MOVE, STATE_DIE}

var map
var angle = 0.0
var base_pos = Vector3()
var target_angle = 0.0
var target_pos = Vector3()
var target_dir = Vector3()
var state = STATE_NONE
var move_time = 0.0
var move_time_scale = 0.0
var backside = Vector2()
var priority_sides
var base_health = 0.0
var smoke = null
var fire = null

signal cell_changed(sender, cell_pos)
signal dead(pos, cost)

func _process(delta):
	match (state):
		STATE_ROTATE:
			var distance = math.angle_distance(angle, target_angle)
			
			if abs(distance) > 0.1:
				var angle_step = rotation_speed * delta * sign(distance)
				angle += angle_step
				rotate_y(-angle_step)
			else:
				change_state(STATE_MOVE)
					
		STATE_MOVE:
			translation = base_pos.linear_interpolate(target_pos, move_time)
			move_time += delta * move_time_scale * speed
			
			if move_time >= 1.0:
				translation = base_pos.linear_interpolate(target_pos, 1.0)
				emit_signal("cell_changed", self, translation)
				move_to(find_position(priority_sides))
				
		STATE_DIE:
			pass
			
func set_health(value):
	health = value
	base_health = value

func damage(value):
	health -= value
	
	var percent = float(health) / base_health
	
	if health <= 0:
		kill()
		return
	
	if not smoke and percent <= 0.5:
		smoke = scene_particle_smoke.instance()
		add_child(smoke)
	
	if not fire and percent <= 0.25:
		fire = scene_particle_fire.instance()
		add_child(fire)
	
func find_position(priority_sides):
	var sides = priority_sides
	
	if randi() % 2 > 0:
		var temp = sides[0]
		sides[0] = sides[1]
		sides[1] = temp
	
	var next_cell = map.get_next_cell(translation, sides, backside)
	backside = next_cell.side * -1
	return next_cell.position

func move_to(v):
	base_pos = translation
	var diff = (Vector2(v.x, v.z) - Vector2(base_pos.x, base_pos.z)).normalized()
	
	move_time = 0.0
	target_pos = Vector3(v.x, base_pos.y, v.z)
	target_angle = fmod(diff.angle(), TAU)
	target_dir = Vector3(diff.x, 0.0, diff.y)
	move_time_scale = 1.0 / base_pos.distance_to(target_pos)
	change_state(STATE_ROTATE)

func kill():
	emit_signal("dead", translation, cost)
	queue_free()

func change_state(new_state):
	if state == new_state:
		return
	
	state = new_state
	
