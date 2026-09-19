class_name FighterSimulation
extends RefCounted

enum State {
	IDLE,
	WALK,
	CROUCH,
	AIRBORNE,
	DASH,
	BACKDASH,
	GUARD_STARTUP,
	GUARD,
	GUARD_RECOVERY,
	BURST,
	ATTACK,
	BLOCKSTUN,
	HITSTUN,
	KNOCKDOWN,
	KO,
}

const UNITS_PER_PIXEL := 1000
const BODY_HALF_WIDTH := 38 * UNITS_PER_PIXEL
const BODY_HEIGHT := 176 * UNITS_PER_PIXEL
const WALK_FORWARD_SPEED := 5 * UNITS_PER_PIXEL
const WALK_BACK_SPEED := 4 * UNITS_PER_PIXEL
const JUMP_SPEED := -16 * UNITS_PER_PIXEL
const GRAVITY := 1 * UNITS_PER_PIXEL
const MAX_FALL_SPEED := 18 * UNITS_PER_PIXEL
const DASH_SPEED := 12 * UNITS_PER_PIXEL
const BACKDASH_SPEED := 10 * UNITS_PER_PIXEL
const DASH_FRAMES := 10
const BACKDASH_FRAMES := 12
const INPUT_BUFFER_FRAMES := 5
const KNOCKDOWN_FRAMES := 72
const MEMORY_MARK_DURATION := 300
const EMOTIONAL_ECHO_DURATION := 360
const RECALL_DELAY_FRAMES := 18
const PUPPET_DELAY_FRAMES := 45
const DELAYED_ACTIVE_FRAMES := 3
const GUARD_STARTUP_FRAMES := 4
const GUARD_RECOVERY_FRAMES := 10
const CONVICTION_MAX := 3000
const CONVICTION_BAR := 1000
const BURST_RECOVERY_FRAMES := 28
const BURST_HITSTUN_FRAMES := 18
const BURST_PUSHBACK := 14 * UNITS_PER_PIXEL

var fighter_id: StringName
var character_id: StringName
var state := State.IDLE
var state_frame := 0
var position := Vector2i.ZERO
var velocity := Vector2i.ZERO
var facing := 1
var health := 1000
var is_dummy := false
var rounds_won := 0
var conviction := 0
var burst_available := true
var walk_forward_speed := WALK_FORWARD_SPEED
var walk_back_speed := WALK_BACK_SPEED
var dash_speed := DASH_SPEED
var backdash_speed := BACKDASH_SPEED

var memory_mark_frames := 0
var emotional_echo_tokens := 0
var emotional_echo_frames := 0
var recall_delay_frames := 0
var recall_active_frames := 0
var recall_has_hit := false
var puppet_delay_frames := 0
var puppet_active_frames := 0
var puppet_has_hit := false

var current_move: MoveDefinition
var move_frame := 0
var move_has_hit := false
var buffered_attack: StringName
var buffer_frames := 0


func _init(id: StringName, start_position: Vector2i, character: StringName = &"izuna", dummy := false) -> void:
	fighter_id = id
	character_id = character
	position = start_position
	is_dummy = dummy
	if character_id == &"xenon":
		walk_forward_speed = 4 * UNITS_PER_PIXEL
		walk_back_speed = 3 * UNITS_PER_PIXEL
		dash_speed = 10 * UNITS_PER_PIXEL
		backdash_speed = 9 * UNITS_PER_PIXEL


func queue_attack(action: StringName) -> void:
	buffered_attack = action
	buffer_frames = INPUT_BUFFER_FRAMES


func can_start_attack() -> bool:
	return state in [State.IDLE, State.WALK, State.CROUCH]


func start_move(move: MoveDefinition) -> void:
	state = State.ATTACK
	state_frame = 0
	current_move = move
	move_frame = 0
	move_has_hit = false
	buffered_attack = &""
	buffer_frames = 0


func receive_hit(move: MoveDefinition, attacker_facing: int) -> void:
	health = maxi(0, health - move.damage)
	velocity.x = move.knockback * UNITS_PER_PIXEL * attacker_facing
	current_move = null
	move_frame = 0
	buffered_attack = &""
	buffer_frames = 0
	state_frame = 0
	state = State.KO if health == 0 else State.KNOCKDOWN if move.causes_knockdown else State.HITSTUN
	if character_id == &"xenon":
		clear_puppet()
	if state == State.HITSTUN:
		state_frame = move.hitstun
	elif state == State.KNOCKDOWN:
		state_frame = KNOCKDOWN_FRAMES
		clear_character_mechanic()


func receive_block(move: MoveDefinition, attacker_facing: int, covenant_guard := false) -> void:
	var pushback_divisor := 4 if covenant_guard else 2
	velocity.x = move.knockback * UNITS_PER_PIXEL * attacker_facing / pushback_divisor
	current_move = null
	move_frame = 0
	buffered_attack = &""
	buffer_frames = 0
	state = State.BLOCKSTUN
	var normal_blockstun := maxi(4, move.hitstun - 4)
	state_frame = maxi(3, normal_blockstun / 2) if covenant_guard else normal_blockstun


func receive_burst(attacker_facing: int) -> void:
	velocity.x = BURST_PUSHBACK * attacker_facing
	current_move = null
	move_frame = 0
	buffered_attack = &""
	buffer_frames = 0
	state = State.HITSTUN
	state_frame = BURST_HITSTUN_FRAMES


func gain_conviction(amount: int) -> void:
	conviction = clampi(conviction + amount, 0, CONVICTION_MAX)


func spend_conviction(amount: int) -> bool:
	if conviction < amount:
		return false
	conviction -= amount
	return true


func reset_for_round(start_position: Vector2i) -> void:
	state = State.IDLE
	state_frame = 0
	position = start_position
	velocity = Vector2i.ZERO
	health = 1000
	current_move = null
	move_frame = 0
	move_has_hit = false
	buffered_attack = &""
	buffer_frames = 0
	conviction = 0
	burst_available = true
	clear_character_mechanic()


func apply_memory_mark() -> void:
	if character_id != &"izuna":
		return
	memory_mark_frames = MEMORY_MARK_DURATION


func grant_emotional_echo() -> void:
	if character_id != &"xenon":
		return
	emotional_echo_tokens = 1
	emotional_echo_frames = EMOTIONAL_ECHO_DURATION


func consume_memory_mark_for_recall(force := false) -> bool:
	if character_id != &"izuna" or (memory_mark_frames <= 0 and not force):
		return false
	memory_mark_frames = 0
	recall_delay_frames = RECALL_DELAY_FRAMES
	recall_active_frames = 0
	recall_has_hit = false
	return true


func consume_echo_for_puppet(force := false) -> bool:
	if character_id != &"xenon" or (emotional_echo_tokens <= 0 and not force) or puppet_delay_frames > 0 or puppet_active_frames > 0:
		return false
	emotional_echo_tokens = 0
	emotional_echo_frames = 0
	puppet_delay_frames = PUPPET_DELAY_FRAMES
	puppet_active_frames = 0
	puppet_has_hit = false
	return true


func tick_character_mechanic() -> void:
	if memory_mark_frames > 0:
		memory_mark_frames -= 1
	if emotional_echo_frames > 0:
		emotional_echo_frames -= 1
		if emotional_echo_frames == 0:
			emotional_echo_tokens = 0
	if recall_delay_frames > 0:
		recall_delay_frames -= 1
		if recall_delay_frames == 0:
			recall_active_frames = DELAYED_ACTIVE_FRAMES
	elif recall_active_frames > 0:
		recall_active_frames -= 1
	if puppet_delay_frames > 0:
		puppet_delay_frames -= 1
		if puppet_delay_frames == 0:
			puppet_active_frames = DELAYED_ACTIVE_FRAMES
	elif puppet_active_frames > 0:
		puppet_active_frames -= 1


func clear_character_mechanic() -> void:
	memory_mark_frames = 0
	emotional_echo_tokens = 0
	emotional_echo_frames = 0
	recall_delay_frames = 0
	recall_active_frames = 0
	recall_has_hit = false
	clear_puppet()


func clear_puppet() -> void:
	puppet_delay_frames = 0
	puppet_active_frames = 0
	puppet_has_hit = false


func body_rect() -> Rect2i:
	return Rect2i(
		position.x - BODY_HALF_WIDTH,
		position.y - BODY_HEIGHT,
		BODY_HALF_WIDTH * 2,
		BODY_HEIGHT
	)


func attack_rect() -> Rect2i:
	if state != State.ATTACK or current_move == null or not current_move.is_active(move_frame):
		return Rect2i()

	var width := current_move.reach * UNITS_PER_PIXEL
	var height := current_move.height * UNITS_PER_PIXEL
	var left := position.x + BODY_HALF_WIDTH if facing > 0 else position.x - BODY_HALF_WIDTH - width
	return Rect2i(left, position.y - height, width, height)


func recall_rect() -> Rect2i:
	if recall_active_frames <= 0:
		return Rect2i()
	var width := 220 * UNITS_PER_PIXEL
	var height := 150 * UNITS_PER_PIXEL
	var left := position.x + BODY_HALF_WIDTH if facing > 0 else position.x - BODY_HALF_WIDTH - width
	return Rect2i(left, position.y - height, width, height)


func puppet_rect() -> Rect2i:
	if puppet_active_frames <= 0:
		return Rect2i()
	var width := 120 * UNITS_PER_PIXEL
	var height := 130 * UNITS_PER_PIXEL
	var center_x := position.x + facing * 180 * UNITS_PER_PIXEL
	return Rect2i(center_x - width / 2, position.y - height, width, height)


func is_grounded(ground_y: int) -> bool:
	return position.y >= ground_y
