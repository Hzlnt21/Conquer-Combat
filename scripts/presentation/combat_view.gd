class_name CombatView
extends Control

const UNITS_PER_PIXEL := 1000.0

var simulation: CombatSimulation
var show_debug := false


func _draw() -> void:
	if simulation == null:
		return

	_draw_stage()
	_draw_fighter(simulation.player, Color("f2eee8"), Color("df334f"), "P1 IZUNA")
	_draw_fighter(simulation.dummy, Color("d8d1df"), Color("a54cc8"), "P2 XENON")
	_draw_health()
	_draw_match_status()
	if show_debug:
		_draw_debug_text()


func _draw_stage() -> void:
	draw_rect(Rect2(0, 0, size.x, size.y), Color("0d0a13"))
	draw_circle(Vector2(size.x * 0.5, 210), 135, Color("24162b"))
	draw_arc(Vector2(size.x * 0.5, 210), 135, 0, TAU, 64, Color("6b304f"), 3)
	for index in range(7):
		var x := 100.0 + index * 180.0
		draw_line(Vector2(x, 250), Vector2(x - 70, 590), Color("211928"), 18)
	draw_rect(Rect2(0, 590, size.x, size.y - 590), Color("17121d"))
	draw_line(Vector2(0, 590), Vector2(size.x, 590), Color("8a5a65"), 3)


func _draw_fighter(fighter: FighterSimulation, body_color: Color, accent: Color, label: String) -> void:
	var bottom := Vector2(fighter.position) / UNITS_PER_PIXEL
	var body := _to_screen_rect(fighter.body_rect())

	draw_rect(body, body_color, true)
	draw_rect(Rect2(body.position + Vector2(8, 12), Vector2(body.size.x - 16, 24)), accent, true)
	draw_circle(Vector2(body.get_center().x, body.position.y + 30), 21, accent)

	var sword_origin := Vector2(body.get_center().x + fighter.facing * 18, body.position.y + 72)
	var sword_tip := sword_origin + Vector2(fighter.facing * 92, -22)
	draw_line(sword_origin, sword_tip, accent, 8)

	if fighter.state == FighterSimulation.State.ATTACK and fighter.current_move != null:
		_draw_attack_effect(fighter, bottom, accent)
	elif fighter.state == FighterSimulation.State.BLOCKSTUN:
		draw_arc(bottom + Vector2(fighter.facing * 22, -90), 48, -1.4, 1.4, 16, Color("77d8ff"), 7)
	elif fighter.state in [FighterSimulation.State.GUARD_STARTUP, FighterSimulation.State.GUARD, FighterSimulation.State.GUARD_RECOVERY]:
		var guard_color := Color("d9fbff") if fighter.state == FighterSimulation.State.GUARD else Color("64889d")
		draw_arc(bottom + Vector2(fighter.facing * 24, -92), 56, -1.45, 1.45, 20, guard_color, 9)
		draw_circle(bottom + Vector2(fighter.facing * 34, -92), 7, guard_color)
	elif fighter.state == FighterSimulation.State.KNOCKDOWN:
		draw_line(bottom + Vector2(-48, -16), bottom + Vector2(48, -16), accent, 20)
	_draw_delayed_effects(fighter, bottom)

	draw_string(ThemeDB.fallback_font, body.position + Vector2(0, -10), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, body_color)

	if show_debug:
		draw_rect(body, Color("62d6ff"), false, 2)
		var attack_rect := fighter.attack_rect()
		if attack_rect.has_area():
			draw_rect(_to_screen_rect(attack_rect), Color("ff405d"), false, 3)
		var recall_rect := fighter.recall_rect()
		if recall_rect.has_area():
			draw_rect(_to_screen_rect(recall_rect), Color("fff0d1"), false, 3)
		var puppet_rect := fighter.puppet_rect()
		if puppet_rect.has_area():
			draw_rect(_to_screen_rect(puppet_rect), Color("ee72ff"), false, 3)


func _draw_attack_effect(fighter: FighterSimulation, bottom: Vector2, accent: Color) -> void:
	var move_id := str(fighter.current_move.id)
	var arc_center := bottom + Vector2(fighter.facing * 70, -108)
	if "foxfire_step" in move_id or "mocking_step" in move_id:
		draw_line(bottom + Vector2(-fighter.facing * 55, -80), bottom + Vector2(fighter.facing * 125, -100), accent, 14)
	elif "memory_break" in move_id:
		draw_arc(bottom + Vector2(0, -120), 72, PI, TAU, 24, Color("fff0d1"), 11)
	elif "laughing_chain" in move_id:
		draw_line(bottom + Vector2(fighter.facing * 20, -100), bottom + Vector2(fighter.facing * 215, -105), accent, 7)
		for index in range(4):
			draw_circle(bottom + Vector2(fighter.facing * (65 + index * 42), -105), 8, Color("e88cff"), false, 3)
	elif "despair_puppet" in move_id:
		draw_circle(bottom + Vector2(fighter.facing * 90, -80), 28, Color("a54cc8"), false, 7)
	elif fighter.current_move.is_throw:
		var grab_center := bottom + Vector2(fighter.facing * 58, -92)
		draw_arc(grab_center, 34, -1.2, 1.2, 16, Color("ffd68a"), 8)
		draw_circle(grab_center, 9, Color("fff1c7"), false, 4)
	else:
		draw_arc(arc_center, 58, -1.3 if fighter.facing > 0 else 1.8, 1.3 if fighter.facing > 0 else 4.4, 20, accent, 9)



func _draw_delayed_effects(fighter: FighterSimulation, bottom: Vector2) -> void:
	if fighter.recall_delay_frames > 0:
		var recall_alpha := 0.35 + 0.35 * sin(float(fighter.recall_delay_frames))
		draw_arc(bottom + Vector2(fighter.facing * 125, -105), 52, 0, TAU, 24, Color(1.0, 0.85, 0.72, recall_alpha), 5)
	elif fighter.recall_active_frames > 0:
		draw_arc(bottom + Vector2(fighter.facing * 125, -105), 70, -1.4, 1.4, 24, Color("fff0d1"), 12)
	if fighter.puppet_delay_frames > 0:
		var puppet_position := bottom + Vector2(fighter.facing * 180, -85)
		draw_circle(puppet_position, 24, Color("8f3ca8"))
		draw_circle(puppet_position, 14, Color("e88cff"), false, 4)
	elif fighter.puppet_active_frames > 0:
		var puppet_position := bottom + Vector2(fighter.facing * 180, -85)
		draw_circle(puppet_position, 42, Color("e88cff"))
		draw_arc(puppet_position, 52, 0, TAU, 28, Color("fff0ff"), 7)


func _draw_health() -> void:
	var left_bar := Rect2(64, 54, 470, 25)
	var right_bar := Rect2(size.x - 534, 54, 470, 25)
	draw_rect(left_bar, Color("2a2430"))
	draw_rect(right_bar, Color("2a2430"))
	draw_rect(Rect2(left_bar.position, Vector2(left_bar.size.x * simulation.player.health / 1000.0, left_bar.size.y)), Color("db3652"))
	var dummy_width := right_bar.size.x * simulation.dummy.health / 1000.0
	draw_rect(Rect2(right_bar.end.x - dummy_width, right_bar.position.y, dummy_width, right_bar.size.y), Color("b84fce"))
	draw_string(ThemeDB.fallback_font, Vector2(64, 46), "P1 IZUNA", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(size.x - 534, 46), "P2 XENON", HORIZONTAL_ALIGNMENT_RIGHT, 470, 18, Color.WHITE)

	for index in simulation.player.rounds_won:
		draw_circle(Vector2(76 + index * 22, 94), 7, Color("df334f"))
	for index in simulation.dummy.rounds_won:
		draw_circle(Vector2(size.x - 76 - index * 22, 94), 7, Color("a54cc8"))


func _draw_match_status() -> void:
	draw_string(
		ThemeDB.fallback_font,
		Vector2(size.x * 0.5 - 40, 72),
		str(simulation.displayed_timer()),
		HORIZONTAL_ALIGNMENT_CENTER,
		80,
		30,
		Color.WHITE
	)
	if simulation.match_state == CombatSimulation.MatchState.FIGHTING:
		return
	var status := "DRAW"
	if simulation.round_winner == 1:
		status = "P1 WINS ROUND"
	elif simulation.round_winner == 2:
		status = "P2 WINS ROUND"
	if simulation.match_state == CombatSimulation.MatchState.MATCH_OVER:
		status = "P1 WINS MATCH" if simulation.player.rounds_won > simulation.dummy.rounds_won else "P2 WINS MATCH"
	draw_string(ThemeDB.fallback_font, Vector2(0, 180), status, HORIZONTAL_ALIGNMENT_CENTER, size.x, 34, Color("ffd8a8"))


func _draw_debug_text() -> void:
	var player_one := simulation.player
	var player_two := simulation.dummy
	var move_name_one := "none" if player_one.current_move == null else str(player_one.current_move.id)
	var move_name_two := "none" if player_two.current_move == null else str(player_two.current_move.id)
	var phase_one := "-" if player_one.current_move == null else str(player_one.current_move.phase_at(player_one.move_frame))
	var phase_two := "-" if player_two.current_move == null else str(player_two.current_move.phase_at(player_two.move_frame))
	var data_one := "-" if player_one.current_move == null else "%d/%d/%d" % [player_one.current_move.startup, player_one.current_move.active, player_one.current_move.recovery]
	var data_two := "-" if player_two.current_move == null else "%d/%d/%d" % [player_two.current_move.startup, player_two.current_move.active, player_two.current_move.recovery]
	var lines := [
		"SIM %d | ROUND %d | HITSTOP %d" % [simulation.frame, simulation.round_number, simulation.hitstop_frames],
		"P1 %s f%d | %s %s f%d [%s] | HP %d" % [FighterSimulation.State.keys()[player_one.state], player_one.state_frame, move_name_one, phase_one, player_one.move_frame, data_one, player_one.health],
		"P2 %s f%d | %s %s f%d [%s] | HP %d" % [FighterSimulation.State.keys()[player_two.state], player_two.state_frame, move_name_two, phase_two, player_two.move_frame, data_two, player_two.health],
		"P1 POS %d,%d | P2 POS %d,%d" % [player_one.position.x / 1000, player_one.position.y / 1000, player_two.position.x / 1000, player_two.position.y / 1000],
		"MEMORY %d RECALL %d | ECHO %d (%d) PUPPET %d" % [player_one.memory_mark_frames, player_one.recall_delay_frames, player_two.emotional_echo_tokens, player_two.emotional_echo_frames, player_two.puppet_delay_frames],
	]
	for index in lines.size():
		draw_string(ThemeDB.fallback_font, Vector2(24, 642 + index * 15), lines[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("c9bdcf"))


func _to_screen_rect(rect: Rect2i) -> Rect2:
	return Rect2(Vector2(rect.position) / UNITS_PER_PIXEL, Vector2(rect.size) / UNITS_PER_PIXEL)
