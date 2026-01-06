extends Camera3D


const SENSITIVITY = 0.01
const MOVE_SPEED_SCROLL_MULTIPLIER = 2


var move_speed := 10.0
var rot_x := 0.0
var rot_y := 0.0

func _input(event: InputEvent) -> void:
	if get_viewport().gui_get_focus_owner() != null: return
	
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_RIGHT:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		rot_x += event.relative.x * SENSITIVITY
		rot_x = fmod(rot_x, PI*2)
		rot_y += event.relative.y * SENSITIVITY
		rot_y = clampf(rot_y, -PI/2, PI/2)
		transform.basis = Basis()
		rotate_object_local(Vector3.UP, -rot_x)
		rotate_object_local(Vector3.RIGHT, -rot_y)
	elif event is InputEventMouseMotion and not event.button_mask & MOUSE_BUTTON_RIGHT:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP: move_speed *= MOVE_SPEED_SCROLL_MULTIPLIER
			MOUSE_BUTTON_WHEEL_DOWN: move_speed /= MOVE_SPEED_SCROLL_MULTIPLIER
	
	if (event is InputEventKey and event.pressed and not event.is_echo()):
		match event.keycode:
			KEY_F:
				if environment.ambient_light_source == environment.AMBIENT_SOURCE_DISABLED:
					environment.ambient_light_source = environment.AMBIENT_SOURCE_COLOR
				else: environment.ambient_light_source = environment.AMBIENT_SOURCE_DISABLED

func _physics_process(delta: float) -> void:
	if get_viewport().gui_get_focus_owner() != null: return
	
	if Input.is_action_pressed("Forward"): translate_object_local(Vector3.FORWARD * move_speed * delta)
	if Input.is_action_pressed("Back"): translate_object_local(Vector3.BACK * move_speed * delta)
	if Input.is_action_pressed("Left"): translate_object_local(Vector3.LEFT * move_speed * delta)
	if Input.is_action_pressed("Right"): translate_object_local(Vector3.RIGHT * move_speed * delta)
	if Input.is_action_pressed("Up"): translate_object_local(Vector3.UP * move_speed * delta)
	if Input.is_action_pressed("Down"): translate_object_local(Vector3.DOWN * move_speed * delta)
	if Input.is_action_pressed("Reset"): global_position = Vector3.ZERO
