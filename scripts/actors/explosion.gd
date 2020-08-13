extends Spatial

const LIFE_TIME_LIMIT = 1.5
var life_time = 0.0
 
func _process(delta):
	life_time += delta
	
	if life_time >= LIFE_TIME_LIMIT:
		queue_free()
		
func emit():
	$fire.emitting = true
	$smoke.emitting = true
	$sound.play()
