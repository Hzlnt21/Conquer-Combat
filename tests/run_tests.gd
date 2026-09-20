extends SceneTree

var failures := 0
var assertions := 0


func _init() -> void:
	_test_light_attack_timing_and_single_hit()
	_test_pushbox_resolution()
	_test_forward_dash_moves_fighter()
	_test_player_two_can_attack()
	_test_holding_away_blocks()
	_test_heavy_causes_knockdown()
	_test_round_win_and_restart()
	_test_timeout_uses_remaining_health()
	_test_simultaneous_hit_can_double_ko()
	_test_reset_restores_match_state()
	_test_roster_uses_distinct_characters()
	_test_izuna_heavy_applies_memory_mark()
	_test_knockdown_clears_character_mechanic()
	_test_xenon_medium_block_grants_echo()
	_test_character_mechanics_expire()
	_test_izuna_special_selection()
	_test_xenon_special_selection_and_puppet_requirement()
	_test_recall_consumes_mark_and_hits_later()
	_test_puppet_consumes_echo_and_hits_later()
	_test_puppet_is_cancelled_when_xenon_is_hit()
	_test_laughing_chain_pulls_on_hit()
	_test_foxfire_step_moves_forward()
	_test_izuna_basic_cancel_route()
	_test_xenon_basic_cancel_route()
	_test_covenant_guard_startup_and_recovery()
	_test_covenant_guard_reduces_blockstun_and_pushback()
	_test_throw_defeats_block_and_causes_knockdown()
	_test_throw_can_be_teched()
	_test_throw_misses_airborne_opponent()
	_test_throw_whiff_has_recovery()
	_test_training_resets()
	_test_conviction_gain_and_cap()
	_test_conquer_arts_consume_meter_and_start_mechanics()
	_test_shift_cancel_spends_meter_during_recovery()
	_test_burst_escapes_stun_once_per_round()
	_test_ultimate_requires_and_consumes_full_meter()
	_test_round_reset_restores_universal_resources()
	_test_cpu_is_deterministic_for_the_same_seed()
	_test_cpu_closes_distance_and_can_deal_damage()
	_test_hard_cpu_uses_burst_under_pressure()
	_test_hard_cpu_reads_and_techs_an_incoming_throw()
	_test_cpu_match_reaches_a_deterministic_conclusion()
	_test_cpu_is_neutral_outside_active_rounds()

	if failures == 0:
		print("PASS: %d assertions" % assertions)
		quit(0)
	else:
		push_error("FAIL: %d of %d assertions failed" % [failures, assertions])
		quit(1)


func _test_light_attack_timing_and_single_hit() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 450 * CombatSimulation.UNITS_PER_PIXEL

	var attack_input := FrameInput.new()
	attack_input.light_pressed = true
	simulation.tick(attack_input)
	_expect(simulation.player.state == FighterSimulation.State.ATTACK, "Light input starts attack")
	_expect(simulation.player.move_frame == 0, "Attack starts at frame zero")

	for _index in range(4):
		simulation.tick(FrameInput.new())
	_expect(simulation.dummy.health == 1000, "Light does not hit during startup")

	simulation.tick(FrameInput.new())
	_expect(simulation.player.move_frame == 5, "Light reaches active frame five")
	_expect(simulation.dummy.health == 960, "Light deals expected damage on first active frame")

	for _index in range(12):
		simulation.tick(FrameInput.new())
	_expect(simulation.dummy.health == 960, "One attack instance hits only once")


func _test_pushbox_resolution() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 500 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 540 * CombatSimulation.UNITS_PER_PIXEL
	simulation.tick(FrameInput.new())
	_expect(not simulation.player.body_rect().intersects(simulation.dummy.body_rect()), "Pushboxes resolve overlap")


func _test_forward_dash_moves_fighter() -> void:
	var simulation := CombatSimulation.new()
	var start_x := simulation.player.position.x
	var dash_input := FrameInput.new()
	dash_input.dash_forward_pressed = true
	simulation.tick(dash_input)
	for _index in range(FighterSimulation.DASH_FRAMES):
		simulation.tick(FrameInput.new())
	_expect(simulation.player.position.x > start_x, "Forward dash moves fighter toward opponent")
	_expect(simulation.player.state == FighterSimulation.State.IDLE, "Forward dash returns to idle")


func _test_player_two_can_attack() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 730 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 830 * CombatSimulation.UNITS_PER_PIXEL
	var player_two_attack := FrameInput.new()
	player_two_attack.light_pressed = true
	simulation.tick(FrameInput.new(), player_two_attack)
	for _index in range(6):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.health == 965, "Xenon light uses character-specific damage")


func _test_holding_away_blocks() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 450 * CombatSimulation.UNITS_PER_PIXEL
	var attack := FrameInput.new()
	attack.light_pressed = true
	var block := FrameInput.new()
	block.right = true
	simulation.tick(attack, block)
	for _index in range(5):
		simulation.tick(FrameInput.new(), block)
	_expect(simulation.dummy.health == 1000, "Holding away prevents normal damage")
	_expect(simulation.dummy.state == FighterSimulation.State.BLOCKSTUN, "Blocked attack enters blockstun")


func _test_heavy_causes_knockdown() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 480 * CombatSimulation.UNITS_PER_PIXEL
	var attack := FrameInput.new()
	attack.heavy_pressed = true
	simulation.tick(attack)
	for _index in range(14):
		simulation.tick(FrameInput.new())
	_expect(simulation.dummy.state == FighterSimulation.State.KNOCKDOWN, "Heavy attack causes knockdown")


func _test_round_win_and_restart() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 450 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.health = 40
	var attack := FrameInput.new()
	attack.light_pressed = true
	simulation.tick(attack)
	for _index in range(5):
		simulation.tick(FrameInput.new())
	_expect(simulation.match_state == CombatSimulation.MatchState.ROUND_OVER, "KO ends the round")
	_expect(simulation.player.rounds_won == 1, "Round winner receives one point")
	for _index in range(CombatSimulation.ROUND_OVER_FRAMES):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.match_state == CombatSimulation.MatchState.FIGHTING, "Next round starts automatically")
	_expect(simulation.round_number == 2, "Round counter advances")
	_expect(simulation.player.health == 1000 and simulation.dummy.health == 1000, "New round restores health")


func _test_timeout_uses_remaining_health() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.health = 900
	simulation.dummy.health = 800
	simulation.round_timer_frames = 1
	simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.match_state == CombatSimulation.MatchState.ROUND_OVER, "Timer reaching zero ends round")
	_expect(simulation.round_winner == 1, "Higher health wins on timeout")


func _test_simultaneous_hit_can_double_ko() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 500 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 576 * CombatSimulation.UNITS_PER_PIXEL
	simulation.player.health = 35
	simulation.dummy.health = 35
	var player_one_attack := FrameInput.new()
	var player_two_attack := FrameInput.new()
	player_two_attack.light_pressed = true
	simulation.tick(FrameInput.new(), player_two_attack)
	player_one_attack.light_pressed = true
	simulation.tick(player_one_attack, FrameInput.new())
	for _index in range(5):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.health == 0 and simulation.dummy.health == 0, "Simultaneous active hits can double KO")
	_expect(simulation.round_winner == 0, "Double KO records a draw")


func _test_reset_restores_match_state() -> void:
	var simulation := CombatSimulation.new()
	simulation.dummy.health = 200
	simulation.frame = 55
	simulation.reset()
	_expect(simulation.frame == 0, "Reset clears frame counter")
	_expect(simulation.dummy.health == 1000, "Reset restores dummy health")
	_expect(simulation.player.position.x < simulation.dummy.position.x, "Reset restores starting positions")


func _test_roster_uses_distinct_characters() -> void:
	var simulation := CombatSimulation.new()
	_expect(simulation.player.character_id == &"izuna", "Player one uses Izuna character data")
	_expect(simulation.dummy.character_id == &"xenon", "Player two uses Xenon character data")
	_expect(simulation.player.walk_forward_speed > simulation.dummy.walk_forward_speed, "Izuna walks forward faster than Xenon")


func _test_izuna_heavy_applies_memory_mark() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 480 * CombatSimulation.UNITS_PER_PIXEL
	var attack := FrameInput.new()
	attack.heavy_pressed = true
	simulation.tick(attack)
	for _index in range(14):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.memory_mark_frames == FighterSimulation.MEMORY_MARK_DURATION, "Izuna heavy applies a full Memory Mark")


func _test_knockdown_clears_character_mechanic() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.apply_memory_mark()
	simulation.player.position.x = 700 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 830 * CombatSimulation.UNITS_PER_PIXEL
	var attack := FrameInput.new()
	attack.heavy_pressed = true
	simulation.tick(FrameInput.new(), attack)
	for _index in range(16):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.KNOCKDOWN, "Xenon heavy knocks Izuna down")
	_expect(simulation.player.memory_mark_frames == 0, "Knockdown clears Izuna Memory Mark")


func _test_xenon_medium_block_grants_echo() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 690 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 830 * CombatSimulation.UNITS_PER_PIXEL
	var block := FrameInput.new()
	block.left = true
	var attack := FrameInput.new()
	attack.medium_pressed = true
	simulation.tick(block, attack)
	for _index in range(10):
		simulation.tick(block, FrameInput.new())
	_expect(simulation.player.health == 1000, "Izuna blocks Xenon medium")
	_expect(simulation.dummy.emotional_echo_tokens == 1, "Blocked Xenon medium grants Emotional Echo")
	_expect(simulation.dummy.emotional_echo_frames == FighterSimulation.EMOTIONAL_ECHO_DURATION, "Emotional Echo starts at full duration")


func _test_character_mechanics_expire() -> void:
	var izuna := FighterSimulation.new(&"izuna_test", Vector2i.ZERO, &"izuna")
	var xenon := FighterSimulation.new(&"xenon_test", Vector2i.ZERO, &"xenon")
	izuna.apply_memory_mark()
	xenon.grant_emotional_echo()
	for _index in range(FighterSimulation.EMOTIONAL_ECHO_DURATION):
		izuna.tick_character_mechanic()
		xenon.tick_character_mechanic()
	_expect(izuna.memory_mark_frames == 0, "Memory Mark expires after its duration")
	_expect(xenon.emotional_echo_tokens == 0, "Emotional Echo token expires after its duration")


func _test_izuna_special_selection() -> void:
	var simulation := CombatSimulation.new()
	var special := FrameInput.new()
	special.special_pressed = true
	simulation.tick(special, FrameInput.new())
	_expect(simulation.player.current_move.id == &"izuna_recall_slash", "Neutral Special selects Recall Slash")

	simulation.reset()
	var forward_special := FrameInput.new()
	forward_special.right = true
	forward_special.special_pressed = true
	simulation.tick(forward_special, FrameInput.new())
	_expect(simulation.player.current_move.id == &"izuna_foxfire_step", "Forward Special selects Foxfire Step")

	simulation.reset()
	var down_special := FrameInput.new()
	down_special.down = true
	down_special.special_pressed = true
	simulation.tick(down_special, FrameInput.new())
	_expect(simulation.player.current_move.id == &"izuna_memory_break", "Down Special selects Memory Break")


func _test_xenon_special_selection_and_puppet_requirement() -> void:
	var simulation := CombatSimulation.new()
	var neutral_special := FrameInput.new()
	neutral_special.special_pressed = true
	simulation.tick(FrameInput.new(), neutral_special)
	_expect(simulation.dummy.current_move.id == &"xenon_laughing_chain", "Xenon Neutral Special selects Laughing Chain")

	simulation.reset()
	var forward_special := FrameInput.new()
	forward_special.left = true
	forward_special.special_pressed = true
	simulation.tick(FrameInput.new(), forward_special)
	_expect(simulation.dummy.current_move.id == &"xenon_mocking_step", "Xenon Forward Special selects Mocking Step")

	simulation.reset()
	var down_special := FrameInput.new()
	down_special.down = true
	down_special.special_pressed = true
	simulation.tick(FrameInput.new(), down_special)
	_expect(simulation.dummy.current_move == null, "Despair Puppet cannot start without Emotional Echo")

	simulation.reset()
	simulation.dummy.grant_emotional_echo()
	simulation.tick(FrameInput.new(), down_special)
	_expect(simulation.dummy.current_move.id == &"xenon_despair_puppet", "Emotional Echo enables Despair Puppet")
	_expect(simulation.dummy.emotional_echo_tokens == 0, "Despair Puppet consumes Emotional Echo")


func _test_recall_consumes_mark_and_hits_later() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 580 * CombatSimulation.UNITS_PER_PIXEL
	simulation.player.apply_memory_mark()
	var special := FrameInput.new()
	special.special_pressed = true
	simulation.tick(special, FrameInput.new())
	_expect(simulation.player.memory_mark_frames == 0, "Recall Slash consumes Memory Mark")
	_expect(simulation.dummy.health == 1000, "Recall delayed strike does not hit immediately")
	for _index in range(FighterSimulation.RECALL_DELAY_FRAMES):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.dummy.health == 955, "Recall delayed strike deals its own damage")


func _test_puppet_consumes_echo_and_hits_later() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 650 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 830 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.grant_emotional_echo()
	var special := FrameInput.new()
	special.down = true
	special.special_pressed = true
	simulation.tick(FrameInput.new(), special)
	_expect(simulation.player.health == 1000, "Despair Puppet does not hit during summon")
	for _index in range(FighterSimulation.PUPPET_DELAY_FRAMES):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.health == 945, "Despair Puppet performs a delayed fixed strike")


func _test_puppet_is_cancelled_when_xenon_is_hit() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 730 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 830 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.grant_emotional_echo()
	var puppet := FrameInput.new()
	puppet.down = true
	puppet.special_pressed = true
	simulation.tick(FrameInput.new(), puppet)
	var attack := FrameInput.new()
	attack.light_pressed = true
	simulation.tick(attack, FrameInput.new())
	for _index in range(5):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.dummy.health == 960, "Izuna can interrupt Xenon's puppet setup")
	_expect(simulation.dummy.puppet_delay_frames == 0, "Taking a hit removes pending Despair Puppet")


func _test_laughing_chain_pulls_on_hit() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 650 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 830 * CombatSimulation.UNITS_PER_PIXEL
	var special := FrameInput.new()
	special.special_pressed = true
	simulation.tick(FrameInput.new(), special)
	for _index in range(14):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.health == 915, "Laughing Chain deals expected damage")
	_expect(simulation.player.velocity.x > 0, "Laughing Chain pulls the opponent toward Xenon")


func _test_foxfire_step_moves_forward() -> void:
	var simulation := CombatSimulation.new()
	var start_x := simulation.player.position.x
	var special := FrameInput.new()
	special.right = true
	special.special_pressed = true
	simulation.tick(special, FrameInput.new())
	for _index in range(4):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.position.x > start_x, "Foxfire Step travels toward the opponent")


func _test_izuna_basic_cancel_route() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 450 * CombatSimulation.UNITS_PER_PIXEL
	var light := FrameInput.new()
	light.light_pressed = true
	simulation.tick(light, FrameInput.new())
	for _index in range(5):
		simulation.tick(FrameInput.new(), FrameInput.new())

	var medium := FrameInput.new()
	medium.medium_pressed = true
	simulation.tick(medium, FrameInput.new())
	for _index in range(4):
		simulation.tick(FrameInput.new(), FrameInput.new())
	simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.current_move.id == &"izuna_medium", "Izuna cancels Light into Medium")

	for _index in range(9):
		simulation.tick(FrameInput.new(), FrameInput.new())
	var heavy := FrameInput.new()
	heavy.heavy_pressed = true
	simulation.tick(heavy, FrameInput.new())
	for _index in range(6):
		simulation.tick(FrameInput.new(), FrameInput.new())
	simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.current_move.id == &"izuna_heavy", "Izuna cancels Medium into Heavy")

	for _index in range(14):
		simulation.tick(FrameInput.new(), FrameInput.new())
	var special := FrameInput.new()
	special.special_pressed = true
	simulation.tick(special, FrameInput.new())
	for _index in range(8):
		simulation.tick(FrameInput.new(), FrameInput.new())
	simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.current_move.id == &"izuna_recall_slash", "Izuna cancels Heavy into Recall Slash")
	_expect(simulation.player.memory_mark_frames == 0, "Izuna route consumes its newly applied Memory Mark")


func _test_xenon_basic_cancel_route() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 730 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 830 * CombatSimulation.UNITS_PER_PIXEL
	var light := FrameInput.new()
	light.light_pressed = true
	simulation.tick(FrameInput.new(), light)
	for _index in range(6):
		simulation.tick(FrameInput.new(), FrameInput.new())

	var medium := FrameInput.new()
	medium.medium_pressed = true
	simulation.tick(FrameInput.new(), medium)
	for _index in range(4):
		simulation.tick(FrameInput.new(), FrameInput.new())
	simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.dummy.current_move.id == &"xenon_medium", "Xenon cancels Light into Medium")

	for _index in range(10):
		simulation.tick(FrameInput.new(), FrameInput.new())
	var heavy := FrameInput.new()
	heavy.heavy_pressed = true
	simulation.tick(FrameInput.new(), heavy)
	for _index in range(6):
		simulation.tick(FrameInput.new(), FrameInput.new())
	simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.dummy.current_move.id == &"xenon_heavy", "Xenon cancels Medium into Heavy")

	for _index in range(16):
		simulation.tick(FrameInput.new(), FrameInput.new())
	var special := FrameInput.new()
	special.special_pressed = true
	simulation.tick(FrameInput.new(), special)
	for _index in range(8):
		simulation.tick(FrameInput.new(), FrameInput.new())
	simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.dummy.current_move.id == &"xenon_laughing_chain", "Xenon cancels Heavy into Laughing Chain")


func _test_covenant_guard_startup_and_recovery() -> void:
	var simulation := CombatSimulation.new()
	var guard := FrameInput.new()
	guard.guard_held = true
	simulation.tick(guard, FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.GUARD_STARTUP, "Covenant Guard begins with startup")
	for _index in range(FighterSimulation.GUARD_STARTUP_FRAMES):
		simulation.tick(guard, FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.GUARD, "Holding Guard reaches active stance")
	simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.GUARD_RECOVERY, "Releasing Guard begins recovery")
	for _index in range(FighterSimulation.GUARD_RECOVERY_FRAMES):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.IDLE, "Guard recovery returns to idle")


func _test_covenant_guard_reduces_blockstun_and_pushback() -> void:
	var normal := CombatSimulation.new()
	normal.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	normal.dummy.position.x = 450 * CombatSimulation.UNITS_PER_PIXEL
	var attack := FrameInput.new()
	attack.light_pressed = true
	var away := FrameInput.new()
	away.right = true
	normal.tick(attack, away)
	for _index in range(5):
		normal.tick(FrameInput.new(), away)
	var normal_stun := normal.dummy.state_frame
	var normal_pushback := absi(normal.dummy.velocity.x)

	var guarded := CombatSimulation.new()
	guarded.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	guarded.dummy.position.x = 450 * CombatSimulation.UNITS_PER_PIXEL
	var guard := FrameInput.new()
	guard.guard_held = true
	guarded.tick(FrameInput.new(), guard)
	for _index in range(FighterSimulation.GUARD_STARTUP_FRAMES):
		guarded.tick(FrameInput.new(), guard)
	guarded.tick(attack, guard)
	for _index in range(5):
		guarded.tick(FrameInput.new(), guard)
	_expect(guarded.dummy.health == 1000, "Active Covenant Guard blocks incoming strikes")
	_expect(guarded.dummy.state_frame < normal_stun, "Covenant Guard reduces blockstun")
	_expect(absi(guarded.dummy.velocity.x) < normal_pushback, "Covenant Guard reduces pushback")


func _test_throw_defeats_block_and_causes_knockdown() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 440 * CombatSimulation.UNITS_PER_PIXEL
	var guard := FrameInput.new()
	guard.guard_held = true
	simulation.tick(FrameInput.new(), guard)
	for _index in range(FighterSimulation.GUARD_STARTUP_FRAMES):
		simulation.tick(FrameInput.new(), guard)
	_expect(simulation.dummy.state == FighterSimulation.State.GUARD, "Defender has active Covenant Guard before throw")
	var throw_input := FrameInput.new()
	throw_input.throw_pressed = true
	simulation.tick(throw_input, guard)
	for _index in range(6):
		simulation.tick(FrameInput.new(), guard)
	_expect(simulation.dummy.health == 880, "Throw bypasses Covenant Guard")
	_expect(simulation.dummy.state == FighterSimulation.State.KNOCKDOWN, "Throw causes soft knockdown")


func _test_throw_can_be_teched() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 500 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 565 * CombatSimulation.UNITS_PER_PIXEL
	var player_throw := FrameInput.new()
	var dummy_throw := FrameInput.new()
	player_throw.throw_pressed = true
	dummy_throw.throw_pressed = true
	simulation.tick(player_throw, dummy_throw)
	for _index in range(6):
		simulation.tick(FrameInput.new(), FrameInput.new())
	var emitted_tech := false
	for event in simulation.events:
		if event.get("type", &"") == &"throw_teched":
			emitted_tech = true
	_expect(simulation.player.health == 1000 and simulation.dummy.health == 1000, "Throw Tech prevents throw damage")
	_expect(simulation.player.state == FighterSimulation.State.THROW_TECH, "Thrower enters Throw Tech recovery")
	_expect(simulation.dummy.state == FighterSimulation.State.THROW_TECH, "Defender enters Throw Tech recovery")
	_expect(emitted_tech, "Throw Tech emits a presentation event")
	for _index in range(FighterSimulation.THROW_TECH_RECOVERY_FRAMES + 7):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.IDLE and simulation.dummy.state == FighterSimulation.State.IDLE, "Throw Tech recovery returns both fighters to neutral")


func _test_throw_misses_airborne_opponent() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position = Vector2i(440 * CombatSimulation.UNITS_PER_PIXEL, 500 * CombatSimulation.UNITS_PER_PIXEL)
	simulation.dummy.state = FighterSimulation.State.AIRBORNE
	var throw_input := FrameInput.new()
	throw_input.throw_pressed = true
	simulation.tick(throw_input, FrameInput.new())
	for _index in range(8):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.dummy.health == 1000, "Ground throw misses an airborne opponent")


func _test_throw_whiff_has_recovery() -> void:
	var simulation := CombatSimulation.new()
	var throw_input := FrameInput.new()
	throw_input.throw_pressed = true
	simulation.tick(throw_input, FrameInput.new())
	var throw_move := simulation.player.current_move
	for _index in range(throw_move.startup + throw_move.active):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.ATTACK, "Whiffed throw remains committed during recovery")
	for _index in range(throw_move.recovery):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.IDLE, "Throw recovery eventually returns to idle")


func _test_training_resets() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.health = 200
	simulation.dummy.health = 300
	simulation.player.position.x = 100 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 1100 * CombatSimulation.UNITS_PER_PIXEL
	simulation.reset_training_positions()
	_expect(simulation.player.position.x == 420 * CombatSimulation.UNITS_PER_PIXEL, "Training position reset restores P1 spacing")
	_expect(simulation.dummy.position.x == 860 * CombatSimulation.UNITS_PER_PIXEL, "Training position reset restores P2 spacing")
	simulation.player.health = 200
	simulation.dummy.health = 300
	simulation.player.apply_memory_mark()
	simulation.refill_training_state()
	_expect(simulation.player.health == 1000 and simulation.dummy.health == 1000, "Training refill restores both health bars")
	_expect(simulation.player.memory_mark_frames == 0, "Training refill clears character mechanics")
	_expect(simulation.player.conviction == FighterSimulation.CONVICTION_MAX and simulation.dummy.conviction == FighterSimulation.CONVICTION_MAX, "Training refill fills both Conviction gauges")
	_expect(simulation.player.burst_available and simulation.dummy.burst_available, "Training refill restores both Burst charges")


func _test_conviction_gain_and_cap() -> void:
	var hit_simulation := CombatSimulation.new()
	hit_simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	hit_simulation.dummy.position.x = 450 * CombatSimulation.UNITS_PER_PIXEL
	var attack := FrameInput.new()
	attack.light_pressed = true
	hit_simulation.tick(attack, FrameInput.new())
	for _index in range(5):
		hit_simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(hit_simulation.player.conviction == CombatSimulation.METER_GAIN_HIT, "Landing a hit grants substantial Conviction")
	_expect(hit_simulation.dummy.conviction == CombatSimulation.METER_GAIN_RECEIVED, "Receiving a hit grants comeback Conviction")

	var block_simulation := CombatSimulation.new()
	block_simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	block_simulation.dummy.position.x = 450 * CombatSimulation.UNITS_PER_PIXEL
	var block := FrameInput.new()
	block.right = true
	block_simulation.tick(attack, block)
	for _index in range(5):
		block_simulation.tick(FrameInput.new(), block)
	_expect(block_simulation.player.conviction == CombatSimulation.METER_GAIN_BLOCK, "Blocked offense grants reduced Conviction")
	_expect(block_simulation.dummy.conviction == CombatSimulation.METER_GAIN_GUARD, "Defending grants a small Conviction reward")
	block_simulation.player.gain_conviction(9999)
	_expect(block_simulation.player.conviction == FighterSimulation.CONVICTION_MAX, "Conviction is capped at three bars")


func _test_conquer_arts_consume_meter_and_start_mechanics() -> void:
	var izuna_simulation := CombatSimulation.new()
	izuna_simulation.player.conviction = FighterSimulation.CONVICTION_BAR
	var resource := FrameInput.new()
	resource.resource_pressed = true
	izuna_simulation.tick(resource, FrameInput.new())
	_expect(izuna_simulation.player.current_move.id == &"izuna_sacred_recall", "Izuna Resource input starts Sacred Recall")
	_expect(izuna_simulation.player.conviction == 0, "Sacred Recall consumes one Conviction bar")
	_expect(izuna_simulation.player.recall_delay_frames == FighterSimulation.RECALL_DELAY_FRAMES, "Sacred Recall creates Recall without an existing Mark")

	var xenon_simulation := CombatSimulation.new()
	xenon_simulation.dummy.conviction = FighterSimulation.CONVICTION_BAR
	xenon_simulation.tick(FrameInput.new(), resource)
	_expect(xenon_simulation.dummy.current_move.id == &"xenon_unmasked_chorus", "Xenon Resource input starts Unmasked Chorus")
	_expect(xenon_simulation.dummy.conviction == 0, "Unmasked Chorus consumes one Conviction bar")
	_expect(xenon_simulation.dummy.puppet_delay_frames == FighterSimulation.PUPPET_DELAY_FRAMES, "Unmasked Chorus summons a Puppet without Echo")


func _test_shift_cancel_spends_meter_during_recovery() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.conviction = FighterSimulation.CONVICTION_BAR
	var attack := FrameInput.new()
	attack.light_pressed = true
	simulation.tick(attack, FrameInput.new())
	for _index in range(8):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.current_move.phase_at(simulation.player.move_frame) == &"recovery", "Move reaches recovery before Shift Cancel")
	var resource := FrameInput.new()
	resource.resource_pressed = true
	simulation.tick(resource, FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.IDLE, "Shift Cancel returns recovery to neutral")
	_expect(simulation.player.conviction == 0, "Shift Cancel consumes one Conviction bar")


func _test_burst_escapes_stun_once_per_round() -> void:
	var simulation := CombatSimulation.new()
	simulation.player.position.x = 600 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 760 * CombatSimulation.UNITS_PER_PIXEL
	simulation.player.state = FighterSimulation.State.HITSTUN
	simulation.player.state_frame = 20
	var resource := FrameInput.new()
	resource.resource_pressed = true
	simulation.tick(resource, FrameInput.new())
	_expect(simulation.player.state == FighterSimulation.State.BURST, "Resource input during hitstun activates Burst")
	_expect(not simulation.player.burst_available, "Burst charge is consumed")
	_expect(simulation.dummy.state == FighterSimulation.State.HITSTUN, "Burst pushes the opponent into hitstun")
	_expect(simulation.dummy.velocity.x > 0, "Burst pushes the opponent away from Izuna")
	var remaining_recovery := simulation.player.state_frame
	simulation.tick(resource, FrameInput.new())
	_expect(simulation.player.state_frame == remaining_recovery - 1, "Consumed Burst cannot activate again in the same round")


func _test_ultimate_requires_and_consumes_full_meter() -> void:
	var unavailable := CombatSimulation.new()
	var ultimate := FrameInput.new()
	ultimate.ultimate_pressed = true
	unavailable.tick(ultimate, FrameInput.new())
	_expect(unavailable.player.current_move == null, "Ultimate cannot start without three Conviction bars")

	var simulation := CombatSimulation.new()
	simulation.player.position.x = 350 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 500 * CombatSimulation.UNITS_PER_PIXEL
	simulation.player.conviction = FighterSimulation.CONVICTION_MAX
	simulation.tick(ultimate, FrameInput.new())
	_expect(simulation.player.current_move.id == &"izuna_ninefold_severance", "Full meter enables Izuna Ultimate")
	_expect(simulation.player.conviction == 0, "Ultimate consumes all Conviction bars on startup")
	for _index in range(12):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.dummy.health == 640, "Ninefold Severance deals Ultimate damage")
	_expect(simulation.dummy.state == FighterSimulation.State.KNOCKDOWN, "Ultimate causes hard knockdown placeholder")


func _test_round_reset_restores_universal_resources() -> void:
	var fighter := FighterSimulation.new(&"resource_test", Vector2i.ZERO, &"izuna")
	fighter.conviction = FighterSimulation.CONVICTION_MAX
	fighter.burst_available = false
	fighter.reset_for_round(Vector2i.ZERO)
	_expect(fighter.conviction == 0, "Conviction resets between rounds")
	_expect(fighter.burst_available, "Burst charge refreshes each round")


func _test_cpu_is_deterministic_for_the_same_seed() -> void:
	var simulation_a := CombatSimulation.new()
	var simulation_b := CombatSimulation.new()
	var cpu_a := BasicCpuController.new(BasicCpuController.Difficulty.NORMAL, 4242)
	var cpu_b := BasicCpuController.new(BasicCpuController.Difficulty.NORMAL, 4242)
	var trace_a: Array[String] = []
	var trace_b: Array[String] = []
	for _index in range(180):
		var input_a := cpu_a.next_input(simulation_a, simulation_a.dummy, simulation_a.player)
		var input_b := cpu_b.next_input(simulation_b, simulation_b.dummy, simulation_b.player)
		trace_a.append(_input_signature(input_a))
		trace_b.append(_input_signature(input_b))
		simulation_a.tick(FrameInput.new(), input_a)
		simulation_b.tick(FrameInput.new(), input_b)
	_expect(trace_a == trace_b, "CPU produces the same decisions for the same seed")
	_expect(simulation_a.dummy.position == simulation_b.dummy.position, "Seeded CPU produces deterministic simulation positions")


func _test_cpu_closes_distance_and_can_deal_damage() -> void:
	var simulation := CombatSimulation.new()
	var cpu := BasicCpuController.new(BasicCpuController.Difficulty.NORMAL, 91)
	var initial_distance := absi(simulation.dummy.position.x - simulation.player.position.x)
	var closest_distance := initial_distance
	var dealt_damage := false
	for _index in range(900):
		var cpu_input := cpu.next_input(simulation, simulation.dummy, simulation.player)
		simulation.tick(FrameInput.new(), cpu_input)
		closest_distance = mini(closest_distance, absi(simulation.dummy.position.x - simulation.player.position.x))
		if simulation.player.health < 1000:
			dealt_damage = true
			break
	_expect(closest_distance < initial_distance, "CPU closes distance when the opponent is far away")
	_expect(dealt_damage, "CPU can engage and deal damage without reading player input")


func _test_hard_cpu_uses_burst_under_pressure() -> void:
	var simulation := CombatSimulation.new()
	var cpu := BasicCpuController.new(BasicCpuController.Difficulty.HARD, 7)
	simulation.dummy.health = 700
	simulation.dummy.state = FighterSimulation.State.HITSTUN
	simulation.dummy.state_frame = 20
	var cpu_input := cpu.next_input(simulation, simulation.dummy, simulation.player)
	_expect(cpu_input.resource_pressed, "Hard CPU requests Burst while stunned below its health threshold")


func _test_hard_cpu_reads_and_techs_an_incoming_throw() -> void:
	var simulation := CombatSimulation.new()
	var cpu := BasicCpuController.new(BasicCpuController.Difficulty.HARD, 12)
	simulation.player.position.x = 500 * CombatSimulation.UNITS_PER_PIXEL
	simulation.dummy.position.x = 570 * CombatSimulation.UNITS_PER_PIXEL
	var throw_input := FrameInput.new()
	throw_input.throw_pressed = true
	simulation.tick(throw_input, FrameInput.new())
	var cpu_input := cpu.next_input(simulation, simulation.dummy, simulation.player)
	_expect(cpu_input.throw_pressed, "Hard CPU attempts Throw Tech against a nearby telegraphed throw")


func _test_cpu_match_reaches_a_deterministic_conclusion() -> void:
	var simulation := CombatSimulation.new()
	var izuna_cpu := BasicCpuController.new(BasicCpuController.Difficulty.NORMAL, 101)
	var xenon_cpu := BasicCpuController.new(BasicCpuController.Difficulty.NORMAL, 202)
	var elapsed_frames := 0
	while simulation.match_state != CombatSimulation.MatchState.MATCH_OVER and elapsed_frames < 24000:
		var player_input := izuna_cpu.next_input(simulation, simulation.player, simulation.dummy)
		var dummy_input := xenon_cpu.next_input(simulation, simulation.dummy, simulation.player)
		simulation.tick(player_input, dummy_input)
		elapsed_frames += 1
	_expect(simulation.match_state == CombatSimulation.MatchState.MATCH_OVER, "CPU-versus-CPU soak match reaches a conclusion")
	_expect(simulation.player.rounds_won == 2 or simulation.dummy.rounds_won == 2, "Soak match produces a best-of-three winner")
	_expect(elapsed_frames < 24000, "Soak match completes within the deterministic frame budget")


func _test_cpu_is_neutral_outside_active_rounds() -> void:
	var simulation := CombatSimulation.new()
	var cpu := BasicCpuController.new(BasicCpuController.Difficulty.NORMAL, 7)
	simulation.match_state = CombatSimulation.MatchState.ROUND_OVER
	var cpu_input := cpu.next_input(simulation, simulation.dummy, simulation.player)
	_expect(_input_signature(cpu_input) == "00000000000000", "CPU stays neutral outside an active round")


func _input_signature(input: FrameInput) -> String:
	return "%d%d%d%d%d%d%d%d%d%d%d%d%d%d" % [
		int(input.left),
		int(input.right),
		int(input.up),
		int(input.down),
		int(input.dash_forward_pressed),
		int(input.backdash_pressed),
		int(input.guard_held),
		int(input.light_pressed),
		int(input.medium_pressed),
		int(input.heavy_pressed),
		int(input.special_pressed),
		int(input.throw_pressed),
		int(input.resource_pressed),
		int(input.ultimate_pressed),
	]


func _expect(condition: bool, message: String) -> void:
	assertions += 1
	if condition:
		print("  OK  %s" % message)
		return

	failures += 1
	push_error("  ERR %s" % message)
