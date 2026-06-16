class_name MoveDefinition
extends RefCounted

var id: StringName
var startup: int
var active: int
var recovery: int
var damage: int
var hitstop: int
var hitstun: int
var reach: int
var height: int
var knockback: int
var causes_knockdown: bool


func _init(
	move_id: StringName,
	startup_frames: int,
	active_frames: int,
	recovery_frames: int,
	move_damage: int,
	move_hitstop: int,
	move_hitstun: int,
	move_reach: int,
	move_height: int,
	move_knockback: int,
	move_causes_knockdown := false
) -> void:
	id = move_id
	startup = startup_frames
	active = active_frames
	recovery = recovery_frames
	damage = move_damage
	hitstop = move_hitstop
	hitstun = move_hitstun
	reach = move_reach
	height = move_height
	knockback = move_knockback
	causes_knockdown = move_causes_knockdown


func total_frames() -> int:
	return startup + active + recovery


func is_active(frame: int) -> bool:
	return frame >= startup and frame < startup + active
