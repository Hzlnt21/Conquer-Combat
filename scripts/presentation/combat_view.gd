class_name CombatView
extends Control

const UNITS_PER_PIXEL := 1000.0
const STAGE_TEXTURE := preload("res://assets/stages/ruined-shrine/ruined-shrine-bg-v01.png")
const IZUNA_TEXTURE := preload("res://assets/characters/izuna/game-ready/izuna-combat-idle-v01.png")
const XENON_TEXTURE := preload("res://assets/characters/xenon/game-ready/xenon-combat-idle-v01.png")

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
	draw_texture_rect(STAGE_TEXTURE, Rect2(Vector2.ZERO, size), false)
	draw_rect(Rect2(0, 0, size.x, 122), Color(0.025, 0.018, 0.045, 0.72))
	draw_rect(Rect2(0, 520, size.x, size.y - 520), Color(0.035, 0.02, 0.05, 0.18))
	draw_line(Vector2(0, 590), Vector2(size.x, 590), Color(0.82, 0.54, 0.63, 0.35), 2)


func _draw_fighter(fighter: FighterSimulation, body_color: Color, accent: Color, label: String) -> void:
	var bottom := Vector2(fighter.position) / UNITS_PER_PIXEL
	var body := _to_screen_rect(fighter.body_rect())
	_draw_fighter_shadow(bottom, accent)
	_draw_fighter_art(fighter, bottom)

	if fighter.state == FighterSimulation.State.ATTACK and fighter.current_move != null:
		_draw_attack_effect(fighter, bottom, accent)
	elif fighter.state == FighterSimulation.State.BURST:
		for ring in range(3):
			draw_arc(bottom + Vector2(0, -96), 54 + ring * 24, 0, TAU, 36, Color(0.75, 0.95, 1.0, 0.82 - ring * 0.18), 8 - ring * 2)
	elif fighter.state == FighterSimulation.State.BLOCKSTUN:
		draw_arc(bottom + Vector2(fighter.facing * 22, -90), 48, -1.4, 1.4, 16, Color("77d8ff"), 7)
	elif fighter.state in [FighterSimulation.State.GUARD_STARTUP, FighterSimulation.State.GUARD, FighterSimulation.State.GUARD_RECOVERY]:
		var guard_color := Color("d9fbff") if fighter.state == FighterSimulation.State.GUARD else Color("64889d")
		draw_arc(bottom + Vector2(fighter.facing * 24, -92), 56, -1.45, 1.45, 20, guard_color, 9)
		draw_circle(bottom + Vector2(fighter.facing * 34, -92), 7, guard_color)
	elif fighter.state == FighterSimulation.State.KNOCKDOWN:
		draw_line(bottom + Vector2(-48, -16), bottom + Vector2(48, -16), accent, 20)
	_draw_delayed_effects(fighter, bottom)

	if show_debug:
		draw_string(ThemeDB.fallback_font, body.position + Vector2(0, -10), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, body_color)
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


func _draw_fighter_shadow(bottom: Vector2, accent: Color) -> void:
	draw_set_transform(bottom + Vector2(0, -3), 0.0, Vector2(1.0, 0.24))
	draw_circle(Vector2.ZERO, 72, Color(0.02, 0.01, 0.04, 0.58))
	draw_arc(Vector2.ZERO, 68, 0, TAU, 36, Color(accent, 0.24), 5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_fighter_art(fighter: FighterSimulation, bottom: Vector2) -> void:
	var is_izuna := fighter.character_id == &"izuna"
	var texture: Texture2D = IZUNA_TEXTURE if is_izuna else XENON_TEXTURE
	var art_height := 330.0 if is_izuna else 306.0
	var art_width := art_height * texture.get_width() / float(texture.get_height())
	var canonical_facing := 1 if is_izuna else -1
	var flip := 1.0 if fighter.facing == canonical_facing else -1.0
	var breathe := 1.0 + sin(float(simulation.frame) * 0.075) * 0.008
	var pose_scale := Vector2(flip, breathe)
	var pose_rotation := 0.0
	var tint := Color.WHITE
	if fighter.state == FighterSimulation.State.ATTACK:
		pose_scale.x *= 1.035
	elif fighter.state == FighterSimulation.State.HITSTUN:
		pose_rotation = -fighter.facing * 0.08
		tint = Color(1.0, 0.72, 0.72)
	elif fighter.state == FighterSimulation.State.KNOCKDOWN:
		pose_rotation = fighter.facing * 1.25
		pose_scale *= 0.82
	elif fighter.state == FighterSimulation.State.CROUCH:
		pose_scale.y *= 0.88
	draw_set_transform(bottom, pose_rotation, pose_scale)
	draw_texture_rect(texture, Rect2(-art_width * 0.5, -art_height, art_width, art_height), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_attack_effect(fighter: FighterSimulation, bottom: Vector2, accent: Color) -> void:
	var move_id := str(fighter.current_move.id)
	var arc_center := bottom + Vector2(fighter.facing * 70, -108)
	if "ninefold_severance" in move_id or "the_last_laugh" in move_id:
		for ring in range(3):
			draw_arc(bottom + Vector2(fighter.facing * 100, -105), 80 + ring * 24, -1.55, 1.55, 30, Color(1.0, 0.82 - ring * 0.14, 0.35 + ring * 0.2, 0.9), 13 - ring * 2)
	elif "sacred_recall" in move_id or "unmasked_chorus" in move_id:
		draw_arc(arc_center, 86, -1.45, 1.45, 28, Color("ffe3a1"), 13)
		draw_arc(arc_center, 64, -1.45, 1.45, 24, accent, 7)
	elif "foxfire_step" in move_id or "mocking_step" in move_id:
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
	var left_bar := Rect2(54, 49, 466, 30)
	var right_bar := Rect2(size.x - 520, 49, 466, 30)
	_draw_health_frame(left_bar, simulation.player.health / 1000.0, Color("ed3656"), false)
	var dummy_width := right_bar.size.x * simulation.dummy.health / 1000.0
	_draw_health_frame(right_bar, dummy_width / right_bar.size.x, Color("c757dd"), true)
	draw_string(ThemeDB.fallback_font, Vector2(54, 39), "IZUNA", HORIZONTAL_ALIGNMENT_LEFT, 250, 22, Color("fff7ef"))
	draw_string(ThemeDB.fallback_font, Vector2(54, 96), "THE SACRED EDGE", HORIZONTAL_ALIGNMENT_LEFT, 280, 12, Color("d7b5aa"))
	draw_string(ThemeDB.fallback_font, Vector2(size.x - 304, 39), "XENON", HORIZONTAL_ALIGNMENT_RIGHT, 250, 22, Color("fff7ff"))
	draw_string(ThemeDB.fallback_font, Vector2(size.x - 334, 96), "THE SMILING DESPAIR", HORIZONTAL_ALIGNMENT_RIGHT, 280, 12, Color("d5b1dc"))

	_draw_mechanic_bar(Rect2(54, 84, 180, 6), simulation.player.memory_mark_frames / float(FighterSimulation.MEMORY_MARK_DURATION), Color("ff6a55"), "MEMORY")
	var echo_ratio := simulation.dummy.emotional_echo_frames / float(FighterSimulation.EMOTIONAL_ECHO_DURATION)
	_draw_mechanic_bar(Rect2(size.x - 234, 84, 180, 6), echo_ratio, Color("e66cff"), "EMOTION", true)
	_draw_conviction_gauge(Rect2(54, 111, 260, 9), simulation.player, Color("ffb55e"), false)
	_draw_conviction_gauge(Rect2(size.x - 314, 111, 260, 9), simulation.dummy, Color("ef8cff"), true)

	for index in simulation.player.rounds_won:
		draw_circle(Vector2(254 + index * 22, 88), 7, Color("ffcf79"))
	for index in simulation.dummy.rounds_won:
		draw_circle(Vector2(size.x - 254 - index * 22, 88), 7, Color("ffcf79"))


func _draw_health_frame(rect: Rect2, ratio: float, accent: Color, fill_from_right: bool) -> void:
	draw_rect(rect.grow(4), Color(0.025, 0.02, 0.04, 0.94))
	draw_rect(rect, Color("211c2b"))
	var fill_width := rect.size.x * clampf(ratio, 0.0, 1.0)
	var fill_rect := Rect2(rect.end.x - fill_width if fill_from_right else rect.position.x, rect.position.y, fill_width, rect.size.y)
	draw_rect(fill_rect, accent)
	draw_rect(Rect2(fill_rect.position, Vector2(fill_rect.size.x, 6)), Color(1.0, 0.9, 0.82, 0.32))
	draw_rect(rect, Color("f0d7c2"), false, 2)
	for notch in range(1, 5):
		var x := rect.position.x + rect.size.x * notch / 5.0
		draw_line(Vector2(x, rect.position.y + 20), Vector2(x, rect.end.y), Color(0.08, 0.05, 0.11, 0.55), 2)


func _draw_mechanic_bar(rect: Rect2, ratio: float, accent: Color, label: String, align_right := false) -> void:
	draw_rect(rect, Color(0.08, 0.055, 0.1, 0.92))
	var fill_width := rect.size.x * clampf(ratio, 0.0, 1.0)
	var x := rect.end.x - fill_width if align_right else rect.position.x
	draw_rect(Rect2(x, rect.position.y, fill_width, rect.size.y), accent)
	var label_x := rect.position.x if not align_right else rect.position.x - 70
	draw_string(ThemeDB.fallback_font, Vector2(label_x, rect.position.y + 20), label, HORIZONTAL_ALIGNMENT_RIGHT if align_right else HORIZONTAL_ALIGNMENT_LEFT, 70 if align_right else -1, 10, Color("d9cadf"))


func _draw_conviction_gauge(rect: Rect2, fighter: FighterSimulation, accent: Color, align_right: bool) -> void:
	for bar in range(3):
		var segment_width := (rect.size.x - 8.0) / 3.0
		var visual_index := 2 - bar if align_right else bar
		var segment := Rect2(rect.position.x + visual_index * (segment_width + 4.0), rect.position.y, segment_width, rect.size.y)
		var fill := clampf((fighter.conviction - bar * FighterSimulation.CONVICTION_BAR) / float(FighterSimulation.CONVICTION_BAR), 0.0, 1.0)
		draw_rect(segment, Color(0.07, 0.045, 0.09, 0.94))
		var fill_width := segment.size.x * fill
		var fill_x := segment.end.x - fill_width if align_right else segment.position.x
		draw_rect(Rect2(fill_x, segment.position.y, fill_width, segment.size.y), accent)
		draw_rect(segment, Color("e8d2d9"), false, 1)
	var burst_center := Vector2(rect.end.x + 18 if not align_right else rect.position.x - 18, rect.get_center().y)
	draw_circle(burst_center, 8, Color("bff7ff") if fighter.burst_available else Color("3f3548"))
	draw_arc(burst_center, 10, 0, TAU, 16, Color("efffff") if fighter.burst_available else Color("766a7e"), 2)


func _draw_match_status() -> void:
	var center := Vector2(size.x * 0.5, 63)
	draw_circle(center, 39, Color(0.04, 0.025, 0.06, 0.95))
	draw_arc(center, 38, 0, TAU, 32, Color("d4a6c8"), 3)
	draw_arc(center, 31, 0, TAU, 32, Color(0.5, 0.2, 0.4, 0.5), 2)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(size.x * 0.5 - 40, 74),
		str(simulation.displayed_timer()),
		HORIZONTAL_ALIGNMENT_CENTER,
		80,
		28,
		Color("fff3e8")
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
		"P1 METER %d BURST %s | P2 METER %d BURST %s" % [player_one.conviction, player_one.burst_available, player_two.conviction, player_two.burst_available],
		"MEMORY %d RECALL %d | ECHO %d (%d) PUPPET %d" % [player_one.memory_mark_frames, player_one.recall_delay_frames, player_two.emotional_echo_tokens, player_two.emotional_echo_frames, player_two.puppet_delay_frames],
	]
	for index in lines.size():
		draw_string(ThemeDB.fallback_font, Vector2(24, 642 + index * 15), lines[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("c9bdcf"))


func _to_screen_rect(rect: Rect2i) -> Rect2:
	return Rect2(Vector2(rect.position) / UNITS_PER_PIXEL, Vector2(rect.size) / UNITS_PER_PIXEL)
