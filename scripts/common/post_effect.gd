extends CanvasLayer

var fade_intensity: float
var blur_intensity: float

signal completed

func set_fade_intensity(value: float):
	fade_intensity = value
	$screen.material.set_shader_param("fade_intensity", value)

func fade(type: int, duration: float, delay: float, reverse: bool):
	if duration <= 0.0:
		enabled(false)
		return
	
	var from = 0.0 if not reverse else 1.0
	var to = 1.0 - from
	
	$screen.material.set_shader_param("fade_type", type);
	set_fade_intensity(from)
	enabled(true)
	
	if not completed():
		$interval.stop(self, "set_fade_intensity");
	
	$interval.interpolate_method(self, "set_fade_intensity", from, to, duration, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, delay)
	$interval.start()
	
func completed() -> bool:
	return not $interval.is_active()

func on_interval_completed(object, key):
	if fade_intensity + blur_intensity <= 0.0:
		enabled(false)
	
	emit_signal("completed")

func blur(value: float):
	blur_intensity = value
	$screen.material.set_shader_param("blur", value)

func grayscale(value: float):
	$screen.material.set_shader_param("grayscale", value)

func fading(intensity: float):
	$screen.material.set_shader_param("fade_intensity", intensity)

func enabled(value: bool):
	if $screen.visible != value:
		$screen.visible = value

func flash_blur(duration: float):
	var half = duration / 2.0
	$interval.interpolate_method(self, "blur", 0.0, 3.0, half, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$interval.interpolate_method(self, "blur", 3.0, 0.0, half, Tween.TRANS_LINEAR, Tween.EASE_OUT, half)
	enabled(true)
	$interval.start()
