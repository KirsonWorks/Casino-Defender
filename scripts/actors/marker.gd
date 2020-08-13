extends MeshInstance

var allowed = true setget set_allowed
var allowed_colors = [Color.firebrick, Color.forestgreen]

func _ready():
	set_allowed(false)

func set_color(color):
	var material = mesh.surface_get_material(0)
	material.albedo_color = color

func set_allowed(value):
	if allowed != value:
		allowed = value
		set_color(allowed_colors[int(value)])
