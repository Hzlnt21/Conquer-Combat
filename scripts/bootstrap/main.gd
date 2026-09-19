extends Control

@onready var combat_view: CombatView = %CombatView
@onready var phase_label: Label = %PhaseLabel

var simulation := CombatSimulation.new()
var previous_keys: Dictionary[int, bool] = {}
var previous_joy_buttons: Dictionary[String, bool] = {}
var last_tap_frame := {
	&"p1_left": -100,
	&"p1_right": -100,
	&"p2_left": -100,
	&"p2_right": -100,
}


func _ready() -> void:
	combat_view.simulation = simulation
	phase_label.text = "P1 A/D W S J/K/L/I | P2 arrows 1/2/3/4 | direction + Special | R reset"
	print("Conquer Combat v0.1c character contrast foundation loaded.")


func _physics_process(_delta: float) -> void:
	var input_one := _capture_player_one()
	var input_two := _capture_player_two()
	simulation.tick(input_one, input_two)
	combat_view.queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_R:
		simulation.reset()
	elif event.keycode == KEY_F1:
		combat_view.show_debug = not combat_view.show_debug
		combat_view.queue_redraw()


func _capture_player_one() -> FrameInput:
	var result := FrameInput.new()
	var left_pressed := _just_pressed(KEY_A)
	var right_pressed := _just_pressed(KEY_D)
	result.left = Input.is_key_pressed(KEY_A) or _joy_direction(0, JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1)
	result.right = Input.is_key_pressed(KEY_D) or _joy_direction(0, JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1)
	result.up = Input.is_key_pressed(KEY_W) or Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_UP)
	result.down = Input.is_key_pressed(KEY_S) or Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_DOWN)
	result.light_pressed = _just_pressed(KEY_J) or _joy_just_pressed(0, JOY_BUTTON_X)
	result.medium_pressed = _just_pressed(KEY_K) or _joy_just_pressed(0, JOY_BUTTON_Y)
	result.heavy_pressed = _just_pressed(KEY_L) or _joy_just_pressed(0, JOY_BUTTON_B)
	result.special_pressed = _just_pressed(KEY_I) or _joy_just_pressed(0, JOY_BUTTON_A)
	_apply_double_tap(result, left_pressed, right_pressed, simulation.player.facing, &"p1_left", &"p1_right")
	_update_previous_keys([KEY_A, KEY_D, KEY_J, KEY_K, KEY_L, KEY_I])
	return result


func _capture_player_two() -> FrameInput:
	var result := FrameInput.new()
	var left_pressed := _just_pressed(KEY_LEFT)
	var right_pressed := _just_pressed(KEY_RIGHT)
	result.left = Input.is_key_pressed(KEY_LEFT) or _joy_direction(1, JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1)
	result.right = Input.is_key_pressed(KEY_RIGHT) or _joy_direction(1, JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1)
	result.up = Input.is_key_pressed(KEY_UP) or Input.is_joy_button_pressed(1, JOY_BUTTON_DPAD_UP)
	result.down = Input.is_key_pressed(KEY_DOWN) or Input.is_joy_button_pressed(1, JOY_BUTTON_DPAD_DOWN)
	result.light_pressed = _just_pressed(KEY_1) or _joy_just_pressed(1, JOY_BUTTON_X)
	result.medium_pressed = _just_pressed(KEY_2) or _joy_just_pressed(1, JOY_BUTTON_Y)
	result.heavy_pressed = _just_pressed(KEY_3) or _joy_just_pressed(1, JOY_BUTTON_B)
	result.special_pressed = _just_pressed(KEY_4) or _joy_just_pressed(1, JOY_BUTTON_A)
	_apply_double_tap(result, left_pressed, right_pressed, simulation.dummy.facing, &"p2_left", &"p2_right")
	_update_previous_keys([KEY_LEFT, KEY_RIGHT, KEY_1, KEY_2, KEY_3, KEY_4])
	return result


func _apply_double_tap(
	result: FrameInput,
	left_pressed: bool,
	right_pressed: bool,
	facing: int,
	left_key: StringName,
	right_key: StringName
) -> void:
	if left_pressed:
		var is_double_tap: bool = simulation.frame - int(last_tap_frame[left_key]) <= 12
		last_tap_frame[left_key] = simulation.frame
		if is_double_tap:
			result.dash_forward_pressed = facing < 0
			result.backdash_pressed = facing > 0
	if right_pressed:
		var is_double_tap: bool = simulation.frame - int(last_tap_frame[right_key]) <= 12
		last_tap_frame[right_key] = simulation.frame
		if is_double_tap:
			result.dash_forward_pressed = facing > 0
			result.backdash_pressed = facing < 0


func _just_pressed(keycode: Key) -> bool:
	return Input.is_key_pressed(keycode) and not previous_keys.get(keycode, false)


func _joy_just_pressed(device: int, button: JoyButton) -> bool:
	var key := "%d:%d" % [device, button]
	var pressed := Input.is_joy_button_pressed(device, button)
	var was_pressed: bool = previous_joy_buttons.get(key, false)
	previous_joy_buttons[key] = pressed
	return pressed and not was_pressed


func _joy_direction(device: int, dpad_button: JoyButton, axis: JoyAxis, direction: int) -> bool:
	if Input.is_joy_button_pressed(device, dpad_button):
		return true
	return Input.get_joy_axis(device, axis) * direction > 0.55


func _update_previous_keys(keycodes: Array[Key]) -> void:
	for keycode in keycodes:
		previous_keys[keycode] = Input.is_key_pressed(keycode)
