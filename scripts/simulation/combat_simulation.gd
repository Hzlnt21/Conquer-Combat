class_name CombatSimulation
extends RefCounted

enum MatchState {
	FIGHTING,
	ROUND_OVER,
	MATCH_OVER,
}

const UNITS_PER_PIXEL := 1000
const STAGE_LEFT := 80 * UNITS_PER_PIXEL
const STAGE_RIGHT := 1200 * UNITS_PER_PIXEL
const GROUND_Y := 590 * UNITS_PER_PIXEL
const ROUND_TIME_FRAMES := 99 * 60
const ROUND_OVER_FRAMES := 120
const METER_GAIN_HIT := 180
const METER_GAIN_BLOCK := 60
const METER_GAIN_RECEIVED := 70
const METER_GAIN_GUARD := 30
const BURST_RANGE := 240 * UNITS_PER_PIXEL

var frame := 0
var hitstop_frames := 0
var player: FighterSimulation
var dummy: FighterSimulation
var move_sets: Dictionary[StringName, Dictionary] = {}
var events: Array[Dictionary] = []
var match_state := MatchState.FIGHTING
var round_number := 1
var round_timer_frames := ROUND_TIME_FRAMES
var round_over_frames := 0
var round_winner := 0


func _init() -> void:
	move_sets[&"izuna"] = {
		&"light": MoveDefinition.new(&"izuna_light", 5, 3, 10, 40, 5, 12, 72, 118, 2),
		&"medium": MoveDefinition.new(&"izuna_medium", 9, 4, 15, 70, 7, 17, 108, 132, 4),
		&"heavy": MoveDefinition.new(&"izuna_heavy", 14, 5, 22, 110, 9, 24, 148, 150, 8, true),
		&"special_neutral": MoveDefinition.new(&"izuna_recall_slash", 11, 4, 20, 80, 8, 20, 135, 138, 5),
		&"special_forward": MoveDefinition.new(&"izuna_foxfire_step", 13, 5, 22, 95, 8, 22, 170, 134, 7, false, 7),
		&"special_down": MoveDefinition.new(&"izuna_memory_break", 8, 5, 28, 90, 8, 24, 96, 190, 6, true),
		&"throw": MoveDefinition.new(&"izuna_forgotten_oath", 6, 2, 24, 120, 7, 20, 54, 176, 5, true, 0, true),
		&"conquer_art": MoveDefinition.new(&"izuna_sacred_recall", 10, 5, 18, 125, 10, 24, 190, 150, 8, true),
		&"ultimate": MoveDefinition.new(&"izuna_ninefold_severance", 12, 5, 45, 360, 14, 38, 230, 176, 14, true),
		&"recall_strike": MoveDefinition.new(&"izuna_recall_strike", 0, 3, 0, 45, 6, 16, 220, 150, 4),
	}
	move_sets[&"xenon"] = {
		&"light": MoveDefinition.new(&"xenon_light", 6, 3, 11, 35, 5, 11, 76, 116, 2),
		&"medium": MoveDefinition.new(&"xenon_medium", 10, 4, 17, 75, 7, 18, 142, 130, 5),
		&"heavy": MoveDefinition.new(&"xenon_heavy", 16, 5, 24, 115, 9, 25, 176, 148, 9, true),
		&"special_neutral": MoveDefinition.new(&"xenon_laughing_chain", 14, 4, 23, 85, 8, 21, 220, 126, 5),
		&"special_forward": MoveDefinition.new(&"xenon_mocking_step", 12, 4, 24, 65, 7, 18, 150, 130, 4, false, 5),
		&"special_down": MoveDefinition.new(&"xenon_despair_puppet", 12, 1, 20, 0, 0, 0, 0, 0, 0),
		&"throw": MoveDefinition.new(&"xenon_shared_misery", 7, 2, 25, 125, 7, 21, 56, 176, 6, true, 0, true),
		&"conquer_art": MoveDefinition.new(&"xenon_unmasked_chorus", 12, 1, 19, 0, 0, 0, 0, 0, 0),
		&"ultimate": MoveDefinition.new(&"xenon_the_last_laugh", 14, 6, 44, 380, 14, 40, 250, 180, 15, true),
		&"puppet_strike": MoveDefinition.new(&"xenon_puppet_strike", 0, 3, 0, 55, 6, 17, 120, 130, 4),
	}
	reset()


func reset() -> void:
	frame = 0
	hitstop_frames = 0
	events.clear()
	match_state = MatchState.FIGHTING
	round_number = 1
	round_timer_frames = ROUND_TIME_FRAMES
	round_over_frames = 0
	round_winner = 0
	player = FighterSimulation.new(&"izuna_p1", Vector2i(350 * UNITS_PER_PIXEL, GROUND_Y), &"izuna")
	dummy = FighterSimulation.new(&"xenon_p2", Vector2i(830 * UNITS_PER_PIXEL, GROUND_Y), &"xenon")
	_update_facing()


func tick(input_one: FrameInput, input_two: FrameInput = null) -> void:
	if input_two == null:
		input_two = FrameInput.new()

	events.clear()
	frame += 1

	if match_state != MatchState.FIGHTING:
		_tick_round_flow()
		return

	_capture_attack_input(player, input_one)
	_capture_attack_input(dummy, input_two)
	if hitstop_frames > 0:
		hitstop_frames -= 1
		return
	player.tick_throw_tech_window()
	dummy.tick_throw_tech_window()

	_handle_resource_input(player, dummy, input_one)
	_handle_resource_input(dummy, player, input_two)

	player.tick_character_mechanic()
	dummy.tick_character_mechanic()
	round_timer_frames = maxi(0, round_timer_frames - 1)
	_update_facing()
	_tick_fighter(player, input_one)
	_tick_fighter(dummy, input_two)
	_resolve_stage_bounds(player)
	_resolve_stage_bounds(dummy)
	_resolve_pushboxes()
	_resolve_attacks(input_one, input_two)
	_evaluate_round_end()


func displayed_timer() -> int:
	return ceili(round_timer_frames / 60.0)


func reset_training_positions() -> void:
	hitstop_frames = 0
	match_state = MatchState.FIGHTING
	round_timer_frames = ROUND_TIME_FRAMES
	player.reset_for_round(Vector2i(420 * UNITS_PER_PIXEL, GROUND_Y))
	dummy.reset_for_round(Vector2i(860 * UNITS_PER_PIXEL, GROUND_Y))
	_update_facing()
	events.append({"type": &"training_reset", "scope": &"positions"})


func refill_training_state() -> void:
	player.health = 1000
	dummy.health = 1000
	player.conviction = FighterSimulation.CONVICTION_MAX
	dummy.conviction = FighterSimulation.CONVICTION_MAX
	player.burst_available = true
	dummy.burst_available = true
	player.clear_character_mechanic()
	dummy.clear_character_mechanic()
	round_timer_frames = ROUND_TIME_FRAMES
	events.append({"type": &"training_reset", "scope": &"resources"})


func _capture_attack_input(fighter: FighterSimulation, input: FrameInput) -> void:
	if input.ultimate_pressed:
		fighter.queue_attack(&"ultimate")
	elif input.throw_pressed:
		fighter.open_throw_tech_window()
		fighter.queue_attack(&"throw")
	elif input.light_pressed:
		fighter.queue_attack(&"light")
	elif input.medium_pressed:
		fighter.queue_attack(&"medium")
	elif input.heavy_pressed:
		fighter.queue_attack(&"heavy")
	elif input.special_pressed:
		var special_action := &"special_neutral"
		if input.down:
			special_action = &"special_down"
		elif input.horizontal_axis() == fighter.facing:
			special_action = &"special_forward"
		fighter.queue_attack(special_action)


func _tick_fighter(fighter: FighterSimulation, input: FrameInput) -> void:
	if fighter.state == FighterSimulation.State.KO:
		return

	if fighter.state in [FighterSimulation.State.HITSTUN, FighterSimulation.State.BLOCKSTUN, FighterSimulation.State.THROW_TECH]:
		fighter.state_frame -= 1
		fighter.position.x += fighter.velocity.x
		fighter.velocity.x = move_toward(fighter.velocity.x, 0, 800)
		if fighter.state_frame <= 0:
			_set_state(fighter, FighterSimulation.State.IDLE)
		return

	if fighter.state == FighterSimulation.State.KNOCKDOWN:
		fighter.state_frame -= 1
		fighter.position.x += fighter.velocity.x
		fighter.velocity.x = move_toward(fighter.velocity.x, 0, 1000)
		if fighter.state_frame <= 0:
			_set_state(fighter, FighterSimulation.State.IDLE)
		return

	if fighter.state == FighterSimulation.State.GUARD_STARTUP:
		if not input.guard_held:
			_set_state(fighter, FighterSimulation.State.GUARD_RECOVERY)
			return
		fighter.state_frame += 1
		if fighter.state_frame >= FighterSimulation.GUARD_STARTUP_FRAMES:
			_set_state(fighter, FighterSimulation.State.GUARD)
		return

	if fighter.state == FighterSimulation.State.GUARD:
		if not input.guard_held:
			_set_state(fighter, FighterSimulation.State.GUARD_RECOVERY)
		return

	if fighter.state == FighterSimulation.State.GUARD_RECOVERY:
		fighter.state_frame += 1
		if fighter.state_frame >= FighterSimulation.GUARD_RECOVERY_FRAMES:
			_set_state(fighter, FighterSimulation.State.IDLE)
		return

	if fighter.state == FighterSimulation.State.BURST:
		fighter.state_frame -= 1
		if fighter.state_frame <= 0:
			_set_state(fighter, FighterSimulation.State.IDLE)
		return

	if fighter.state == FighterSimulation.State.ATTACK:
		if fighter.buffer_frames > 0 and fighter.move_has_hit and _can_cancel(fighter.current_move, fighter.buffered_attack):
			var cancel_action := fighter.buffered_attack
			var cancel_move := _move_for(fighter, cancel_action)
			if cancel_move != null and _can_start_action(fighter, cancel_action):
				_prepare_action(fighter, cancel_action)
				fighter.start_move(cancel_move)
				events.append({"type": &"attack_started", "fighter": fighter.fighter_id, "move": cancel_move.id, "cancel": true})
				return
		fighter.move_frame += 1
		if fighter.current_move.travel_per_frame != 0 and fighter.move_frame < fighter.current_move.startup + fighter.current_move.active:
			fighter.position.x += fighter.facing * fighter.current_move.travel_per_frame * UNITS_PER_PIXEL
		if fighter.move_frame >= fighter.current_move.total_frames():
			fighter.current_move = null
			_set_state(fighter, FighterSimulation.State.IDLE)
		_tick_buffer(fighter)
		return

	if fighter.state == FighterSimulation.State.DASH:
		fighter.position.x += fighter.facing * fighter.dash_speed
		fighter.state_frame += 1
		if fighter.state_frame >= FighterSimulation.DASH_FRAMES:
			_set_state(fighter, FighterSimulation.State.IDLE)
		_tick_buffer(fighter)
		return

	if fighter.state == FighterSimulation.State.BACKDASH:
		fighter.position.x -= fighter.facing * fighter.backdash_speed
		fighter.state_frame += 1
		if fighter.state_frame >= FighterSimulation.BACKDASH_FRAMES:
			_set_state(fighter, FighterSimulation.State.IDLE)
		_tick_buffer(fighter)
		return

	if not fighter.is_grounded(GROUND_Y) or fighter.state == FighterSimulation.State.AIRBORNE:
		fighter.state = FighterSimulation.State.AIRBORNE
		fighter.velocity.y = mini(fighter.velocity.y + FighterSimulation.GRAVITY, FighterSimulation.MAX_FALL_SPEED)
		fighter.position += fighter.velocity
		if fighter.position.y >= GROUND_Y:
			fighter.position.y = GROUND_Y
			fighter.velocity = Vector2i.ZERO
			_set_state(fighter, FighterSimulation.State.IDLE)
		_tick_buffer(fighter)
		return

	if fighter.buffer_frames > 0 and fighter.can_start_attack():
		var action := fighter.buffered_attack
		var move: MoveDefinition = _move_for(fighter, action)
		if move != null and _can_start_action(fighter, action):
			_prepare_action(fighter, action)
			fighter.start_move(move)
			events.append({"type": &"attack_started", "fighter": fighter.fighter_id, "move": move.id})
			return

	if input.guard_held:
		_set_state(fighter, FighterSimulation.State.GUARD_STARTUP)
		return

	if input.dash_forward_pressed:
		_set_state(fighter, FighterSimulation.State.DASH)
		return

	if input.backdash_pressed:
		_set_state(fighter, FighterSimulation.State.BACKDASH)
		return

	if input.up:
		fighter.velocity.y = FighterSimulation.JUMP_SPEED
		_set_state(fighter, FighterSimulation.State.AIRBORNE)
		return

	if input.down:
		_set_state(fighter, FighterSimulation.State.CROUCH)
		_tick_buffer(fighter)
		return

	var axis := input.horizontal_axis()
	if axis != 0:
		var moving_forward := axis == fighter.facing
		var speed := fighter.walk_forward_speed if moving_forward else fighter.walk_back_speed
		fighter.position.x += axis * speed
		_set_state(fighter, FighterSimulation.State.WALK)
	else:
		_set_state(fighter, FighterSimulation.State.IDLE)

	_tick_buffer(fighter)


func _tick_buffer(fighter: FighterSimulation) -> void:
	if fighter.buffer_frames <= 0:
		return
	fighter.buffer_frames -= 1
	if fighter.buffer_frames == 0:
		fighter.buffered_attack = &""


func _resolve_attacks(input_one: FrameInput, input_two: FrameInput) -> void:
	var candidates: Array[Dictionary] = []
	_collect_attack_candidate(candidates, player, dummy, input_two, 1)
	_collect_attack_candidate(candidates, dummy, player, input_one, 2)
	_collect_delayed_candidate(candidates, player, dummy, input_two, 1, &"recall")
	_collect_delayed_candidate(candidates, dummy, player, input_one, 2, &"recall")
	_collect_delayed_candidate(candidates, player, dummy, input_two, 1, &"puppet")
	_collect_delayed_candidate(candidates, dummy, player, input_one, 2, &"puppet")

	for candidate in candidates:
		var attacker: FighterSimulation = candidate.attacker
		var defender: FighterSimulation = candidate.defender
		var source: StringName = candidate.get("source", &"move")
		if source == &"move" and attacker.move_has_hit:
			continue
		if source == &"recall" and attacker.recall_has_hit:
			continue
		if source == &"puppet" and attacker.puppet_has_hit:
			continue
		var move: MoveDefinition = candidate.move
		if source == &"move" and candidate.get("throw_tech", false) and (attacker.state != FighterSimulation.State.ATTACK or attacker.current_move != move):
			continue

		if source == &"move":
			attacker.move_has_hit = true
		elif source == &"recall":
			attacker.recall_has_hit = true
		else:
			attacker.puppet_has_hit = true
		if candidate.get("throw_tech", false):
			attacker.apply_throw_tech(-attacker.facing)
			defender.apply_throw_tech(attacker.facing)
			events.append({"type": &"throw_teched", "player": candidate.player})
			hitstop_frames = maxi(hitstop_frames, 6)
			continue
		var defender_was_attacking := defender.state == FighterSimulation.State.ATTACK
		if candidate.blocked:
			var covenant_guard := defender.state == FighterSimulation.State.GUARD
			defender.receive_block(move, attacker.facing, covenant_guard)
			events.append({"type": &"attack_blocked", "player": candidate.player, "move": move.id, "covenant_guard": covenant_guard})
		else:
			defender.receive_hit(move, attacker.facing)
			if move.id == &"xenon_laughing_chain":
				defender.velocity.x = -attacker.facing * 5 * UNITS_PER_PIXEL
			events.append({"type": &"hit_connected", "player": candidate.player, "move": move.id, "damage": move.damage})
		_apply_character_mechanic(attacker, move, candidate.blocked, defender_was_attacking)
		if candidate.blocked:
			attacker.gain_conviction(METER_GAIN_BLOCK)
			defender.gain_conviction(METER_GAIN_GUARD)
		else:
			attacker.gain_conviction(METER_GAIN_HIT)
			defender.gain_conviction(METER_GAIN_RECEIVED)
		events.append({"type": &"conviction_changed", "attacker": attacker.fighter_id, "attacker_value": attacker.conviction, "defender": defender.fighter_id, "defender_value": defender.conviction})
		hitstop_frames = maxi(hitstop_frames, move.hitstop)


func _move_for(fighter: FighterSimulation, action: StringName) -> MoveDefinition:
	var character_moves: Dictionary = move_sets.get(fighter.character_id, {})
	return character_moves.get(action)


func _apply_character_mechanic(
	attacker: FighterSimulation,
	move: MoveDefinition,
	was_blocked: bool,
	was_counter_hit: bool
) -> void:
	if attacker.character_id == &"izuna" and move.id == &"izuna_heavy" and not was_blocked:
		attacker.apply_memory_mark()
		events.append({"type": &"character_mechanic_changed", "fighter": attacker.fighter_id, "mechanic": &"memory_mark", "value": 1})
	elif attacker.character_id == &"xenon" and move.id == &"xenon_medium" and (was_blocked or was_counter_hit):
		attacker.grant_emotional_echo()
		events.append({"type": &"character_mechanic_changed", "fighter": attacker.fighter_id, "mechanic": &"emotional_echo", "value": attacker.emotional_echo_tokens})


func _collect_attack_candidate(
	candidates: Array[Dictionary],
	attacker: FighterSimulation,
	defender: FighterSimulation,
	defender_input: FrameInput,
	player_number: int
) -> void:
	if attacker.state != FighterSimulation.State.ATTACK or attacker.current_move == null:
		return
	if attacker.move_has_hit or not attacker.current_move.is_active(attacker.move_frame):
		return
	var attack_rect := attacker.attack_rect()
	if not attack_rect.has_area() or not attack_rect.intersects(defender.body_rect()):
		return
	if attacker.current_move.is_throw and not defender.is_grounded(GROUND_Y):
		return
	candidates.append({
		"attacker": attacker,
		"defender": defender,
		"move": attacker.current_move,
		"blocked": false if attacker.current_move.is_throw else _is_blocking(defender, defender_input),
		"throw_tech": attacker.current_move.is_throw and defender.throw_tech_frames > 0,
		"player": player_number,
		"source": &"move",
	})


func _collect_delayed_candidate(
	candidates: Array[Dictionary],
	attacker: FighterSimulation,
	defender: FighterSimulation,
	defender_input: FrameInput,
	player_number: int,
	source: StringName
) -> void:
	var effect_rect := attacker.recall_rect() if source == &"recall" else attacker.puppet_rect()
	var already_hit := attacker.recall_has_hit if source == &"recall" else attacker.puppet_has_hit
	if already_hit or not effect_rect.has_area() or not effect_rect.intersects(defender.body_rect()):
		return
	var action := &"recall_strike" if source == &"recall" else &"puppet_strike"
	var move := _move_for(attacker, action)
	if move == null:
		return
	candidates.append({
		"attacker": attacker,
		"defender": defender,
		"move": move,
		"blocked": _is_blocking(defender, defender_input),
		"player": player_number,
		"source": source,
	})


func _is_blocking(fighter: FighterSimulation, input: FrameInput) -> bool:
	if fighter.state == FighterSimulation.State.GUARD:
		return true
	if fighter.state not in [FighterSimulation.State.IDLE, FighterSimulation.State.WALK, FighterSimulation.State.CROUCH, FighterSimulation.State.BLOCKSTUN]:
		return false
	var holding_away := input.horizontal_axis() == -fighter.facing
	return holding_away


func _can_start_action(fighter: FighterSimulation, action: StringName) -> bool:
	if action == &"conquer_art":
		return fighter.conviction >= FighterSimulation.CONVICTION_BAR
	if action == &"ultimate":
		return fighter.conviction >= FighterSimulation.CONVICTION_MAX
	if fighter.character_id == &"xenon" and action == &"special_down":
		return fighter.emotional_echo_tokens > 0 and fighter.puppet_delay_frames == 0 and fighter.puppet_active_frames == 0
	return true


func _can_cancel(move: MoveDefinition, action: StringName) -> bool:
	var move_id := str(move.id)
	var is_special := str(action).begins_with("special_")
	if move_id.ends_with("_light"):
		return action == &"medium" or is_special
	if move_id.ends_with("_medium"):
		return action == &"heavy" or is_special
	if move_id.ends_with("_heavy"):
		return is_special
	return false


func _prepare_action(fighter: FighterSimulation, action: StringName) -> void:
	if action == &"ultimate":
		fighter.spend_conviction(FighterSimulation.CONVICTION_MAX)
		events.append({"type": &"ultimate_started", "fighter": fighter.fighter_id})
	elif action == &"conquer_art" and fighter.spend_conviction(FighterSimulation.CONVICTION_BAR):
		if fighter.character_id == &"izuna":
			fighter.consume_memory_mark_for_recall(true)
			events.append({"type": &"delayed_effect_started", "fighter": fighter.fighter_id, "effect": &"recall"})
		else:
			fighter.consume_echo_for_puppet(true)
			events.append({"type": &"delayed_effect_started", "fighter": fighter.fighter_id, "effect": &"puppet"})
		events.append({"type": &"conquer_art_started", "fighter": fighter.fighter_id})
	elif fighter.character_id == &"izuna" and action == &"special_neutral" and fighter.consume_memory_mark_for_recall():
		events.append({"type": &"character_mechanic_changed", "fighter": fighter.fighter_id, "mechanic": &"memory_mark", "value": 0})
		events.append({"type": &"delayed_effect_started", "fighter": fighter.fighter_id, "effect": &"recall"})
	elif fighter.character_id == &"xenon" and action == &"special_down" and fighter.consume_echo_for_puppet():
		events.append({"type": &"character_mechanic_changed", "fighter": fighter.fighter_id, "mechanic": &"emotional_echo", "value": 0})
		events.append({"type": &"delayed_effect_started", "fighter": fighter.fighter_id, "effect": &"puppet"})


func _handle_resource_input(fighter: FighterSimulation, opponent: FighterSimulation, input: FrameInput) -> void:
	if not input.resource_pressed:
		return
	if fighter.state in [FighterSimulation.State.HITSTUN, FighterSimulation.State.BLOCKSTUN] and fighter.burst_available:
		fighter.burst_available = false
		fighter.current_move = null
		fighter.buffered_attack = &""
		fighter.buffer_frames = 0
		fighter.state = FighterSimulation.State.BURST
		fighter.state_frame = FighterSimulation.BURST_RECOVERY_FRAMES
		if absi(opponent.position.x - fighter.position.x) <= BURST_RANGE:
			opponent.receive_burst(fighter.facing)
		events.append({"type": &"burst_activated", "fighter": fighter.fighter_id})
		return
	if fighter.state == FighterSimulation.State.ATTACK and fighter.current_move != null:
		var can_shift := fighter.current_move.phase_at(fighter.move_frame) == &"recovery" and not fighter.current_move.is_throw
		if can_shift and fighter.spend_conviction(FighterSimulation.CONVICTION_BAR):
			fighter.current_move = null
			fighter.move_frame = 0
			fighter.move_has_hit = false
			_set_state(fighter, FighterSimulation.State.IDLE)
			events.append({"type": &"shift_cancel", "fighter": fighter.fighter_id})
		return
	if fighter.can_start_attack() and fighter.conviction >= FighterSimulation.CONVICTION_BAR:
		fighter.queue_attack(&"conquer_art")


func _resolve_pushboxes() -> void:
	var player_box := player.body_rect()
	var dummy_box := dummy.body_rect()
	if not player_box.intersects(dummy_box):
		return
	var overlap := mini(player_box.end.x, dummy_box.end.x) - maxi(player_box.position.x, dummy_box.position.x)
	if overlap <= 0:
		return
	var left_push := overlap / 2
	var right_push := overlap - left_push
	if player.position.x <= dummy.position.x:
		player.position.x -= left_push
		dummy.position.x += right_push
	else:
		player.position.x += right_push
		dummy.position.x -= left_push
	_resolve_stage_bounds(player)
	_resolve_stage_bounds(dummy)


func _resolve_stage_bounds(fighter: FighterSimulation) -> void:
	fighter.position.x = clampi(fighter.position.x, STAGE_LEFT, STAGE_RIGHT)
	fighter.position.y = mini(fighter.position.y, GROUND_Y)


func _update_facing() -> void:
	if player.state == FighterSimulation.State.ATTACK or dummy.state == FighterSimulation.State.ATTACK:
		return
	if player.position.x < dummy.position.x:
		player.facing = 1
		dummy.facing = -1
	elif player.position.x > dummy.position.x:
		player.facing = -1
		dummy.facing = 1


func _evaluate_round_end() -> void:
	if player.health > 0 and dummy.health > 0 and round_timer_frames > 0:
		return
	var winner := 0
	if player.health > dummy.health:
		winner = 1
	elif dummy.health > player.health:
		winner = 2
	_finish_round(winner)


func _finish_round(winner: int) -> void:
	match_state = MatchState.ROUND_OVER
	round_winner = winner
	round_over_frames = ROUND_OVER_FRAMES
	if winner == 1:
		player.rounds_won += 1
	elif winner == 2:
		dummy.rounds_won += 1
	events.append({"type": &"round_ended", "winner": winner})


func _tick_round_flow() -> void:
	if match_state == MatchState.MATCH_OVER:
		return
	round_over_frames -= 1
	if round_over_frames > 0:
		return
	if player.rounds_won >= 2 or dummy.rounds_won >= 2:
		match_state = MatchState.MATCH_OVER
		events.append({"type": &"match_ended", "winner": 1 if player.rounds_won > dummy.rounds_won else 2})
		return
	round_number += 1
	round_winner = 0
	round_timer_frames = ROUND_TIME_FRAMES
	hitstop_frames = 0
	player.reset_for_round(Vector2i(350 * UNITS_PER_PIXEL, GROUND_Y))
	dummy.reset_for_round(Vector2i(830 * UNITS_PER_PIXEL, GROUND_Y))
	_update_facing()
	match_state = MatchState.FIGHTING
	events.append({"type": &"round_started", "round": round_number})


func _set_state(fighter: FighterSimulation, next_state: FighterSimulation.State) -> void:
	if fighter.state == next_state:
		fighter.state_frame += 1
		return
	fighter.state = next_state
	fighter.state_frame = 0
