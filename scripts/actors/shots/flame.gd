extends "res://scripts/actors/shots/shot_base.gd"

func _ready():
	life_time_limit = 2.0
	pass

func shot(angle):
	.shot(angle)
	$particles.emitting = true
