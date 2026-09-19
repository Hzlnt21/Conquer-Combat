extends Control

enum AppState {
	TITLE,
	PLAYING,
	PAUSED,
}

enum GameMode {
	ARCADE,
	TRAINING,
	LOCAL,
}

@onready var combat_view: CombatView = %CombatView
@onready var phase_label: Label = %PhaseLabel
@onready var header: Control = $Header
@onready var title_screen: Control = %TitleScreen
@onready var pause_screen: Control = %PauseScreen
@onready var arcade_button: Button = %ArcadeButton
@onready var training_button: Button = %TrainingButton
@onready var local_button: Button = %LocalButton
@onready var resume_button: Button = %ResumeButton

var simulation := CombatSimulation.new()
var cpu := BasicCpuController.new(BasicCpuController.Difficulty.NORMAL)
var cpu_enabled := true
var app_state := AppState.TITLE
var game_mode := GameMode.ARCADE
var help_frames_remaining := 360
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
	arcade_button.pressed.connect(_start_arcade)
	training_button.pressed.connect(_start_training)
	local_button.pressed.connect(_start_local)
	resume_button.pressed.connect(_resume_game)
	%TitleButton.pressed.connect(_return_to_title)
	title_screen.visible = true
	pause_screen.visible = false
	header.visible = false
	arcade_button.grab_focus()
	_update_mode_presentation()
	print("Conquer Combat v0.6 application flow loaded.")


func _physics_process(_delta: float) -> void:
	if app_state != AppState.PLAYING:
		return
	var input_one := _capture_player_one()
	var input_two := cpu.next_input(simulation, simulation.dummy, simulation.player) if cpu_enabled else _capture_player_two()
	simulation.tick(input_one, input_two)
	if help_frames_remaining > 0:
		help_frames_remaining -= 1
		header.modulate.a = clampf(help_frames_remaining / 60.0, 0.0, 1.0)
	else:
		header.visible = false
	combat_view.queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		if app_state == AppState.PLAYING:
			_pause_game()
		elif app_state == AppState.PAUSED:
			_resume_game()
		return
	if app_state != AppState.PLAYING:
		return
	if event.keycode == KEY_R:
		simulation.reset()
		cpu.reset()
	elif event.keycode == KEY_F1:
		combat_view.show_debug = not combat_view.show_debug
		combat_view.queue_redraw()
	elif event.keycode == KEY_F2:
		simulation.reset_training_positions()
	elif event.keycode == KEY_F3:
		simulation.refill_training_state()
	elif event.keycode == KEY_F4:
		cpu_enabled = not cpu_enabled
		cpu.reset()
		_update_mode_presentation()
	elif event.keycode == KEY_F5:
		cpu.difficulty = (cpu.difficulty + 1) % BasicCpuController.Difficulty.size()
		cpu.reset()
		_update_mode_presentation()


func _start_arcade() -> void:
	_start_game(GameMode.ARCADE)


func _start_training() -> void:
	_start_game(GameMode.TRAINING)


func _start_local() -> void:
	_start_game(GameMode.LOCAL)


func _start_game(mode: GameMode) -> void:
	game_mode = mode
	app_state = AppState.PLAYING
	cpu_enabled = mode == GameMode.ARCADE
	simulation.reset()
	if mode == GameMode.TRAINING:
		simulation.refill_training_state()
	cpu.reset()
	title_screen.visible = false
	pause_screen.visible = false
	header.visible = true
	help_frames_remaining = 360
	header.modulate.a = 1.0
	_update_mode_presentation()


func _pause_game() -> void:
	app_state = AppState.PAUSED
	pause_screen.visible = true
	resume_button.grab_focus()


func _resume_game() -> void:
	app_state = AppState.PLAYING
	pause_screen.visible = false


func _return_to_title() -> void:
	app_state = AppState.TITLE
	simulation.reset()
	cpu.reset()
	pause_screen.visible = false
	title_screen.visible = true
	header.visible = false
	arcade_button.grab_focus()
	combat_view.queue_redraw()


func _update_mode_presentation() -> void:
	if game_mode == GameMode.TRAINING:
		combat_view.opponent_status = "TRAINING DUMMY"
		phase_label.text = "TRAINING  |  F2 RESET POSITION  |  F3 REFILL  |  F1 FRAME DATA  |  ESC PAUSE"
	elif cpu_enabled:
		combat_view.opponent_status = "CPU %s" % cpu.difficulty_name().to_upper()
		phase_label.text = "ARCADE DUEL  |  F5 CPU LEVEL  |  R RESTART  |  ESC PAUSE"
	else:
		combat_view.opponent_status = "LOCAL P2"
		phase_label.text = "LOCAL VERSUS  |  P1 A/D + J-K-L-I  |  P2 ARROWS + 1-4  |  ESC PAUSE"
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
	result.guard_held = Input.is_key_pressed(KEY_U) or Input.is_joy_button_pressed(0, JOY_BUTTON_LEFT_SHOULDER)
	result.throw_pressed = _just_pressed(KEY_O) or _joy_just_pressed(0, JOY_BUTTON_RIGHT_SHOULDER)
	result.resource_pressed = _just_pressed(KEY_P) or _joy_just_pressed(0, JOY_BUTTON_LEFT_STICK)
	result.ultimate_pressed = _just_pressed(KEY_BRACKETLEFT) or _joy_just_pressed(0, JOY_BUTTON_RIGHT_STICK)
	_apply_double_tap(result, left_pressed, right_pressed, simulation.player.facing, &"p1_left", &"p1_right")
	_update_previous_keys([KEY_A, KEY_D, KEY_J, KEY_K, KEY_L, KEY_I, KEY_U, KEY_O, KEY_P, KEY_BRACKETLEFT])
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
	result.guard_held = Input.is_key_pressed(KEY_5) or Input.is_joy_button_pressed(1, JOY_BUTTON_LEFT_SHOULDER)
	result.throw_pressed = _just_pressed(KEY_6) or _joy_just_pressed(1, JOY_BUTTON_RIGHT_SHOULDER)
	result.resource_pressed = _just_pressed(KEY_7) or _joy_just_pressed(1, JOY_BUTTON_LEFT_STICK)
	result.ultimate_pressed = _just_pressed(KEY_8) or _joy_just_pressed(1, JOY_BUTTON_RIGHT_STICK)
	_apply_double_tap(result, left_pressed, right_pressed, simulation.dummy.facing, &"p2_left", &"p2_right")
	_update_previous_keys([KEY_LEFT, KEY_RIGHT, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8])
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
