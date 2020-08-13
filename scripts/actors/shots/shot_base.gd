extends Spatial

var life_time = 0.0
var life_time_limit = 0.05
var offset = Vector3()

func _process(delta):
	life_time += delta
	
	if life_time >= life_time_limit:
		queue_free()

func shot(angle):
	translation += Vector3(cos(angle), 0, sin(angle)) * offset
	rotation = Vector3(0, -angle + PI / 2, 0)
