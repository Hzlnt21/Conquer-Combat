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
	for _index in range(5):
		simulation.tick(FrameInput.new(), FrameInput.new())
	_expect(simulation.player.health == 960, "Player two attack damages player one")


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
	simulation.player.health = 40
	simulation.dummy.health = 40
	var player_one_attack := FrameInput.new()
	var player_two_attack := FrameInput.new()
	player_one_attack.light_pressed = true
	player_two_attack.light_pressed = true
	simulation.tick(player_one_attack, player_two_attack)
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


func _expect(condition: bool, message: String) -> void:
	assertions += 1
	if condition:
		print("  OK  %s" % message)
		return

	failures += 1
	push_error("  ERR %s" % message)
