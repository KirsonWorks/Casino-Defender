extends Node

func angle_distance(from, to):
	var diff = fmod(to - from, TAU)
	return fmod(diff * 2.0, TAU) - diff
