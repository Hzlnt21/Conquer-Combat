class_name BasicCpuController
extends RefCounted

enum Difficulty {
	EASY,
	NORMAL,
	HARD,
}

const DEFAULT_SEED := 0xC0A73

var difficulty := Difficulty.NORMAL
var rng := RandomNumberGenerator.new()
var decision_cooldown := 0
var movement_frames := 0
var guard_frames := 0
var movement_direction := 0


func _init(level := Difficulty.NORMAL, seed := DEFAULT_SEED) -> void:
	difficulty = level
	reset(seed)


func reset(seed := DEFAULT_SEED) -> void:
	rng.seed = seed
	decision_cooldown = 0
	movement_frames = 0
	guard_frames = 0
	movement_direction = 0


func next_input(simulation: CombatSimulation, fighter: FighterSimulation, opponent: FighterSimulation) -> FrameInput:
	var result := FrameInput.new()
	if simulation.match_state != CombatSimulation.MatchState.FIGHTING or fighter.state == FighterSimulation.State.KO:
		return result

	if fighter.state in [FighterSimulation.State.HITSTUN, FighterSimulation.State.BLOCKSTUN]:
		if _should_burst(fighter):
			result.resource_pressed = true
		return result

	if fighter.state == FighterSimulation.State.ATTACK:
		if fighter.current_move != null and fighter.current_move.phase_at(fighter.move_frame) == &"recovery":
			var shift_chance := 0.08 + 0.08 * difficulty
			if fighter.conviction >= FighterSimulation.CONVICTION_BAR and not fighter.current_move.is_throw and rng.randf() < shift_chance:
				result.resource_pressed = true
		return result

	if guard_frames > 0:
		guard_frames -= 1
		result.guard_held = true
		return result

	if movement_frames > 0:
		movement_frames -= 1
		_set_horizontal(result, movement_direction)
		return result

	if not fighter.can_start_attack():
		return result

	if decision_cooldown > 0:
		decision_cooldown -= 1
		return result

	decision_cooldown = _reaction_frames()
	var distance := absi(opponent.position.x - fighter.position.x) / CombatSimulation.UNITS_PER_PIXEL
	var opponent_threatening := opponent.state == FighterSimulation.State.ATTACK and distance <= 260
	if opponent_threatening and rng.randf() < _defense_chance():
		guard_frames = 12 + difficulty * 4
		result.guard_held = true
		return result

	var roll := rng.randf()
	if distance > 320:
		if roll > 0.72:
			result.dash_forward_pressed = true
		else:
			movement_direction = fighter.facing
			movement_frames = _reaction_frames() + 4
			_set_horizontal(result, movement_direction)
		return result

	if distance > 150:
		if fighter.conviction >= FighterSimulation.CONVICTION_MAX and roll < 0.10 + 0.04 * difficulty:
			result.ultimate_pressed = true
		elif fighter.conviction >= FighterSimulation.CONVICTION_BAR and roll < 0.24:
			result.resource_pressed = true
		elif roll < 0.58:
			result.special_pressed = true
			if rng.randf() < 0.45:
				_set_horizontal(result, fighter.facing)
		elif roll < 0.82:
			result.medium_pressed = true
		else:
			movement_direction = fighter.facing
			movement_frames = _reaction_frames()
			_set_horizontal(result, movement_direction)
		return result

	if fighter.conviction >= FighterSimulation.CONVICTION_MAX and roll < 0.14 + 0.04 * difficulty:
		result.ultimate_pressed = true
	elif roll < 0.25:
		result.throw_pressed = true
	elif roll < 0.62:
		result.light_pressed = true
	elif roll < 0.79:
		result.heavy_pressed = true
	elif roll < 0.90:
		guard_frames = 10 + difficulty * 4
		result.guard_held = true
	else:
		result.backdash_pressed = true
	return result


func difficulty_name() -> String:
	return Difficulty.keys()[difficulty].capitalize()


func _reaction_frames() -> int:
	match difficulty:
		Difficulty.EASY:
			return 18
		Difficulty.HARD:
			return 6
		_:
			return 10


func _defense_chance() -> float:
	match difficulty:
		Difficulty.EASY:
			return 0.38
		Difficulty.HARD:
			return 0.86
		_:
			return 0.64


func _should_burst(fighter: FighterSimulation) -> bool:
	if not fighter.burst_available:
		return false
	match difficulty:
		Difficulty.EASY:
			return fighter.health <= 280 and rng.randf() < 0.32
		Difficulty.HARD:
			return fighter.health <= 760
		_:
			return fighter.health <= 560 and rng.randf() < 0.68


func _set_horizontal(input: FrameInput, direction: int) -> void:
	input.left = direction < 0
	input.right = direction > 0
