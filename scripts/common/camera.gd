extends Camera

const SENSITIVITY = 0.01
const ZOOM_MIN = 2.0
const ZOOM_MAX = 35.0
const ZOOM_STEP = 1.0
const MOVE_RIGHT = Vector3(0.2, 0, 0)
const MOVE_DOWN = Vector3(0, 0, 0.2)
const X_MIN = 15
const X_MAX = 90

onready var parent = get_parent_spatial()

func _ready():
	assert(parent != null)
	look_at(Vector3(), Vector3(0, 1, 0))

func _input(event):
	if event is InputEventMouseMotion and event.button_mask == BUTTON_MASK_MIDDLE:
		var delta = event.relative * SENSITIVITY
		parent.rotate_y(-delta.x)
		
		var quat_right = Quat(Vector3(1, 0, 0), -delta.y)
		var trans = Transform(quat_right) * transform
		var angle_x = rad2deg(atan2(trans.origin.y, trans.origin.z))
		
		if angle_x > X_MIN and angle_x < X_MAX:
			transform = trans
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			if translation.length() > ZOOM_MIN:
				translate(Vector3(0, 0, -ZOOM_STEP))
		elif event.button_index == BUTTON_WHEEL_DOWN:
			if translation.length() < ZOOM_MAX:
				translate(Vector3(0, 0, ZOOM_STEP))

func move(dir):
	var offset = dir * (translation.z / ZOOM_MAX)
	parent.translate(offset)

func _process(delta):
	if Input.is_action_pressed("player_move_left"):
		move(MOVE_RIGHT * -1)
	elif Input.is_action_pressed("player_move_right"):
		move(MOVE_RIGHT)
	
	if Input.is_action_pressed("player_mode_down"):
		move(MOVE_DOWN)
	elif Input.is_action_pressed("player_move_up"):
		move(MOVE_DOWN * -1)
