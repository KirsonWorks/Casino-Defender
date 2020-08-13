extends Spatial

export(NodePath) var node_gun
export(NodePath) var enemies
export(float) var rotation_speed = TAU * 2

export(int) var type
export(float) var speed
export(float) var radius
export(float) var damage
export(int) var level = 0

const material_1 = preload("res://models/turrets/turret.material")
const material_2 = preload("res://models/turrets/turret02.material")
const material_3 = preload("res://models/turrets/turret03.material")
const materials = [material_1, material_2, material_3]

onready var gun = get_node_or_null("gun")

enum {STATE_IDLE, STATE_FIRE}

var state = STATE_IDLE
var gun_angle = 0.0
var target_angle = 0.0
var shot_time = 0

var shot_binds = []
var shot_bind = false

signal shot(type, pos, angle)

func _ready():
	shot_binds.append(get_node_or_null("gun/shot_bind1"))
	shot_binds.append(get_node_or_null("gun/shot_bind2"))
	pass

func _process(delta):
	var target = null
	shot_time += delta
	
	var enemies_node = get_node(enemies)
	for enemy in enemies_node.get_children():
		if in_reach(enemy):
			target = enemy
			look_at_target(enemy.translation)
			break
				
	if gun:
		var distance = math.angle_distance(gun_angle, target_angle)
		
		if abs(distance) > 0.2:
			var angle_step = delta * rotation_speed * sign(distance)
			gun_angle += angle_step
			gun.rotate_y(-angle_step)
		else:
			if target and shot_time >= speed:
				emit_signal("shot", type, shot_binds[int(shot_bind)].global_transform.origin, gun_angle)
				shot_bind = !shot_bind
				target.damage(damage)
				shot_time = 0.0

func set_params(params):
	type = params.type
	speed = params.speed
	damage = params.damage
	radius = params.radius
	level = params.level
	$gun.set_surface_material(0, materials[level])
	
func look_at_targets(targets):
	var min_dist = INF
	var nearest_target = null
	
	for target in targets:
		var dist = target.translation.distance_to(translation)
		
		if dist < min_dist:
			min_dist = dist
			nearest_target = target
	
	if nearest_target:
		look_at_target(nearest_target.translation)
	
func look_at_target(target_pos):
	var target_xz = Vector2(target_pos.x, target_pos.z)
	var self_xz = Vector2(translation.x, translation.z)
	target_angle = fmod((target_xz - self_xz).angle(), TAU)
	gun_angle = -gun.rotation.y - PI / 2

func in_reach(spatial):
	var target_xz = Vector2(spatial.translation.x, spatial.translation.z)
	var self_xz = Vector2(translation.x, translation.z)
	return self_xz.distance_to(target_xz) <= radius + 0.5
