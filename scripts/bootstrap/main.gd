extends Control

const SETTINGS_PATH := "user://settings.cfg"

enum AppState {
	TITLE,
	PLAYING,
	PAUSED,
	RESULT,
}

enum GameMode {
	ARCADE,
	TRAINING,
	LOCAL,
	TUTORIAL,
}

enum TrainingDummyMode {
	STAND,
	GUARD,
	CPU,
}

@onready var combat_view: CombatView = %CombatView
@onready var phase_label: Label = %PhaseLabel
@onready var header: Control = $Header
@onready var title_screen: Control = %TitleScreen
@onready var pause_screen: Control = %PauseScreen
@onready var tutorial_screen: Control = %TutorialScreen
@onready var settings_screen: Control = %SettingsScreen
@onready var result_screen: Control = %ResultScreen
@onready var credits_screen: Control = %CreditsScreen
@onready var controls_screen: Control = %ControlsScreen
@onready var tutorial_guide: Control = %TutorialGuide
@onready var tutorial_step_title: Label = %TutorialStepTitle
@onready var tutorial_step_body: Label = %TutorialStepBody
@onready var result_title: Label = %ResultTitle
@onready var match_banner: Label = %MatchBanner
@onready var audio_director: AudioDirector = %AudioDirector
@onready var arcade_button: Button = %ArcadeButton
@onready var training_button: Button = %TrainingButton
@onready var local_button: Button = %LocalButton
@onready var how_to_play_button: Button = %HowToPlayButton
@onready var settings_button: Button = %SettingsButton
@onready var resume_button: Button = %ResumeButton
@onready var volume_slider: HSlider = %VolumeSlider
@onready var screen_shake_toggle: CheckButton = %ScreenShakeToggle
@onready var impact_flash_toggle: CheckButton = %ImpactFlashToggle
@onready var music_toggle: CheckButton = %MusicToggle
@onready var bindings_grid: GridContainer = %BindingsGrid

var simulation := CombatSimulation.new()
var cpu := BasicCpuController.new(BasicCpuController.Difficulty.NORMAL)
var cpu_enabled := true
var app_state := AppState.TITLE
var game_mode := GameMode.ARCADE
var training_dummy_mode := TrainingDummyMode.STAND
var intro_frames := 0
var settings_from_pause := false
var result_delay_frames := 0
var help_frames_remaining := 360
var tutorial_step := 0
var tutorial_move_frames := 0
var tutorial_attack_cooldown := 0
var waiting_for_binding: StringName = &""
var binding_buttons: Dictionary = {}
var p1_bindings: Dictionary = {}
var previous_keys: Dictionary[int, bool] = {}
var previous_joy_buttons: Dictionary[String, bool] = {}
var last_tap_frame := {
	&"p1_left": -100,
	&"p1_right": -100,
	&"p2_left": -100,
	&"p2_right": -100,
}

const BINDING_ACTIONS := [&"left", &"right", &"up", &"down", &"light", &"medium", &"heavy", &"special", &"guard", &"throw", &"resource", &"ultimate"]
const BINDING_LABELS := {
	&"left": "MOVE LEFT", &"right": "MOVE RIGHT", &"up": "JUMP", &"down": "CROUCH",
	&"light": "LIGHT", &"medium": "MEDIUM", &"heavy": "HEAVY", &"special": "SPECIAL",
	&"guard": "GUARD", &"throw": "THROW / TECH", &"resource": "RESOURCE", &"ultimate": "ULTIMATE",
}
const DEFAULT_BINDINGS := {
	&"left": KEY_A, &"right": KEY_D, &"up": KEY_W, &"down": KEY_S,
	&"light": KEY_J, &"medium": KEY_K, &"heavy": KEY_L, &"special": KEY_I,
	&"guard": KEY_U, &"throw": KEY_O, &"resource": KEY_P, &"ultimate": KEY_BRACKETLEFT,
}


func _ready() -> void:
	combat_view.simulation = simulation
	arcade_button.pressed.connect(_start_arcade)
	training_button.pressed.connect(_start_training)
	local_button.pressed.connect(_start_local)
	how_to_play_button.pressed.connect(_show_tutorial)
	settings_button.pressed.connect(_show_title_settings)
	%TutorialStartButton.pressed.connect(_start_guided_tutorial)
	%TutorialBackButton.pressed.connect(_hide_tutorial)
	resume_button.pressed.connect(_resume_game)
	%PauseSettingsButton.pressed.connect(_show_pause_settings)
	%TitleButton.pressed.connect(_return_to_title)
	%SettingsBackButton.pressed.connect(_hide_settings)
	%CreditsButton.pressed.connect(_show_credits)
	%CreditsBackButton.pressed.connect(_hide_credits)
	%ControlsButton.pressed.connect(_show_controls)
	%ControlsBackButton.pressed.connect(_hide_controls)
	%ResetBindingsButton.pressed.connect(_reset_bindings)
	%RematchButton.pressed.connect(_rematch)
	%ResultTitleButton.pressed.connect(_return_to_title)
	volume_slider.value_changed.connect(_set_master_volume)
	screen_shake_toggle.toggled.connect(_set_screen_shake)
	impact_flash_toggle.toggled.connect(_set_impact_flash)
	music_toggle.toggled.connect(_set_music_enabled)
	title_screen.visible = true
	pause_screen.visible = false
	tutorial_screen.visible = false
	settings_screen.visible = false
	result_screen.visible = false
	credits_screen.visible = false
	controls_screen.visible = false
	tutorial_guide.visible = false
	match_banner.visible = false
	_load_settings()
	_build_binding_controls()
	header.visible = false
	arcade_button.grab_focus()
	_update_mode_presentation()
	_apply_visual_qa_mode()
	print("Conquer Combat v1.0 loaded.")


func _apply_visual_qa_mode() -> void:
	var arguments := OS.get_cmdline_user_args()
	if "--qa-tutorial" in arguments:
		_show_tutorial()
	elif "--qa-guided" in arguments:
		_start_guided_tutorial()
		intro_frames = 0
		match_banner.visible = false
	elif "--qa-attack" in arguments:
		_start_game(GameMode.TRAINING)
		intro_frames = 0
		match_banner.visible = false
		var attack := FrameInput.new()
		attack.heavy_pressed = true
		simulation.tick(attack, FrameInput.new())
		for _index in range(10):
			simulation.tick(FrameInput.new(), FrameInput.new())
		combat_view.queue_redraw()
	elif "--qa-xenon-attack" in arguments:
		_start_game(GameMode.TRAINING)
		intro_frames = 0
		match_banner.visible = false
		var attack := FrameInput.new()
		attack.heavy_pressed = true
		simulation.tick(FrameInput.new(), attack)
		for _index in range(11):
			simulation.tick(FrameInput.new(), FrameInput.new())
		combat_view.queue_redraw()
	elif "--qa-settings" in arguments:
		_show_title_settings()
	elif "--qa-controls" in arguments:
		_show_title_settings()
		_show_controls()
	elif "--qa-credits" in arguments:
		_show_title_settings()
		_show_credits()
	elif "--qa-result" in arguments:
		simulation.player.rounds_won = 2
		_show_result()
	elif "--qa-hurt" in arguments:
		_start_game(GameMode.TRAINING)
		intro_frames = 0
		match_banner.visible = false
		simulation.player.state = FighterSimulation.State.HITSTUN
		simulation.player.state_frame = 30
		combat_view.queue_redraw()
	elif "--qa-xenon-hurt" in arguments:
		_start_game(GameMode.TRAINING)
		intro_frames = 0
		match_banner.visible = false
		simulation.dummy.state = FighterSimulation.State.HITSTUN
		simulation.dummy.state_frame = 30
		combat_view.queue_redraw()


func _physics_process(_delta: float) -> void:
	if app_state != AppState.PLAYING:
		return
	if intro_frames > 0:
		intro_frames -= 1
		_update_match_banner()
		return
	if result_delay_frames > 0:
		result_delay_frames -= 1
		if result_delay_frames == 0:
			_show_result()
		return
	var input_one := _capture_player_one()
	var input_two := _capture_opponent_input()
	simulation.tick(input_one, input_two)
	audio_director.process_events(simulation.events)
	combat_view.react_to_events(simulation.events)
	combat_view.tick_presentation()
	_handle_application_events(simulation.events)
	if game_mode == GameMode.TUTORIAL:
		_handle_tutorial_progress(input_one, simulation.events)
	if game_mode == GameMode.TRAINING:
		simulation.round_timer_frames = CombatSimulation.ROUND_TIME_FRAMES
		if simulation.match_state != CombatSimulation.MatchState.FIGHTING:
			simulation.refill_training_state()
	if help_frames_remaining > 0:
		help_frames_remaining -= 1
		header.modulate.a = clampf(help_frames_remaining / 60.0, 0.0, 1.0)
	else:
		header.visible = false
	combat_view.queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	if waiting_for_binding != &"":
		_capture_binding(event)
		return
	if event.keycode == KEY_ESCAPE:
		if credits_screen.visible:
			_hide_credits()
		elif controls_screen.visible:
			_hide_controls()
		elif settings_screen.visible:
			_hide_settings()
		elif tutorial_screen.visible:
			_hide_tutorial()
		elif app_state == AppState.PLAYING and game_mode == GameMode.TUTORIAL:
			_return_to_title()
		elif app_state == AppState.PLAYING:
			_pause_game()
		elif app_state == AppState.PAUSED:
			_resume_game()
		elif app_state == AppState.RESULT:
			_return_to_title()
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
	elif event.keycode == KEY_F6 and game_mode == GameMode.TRAINING:
		training_dummy_mode = (training_dummy_mode + 1) % TrainingDummyMode.size()
		cpu.reset()
		_update_mode_presentation()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START:
		if app_state == AppState.PLAYING:
			_pause_game()
		elif app_state == AppState.PAUSED and not settings_screen.visible:
			_resume_game()
		get_viewport().set_input_as_handled()


func _start_arcade() -> void:
	_start_game(GameMode.ARCADE)


func _start_training() -> void:
	_start_game(GameMode.TRAINING)


func _start_local() -> void:
	_start_game(GameMode.LOCAL)


func _start_guided_tutorial() -> void:
	tutorial_screen.visible = false
	_start_game(GameMode.TUTORIAL)
	intro_frames = 45
	tutorial_step = 0
	tutorial_move_frames = 0
	tutorial_attack_cooldown = 45
	tutorial_guide.visible = true
	_update_tutorial_guide()


func _start_game(mode: GameMode) -> void:
	audio_director.play_ui()
	game_mode = mode
	app_state = AppState.PLAYING
	cpu_enabled = mode == GameMode.ARCADE
	simulation.reset()
	if mode == GameMode.TRAINING:
		simulation.refill_training_state()
	elif mode == GameMode.TUTORIAL:
		simulation.reset_training_positions()
	cpu.reset()
	intro_frames = 150 if mode == GameMode.ARCADE else 90
	result_delay_frames = 0
	title_screen.visible = false
	pause_screen.visible = false
	result_screen.visible = false
	header.visible = true
	help_frames_remaining = 360
	header.modulate.a = 1.0
	match_banner.visible = true
	_update_match_banner()
	_update_mode_presentation()


func _pause_game() -> void:
	app_state = AppState.PAUSED
	pause_screen.visible = true
	resume_button.grab_focus()


func _resume_game() -> void:
	audio_director.play_ui()
	app_state = AppState.PLAYING
	pause_screen.visible = false


func _return_to_title() -> void:
	audio_director.play_ui()
	app_state = AppState.TITLE
	simulation.reset()
	cpu.reset()
	pause_screen.visible = false
	tutorial_screen.visible = false
	settings_screen.visible = false
	result_screen.visible = false
	credits_screen.visible = false
	controls_screen.visible = false
	tutorial_guide.visible = false
	match_banner.visible = false
	title_screen.visible = true
	header.visible = false
	arcade_button.grab_focus()
	combat_view.queue_redraw()


func _handle_application_events(events: Array[Dictionary]) -> void:
	for event in events:
		if event.get("type", &"") == &"match_ended":
			result_delay_frames = 105


func _show_result() -> void:
	app_state = AppState.RESULT
	title_screen.visible = false
	pause_screen.visible = false
	tutorial_screen.visible = false
	settings_screen.visible = false
	result_screen.visible = true
	tutorial_guide.visible = false
	var player_won := simulation.player.rounds_won > simulation.dummy.rounds_won
	result_title.text = "IZUNA CONQUERS" if player_won else "XENON CONQUERS"
	%ResultSubtitle.text = (
		"Memory endures. Eidara keeps its choices." if player_won
		else "The mask breaks. Despair takes the stage."
	)
	%RematchButton.grab_focus()


func _rematch() -> void:
	_start_game(game_mode)


func _show_tutorial() -> void:
	audio_director.play_ui()
	title_screen.visible = false
	tutorial_screen.visible = true
	%TutorialBackButton.grab_focus()


func _hide_tutorial() -> void:
	audio_director.play_ui()
	tutorial_screen.visible = false
	title_screen.visible = true
	how_to_play_button.grab_focus()


func _show_title_settings() -> void:
	_show_settings(false)


func _show_pause_settings() -> void:
	_show_settings(true)


func _show_settings(from_pause: bool) -> void:
	audio_director.play_ui()
	settings_from_pause = from_pause
	title_screen.visible = false
	pause_screen.visible = false
	settings_screen.visible = true
	controls_screen.visible = false
	volume_slider.grab_focus()


func _hide_settings() -> void:
	audio_director.play_ui()
	settings_screen.visible = false
	if settings_from_pause:
		pause_screen.visible = true
		resume_button.grab_focus()
	else:
		title_screen.visible = true
		settings_button.grab_focus()


func _show_credits() -> void:
	audio_director.play_ui()
	settings_screen.visible = false
	credits_screen.visible = true
	%CreditsBackButton.grab_focus()


func _hide_credits() -> void:
	audio_director.play_ui()
	credits_screen.visible = false
	settings_screen.visible = true
	%CreditsButton.grab_focus()


func _show_controls() -> void:
	audio_director.play_ui()
	settings_screen.visible = false
	controls_screen.visible = true
	waiting_for_binding = &""
	_update_binding_buttons()
	%ControlsBackButton.grab_focus()


func _hide_controls() -> void:
	audio_director.play_ui()
	waiting_for_binding = &""
	controls_screen.visible = false
	settings_screen.visible = true
	%ControlsButton.grab_focus()


func _load_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	for action in BINDING_ACTIONS:
		p1_bindings[action] = int(config.get_value("controls", String(action), DEFAULT_BINDINGS[action]))
	volume_slider.value = float(config.get_value("audio", "master", 78.0))
	music_toggle.button_pressed = bool(config.get_value("audio", "music", true))
	screen_shake_toggle.button_pressed = bool(config.get_value("accessibility", "screen_shake", true))
	impact_flash_toggle.button_pressed = bool(config.get_value("accessibility", "impact_flash", true))
	_set_master_volume(volume_slider.value, false)
	_set_music_enabled(music_toggle.button_pressed, false)
	_set_screen_shake(screen_shake_toggle.button_pressed, false)
	_set_impact_flash(impact_flash_toggle.button_pressed, false)


func _set_master_volume(value: float, persist := true) -> void:
	audio_director.set_master_volume(clampf(value / 100.0, 0.0, 1.0))
	if persist:
		_save_settings()


func _set_screen_shake(enabled: bool, persist := true) -> void:
	combat_view.screen_shake_enabled = enabled
	if persist:
		_save_settings()


func _set_impact_flash(enabled: bool, persist := true) -> void:
	combat_view.impact_flash_enabled = enabled
	if persist:
		_save_settings()


func _set_music_enabled(enabled: bool, persist := true) -> void:
	audio_director.set_music_enabled(enabled)
	if persist:
		_save_settings()


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master", volume_slider.value)
	config.set_value("audio", "music", music_toggle.button_pressed)
	for action in BINDING_ACTIONS:
		config.set_value("controls", String(action), p1_bindings[action])
	config.set_value("accessibility", "screen_shake", screen_shake_toggle.button_pressed)
	config.set_value("accessibility", "impact_flash", impact_flash_toggle.button_pressed)
	config.save(SETTINGS_PATH)


func _capture_opponent_input() -> FrameInput:
	if game_mode == GameMode.LOCAL:
		return _capture_player_two()
	if game_mode == GameMode.TRAINING:
		match training_dummy_mode:
			TrainingDummyMode.GUARD:
				var guard_input := FrameInput.new()
				guard_input.right = simulation.dummy.facing < 0
				guard_input.left = simulation.dummy.facing > 0
				return guard_input
			TrainingDummyMode.CPU:
				return cpu.next_input(simulation, simulation.dummy, simulation.player)
			_:
				return FrameInput.new()
	if game_mode == GameMode.TUTORIAL:
		if tutorial_step != 3:
			return FrameInput.new()
		tutorial_attack_cooldown -= 1
		var tutorial_input := FrameInput.new()
		if tutorial_attack_cooldown <= 0 and simulation.dummy.can_start_attack():
			tutorial_input.light_pressed = true
			tutorial_attack_cooldown = 75
		return tutorial_input
	return cpu.next_input(simulation, simulation.dummy, simulation.player)


func _update_match_banner() -> void:
	if intro_frames <= 0:
		match_banner.visible = false
		return
	match_banner.visible = true
	if intro_frames > 70:
		match_banner.text = "MEMORY  VS  EMOTION\nTHE CONQUEST BEGINS"
		match_banner.modulate.a = clampf((150 - intro_frames) / 24.0, 0.0, 1.0)
	else:
		match_banner.text = "FIGHT"
		match_banner.modulate.a = clampf(intro_frames / 24.0, 0.0, 1.0)


func _update_mode_presentation() -> void:
	if game_mode == GameMode.TRAINING:
		combat_view.opponent_status = "DUMMY %s" % TrainingDummyMode.keys()[training_dummy_mode]
		phase_label.text = "TRAINING  |  F6 DUMMY: %s  |  F2 RESET  |  F3 REFILL  |  F1 FRAME DATA" % TrainingDummyMode.keys()[training_dummy_mode]
	elif game_mode == GameMode.TUTORIAL:
		combat_view.opponent_status = "TUTORIAL PARTNER"
		phase_label.text = "GUIDED TUTORIAL  |  COMPLETE EACH OBJECTIVE  |  ESC EXIT"
	elif cpu_enabled:
		combat_view.opponent_status = "CPU %s" % cpu.difficulty_name().to_upper()
		phase_label.text = "ARCADE DUEL  |  F5 CPU LEVEL  |  R RESTART  |  ESC PAUSE"
	else:
		combat_view.opponent_status = "LOCAL P2"
		phase_label.text = "LOCAL VERSUS  |  P1 A/D + J-K-L-I  |  P2 ARROWS + 1-4  |  ESC PAUSE"
	combat_view.queue_redraw()


func _capture_player_one() -> FrameInput:
	var result := FrameInput.new()
	var left_key: Key = p1_bindings[&"left"]
	var right_key: Key = p1_bindings[&"right"]
	var left_pressed := _just_pressed(left_key)
	var right_pressed := _just_pressed(right_key)
	result.left = Input.is_key_pressed(left_key) or _joy_direction(0, JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1)
	result.right = Input.is_key_pressed(right_key) or _joy_direction(0, JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1)
	result.up = Input.is_key_pressed(p1_bindings[&"up"]) or Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_UP)
	result.down = Input.is_key_pressed(p1_bindings[&"down"]) or Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_DOWN)
	result.light_pressed = _just_pressed(p1_bindings[&"light"]) or _joy_just_pressed(0, JOY_BUTTON_X)
	result.medium_pressed = _just_pressed(p1_bindings[&"medium"]) or _joy_just_pressed(0, JOY_BUTTON_Y)
	result.heavy_pressed = _just_pressed(p1_bindings[&"heavy"]) or _joy_just_pressed(0, JOY_BUTTON_B)
	result.special_pressed = _just_pressed(p1_bindings[&"special"]) or _joy_just_pressed(0, JOY_BUTTON_A)
	result.guard_held = Input.is_key_pressed(p1_bindings[&"guard"]) or Input.is_joy_button_pressed(0, JOY_BUTTON_LEFT_SHOULDER)
	result.throw_pressed = _just_pressed(p1_bindings[&"throw"]) or _joy_just_pressed(0, JOY_BUTTON_RIGHT_SHOULDER)
	result.resource_pressed = _just_pressed(p1_bindings[&"resource"]) or _joy_just_pressed(0, JOY_BUTTON_LEFT_STICK)
	result.ultimate_pressed = _just_pressed(p1_bindings[&"ultimate"]) or _joy_just_pressed(0, JOY_BUTTON_RIGHT_STICK)
	_apply_double_tap(result, left_pressed, right_pressed, simulation.player.facing, &"p1_left", &"p1_right")
	var bound_keys: Array[Key] = []
	for action in BINDING_ACTIONS:
		bound_keys.append(p1_bindings[action])
	_update_previous_keys(bound_keys)
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


func _handle_tutorial_progress(input: FrameInput, events: Array[Dictionary]) -> void:
	if tutorial_step == 0 and input.horizontal_axis() != 0:
		tutorial_move_frames += 1
		if tutorial_move_frames >= 30:
			_advance_tutorial()
			return
	for event in events:
		var event_type: StringName = event.get("type", &"")
		if tutorial_step == 1 and event_type == &"hit_connected" and event.get("player", 0) == 1:
			_advance_tutorial()
			return
		if tutorial_step == 2 and event_type == &"hit_connected" and event.get("player", 0) == 1 and event.get("move", &"") == &"izuna_medium":
			_advance_tutorial()
			return
		if tutorial_step == 3 and event_type == &"attack_blocked" and event.get("player", 0) == 2:
			_advance_tutorial()
			return
		if tutorial_step == 4 and event_type == &"conquer_art_started":
			_advance_tutorial()
			return


func _advance_tutorial() -> void:
	tutorial_step += 1
	audio_director.play_ui()
	simulation.reset_training_positions()
	if tutorial_step == 3:
		simulation.player.position.x = 500 * CombatSimulation.UNITS_PER_PIXEL
		simulation.dummy.position.x = 630 * CombatSimulation.UNITS_PER_PIXEL
		tutorial_attack_cooldown = 45
	elif tutorial_step == 4:
		simulation.player.conviction = FighterSimulation.CONVICTION_BAR
	_update_tutorial_guide()


func _update_tutorial_guide() -> void:
	var titles := ["STEP 1 / 5  MOVEMENT", "STEP 2 / 5  STRIKE", "STEP 3 / 5  COMBO", "STEP 4 / 5  DEFENSE", "STEP 5 / 5  CONVICTION", "TUTORIAL COMPLETE"]
	var bodies := [
		"Move left and right for a moment.",
		"Land a Light attack on Xenon.",
		"Land a Medium attack. Try Light into Medium.",
		"Hold Guard or hold away and block Xenon's attack.",
		"Press Resource with one full bar to unleash Conquer Art.",
		"You are ready for The Conquest. Press ESC to return to the title.",
	]
	var index := mini(tutorial_step, titles.size() - 1)
	tutorial_step_title.text = titles[index]
	tutorial_step_body.text = bodies[index]


func _build_binding_controls() -> void:
	for child in bindings_grid.get_children():
		child.queue_free()
	binding_buttons.clear()
	for action in BINDING_ACTIONS:
		var label := Label.new()
		label.text = BINDING_LABELS[action]
		label.custom_minimum_size = Vector2(150, 32)
		label.add_theme_font_size_override("font_size", 13)
		bindings_grid.add_child(label)
		var button := Button.new()
		button.custom_minimum_size = Vector2(118, 32)
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(_begin_rebind.bind(action))
		bindings_grid.add_child(button)
		binding_buttons[action] = button
	_update_binding_buttons()


func _begin_rebind(action: StringName) -> void:
	waiting_for_binding = action
	audio_director.play_ui()
	_update_binding_buttons()


func _capture_binding(event: InputEventKey) -> void:
	if event.keycode == KEY_ESCAPE:
		waiting_for_binding = &""
		_update_binding_buttons()
		return
	if event.keycode in [KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6, KEY_R]:
		return
	var old_key: int = p1_bindings[waiting_for_binding]
	for action in BINDING_ACTIONS:
		if action != waiting_for_binding and p1_bindings[action] == event.keycode:
			p1_bindings[action] = old_key
			break
	p1_bindings[waiting_for_binding] = event.keycode
	waiting_for_binding = &""
	previous_keys.clear()
	_save_settings()
	audio_director.play_ui()
	_update_binding_buttons()


func _reset_bindings() -> void:
	for action in BINDING_ACTIONS:
		p1_bindings[action] = DEFAULT_BINDINGS[action]
	waiting_for_binding = &""
	previous_keys.clear()
	_save_settings()
	audio_director.play_ui()
	_update_binding_buttons()


func _update_binding_buttons() -> void:
	for action in binding_buttons:
		var button: Button = binding_buttons[action]
		button.text = "PRESS A KEY..." if action == waiting_for_binding else OS.get_keycode_string(p1_bindings[action])
