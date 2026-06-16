class_name FighterSimulation
extends RefCounted

enum State {
	IDLE,
	WALK,
	CROUCH,
	AIRBORNE,
	DASH,
	BACKDASH,
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

var fighter_id: StringName
var state := State.IDLE
var state_frame := 0
var position := Vector2i.ZERO
var velocity := Vector2i.ZERO
var facing := 1
var health := 1000
var is_dummy := false
var rounds_won := 0

var current_move: MoveDefinition
var move_frame := 0
var move_has_hit := false
var buffered_attack: StringName
var buffer_frames := 0


func _init(id: StringName, start_position: Vector2i, dummy := false) -> void:
	fighter_id = id
	position = start_position
	is_dummy = dummy


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
	if state == State.HITSTUN:
		state_frame = move.hitstun
	elif state == State.KNOCKDOWN:
		state_frame = KNOCKDOWN_FRAMES


func receive_block(move: MoveDefinition, attacker_facing: int) -> void:
	velocity.x = move.knockback * UNITS_PER_PIXEL * attacker_facing / 2
	current_move = null
	move_frame = 0
	buffered_attack = &""
	buffer_frames = 0
	state = State.BLOCKSTUN
	state_frame = maxi(4, move.hitstun - 4)


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


func is_grounded(ground_y: int) -> bool:
	return position.y >= ground_y
