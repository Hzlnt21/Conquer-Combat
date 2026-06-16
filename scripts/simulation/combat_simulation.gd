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

var frame := 0
var hitstop_frames := 0
var player: FighterSimulation
var dummy: FighterSimulation
var moves: Dictionary[StringName, MoveDefinition] = {}
var events: Array[Dictionary] = []
var match_state := MatchState.FIGHTING
var round_number := 1
var round_timer_frames := ROUND_TIME_FRAMES
var round_over_frames := 0
var round_winner := 0


func _init() -> void:
	moves[&"light"] = MoveDefinition.new(&"light", 5, 3, 10, 40, 5, 12, 72, 118, 2)
	moves[&"medium"] = MoveDefinition.new(&"medium", 9, 4, 15, 70, 7, 17, 108, 132, 4)
	moves[&"heavy"] = MoveDefinition.new(&"heavy", 14, 5, 22, 110, 9, 24, 148, 150, 8, true)
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
	player = FighterSimulation.new(&"izuna_p1", Vector2i(350 * UNITS_PER_PIXEL, GROUND_Y))
	dummy = FighterSimulation.new(&"izuna_p2", Vector2i(830 * UNITS_PER_PIXEL, GROUND_Y))
	_update_facing()


func tick(input_one: FrameInput, input_two: FrameInput = null) -> void:
	if input_two == null:
		input_two = FrameInput.new()

	events.clear()
	frame += 1

	if match_state != MatchState.FIGHTING:
		_tick_round_flow()
		return

	if hitstop_frames > 0:
		hitstop_frames -= 1
		return

	round_timer_frames = maxi(0, round_timer_frames - 1)
	_capture_attack_input(player, input_one)
	_capture_attack_input(dummy, input_two)
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


func _capture_attack_input(fighter: FighterSimulation, input: FrameInput) -> void:
	if input.light_pressed:
		fighter.queue_attack(&"light")
	elif input.medium_pressed:
		fighter.queue_attack(&"medium")
	elif input.heavy_pressed:
		fighter.queue_attack(&"heavy")


func _tick_fighter(fighter: FighterSimulation, input: FrameInput) -> void:
	if fighter.state == FighterSimulation.State.KO:
		return

	if fighter.state in [FighterSimulation.State.HITSTUN, FighterSimulation.State.BLOCKSTUN]:
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

	if fighter.state == FighterSimulation.State.ATTACK:
		fighter.move_frame += 1
		if fighter.move_frame >= fighter.current_move.total_frames():
			fighter.current_move = null
			_set_state(fighter, FighterSimulation.State.IDLE)
		_tick_buffer(fighter)
		return

	if fighter.state == FighterSimulation.State.DASH:
		fighter.position.x += fighter.facing * FighterSimulation.DASH_SPEED
		fighter.state_frame += 1
		if fighter.state_frame >= FighterSimulation.DASH_FRAMES:
			_set_state(fighter, FighterSimulation.State.IDLE)
		_tick_buffer(fighter)
		return

	if fighter.state == FighterSimulation.State.BACKDASH:
		fighter.position.x -= fighter.facing * FighterSimulation.BACKDASH_SPEED
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
		var move: MoveDefinition = moves.get(fighter.buffered_attack)
		if move != null:
			fighter.start_move(move)
			events.append({"type": &"attack_started", "fighter": fighter.fighter_id, "move": move.id})
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
		var speed := FighterSimulation.WALK_FORWARD_SPEED if moving_forward else FighterSimulation.WALK_BACK_SPEED
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

	for candidate in candidates:
		var attacker: FighterSimulation = candidate.attacker
		var defender: FighterSimulation = candidate.defender
		if attacker.move_has_hit:
			continue

		attacker.move_has_hit = true
		var move: MoveDefinition = candidate.move
		if candidate.blocked:
			defender.receive_block(move, attacker.facing)
			events.append({"type": &"attack_blocked", "player": candidate.player, "move": move.id})
		else:
			defender.receive_hit(move, attacker.facing)
			events.append({"type": &"hit_connected", "player": candidate.player, "move": move.id, "damage": move.damage})
		hitstop_frames = maxi(hitstop_frames, move.hitstop)


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
	candidates.append({
		"attacker": attacker,
		"defender": defender,
		"move": attacker.current_move,
		"blocked": _is_blocking(defender, defender_input),
		"player": player_number,
	})


func _is_blocking(fighter: FighterSimulation, input: FrameInput) -> bool:
	if fighter.state not in [FighterSimulation.State.IDLE, FighterSimulation.State.WALK, FighterSimulation.State.CROUCH, FighterSimulation.State.BLOCKSTUN]:
		return false
	var holding_away := input.horizontal_axis() == -fighter.facing
	return holding_away


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
