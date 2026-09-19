class_name FrameInput
extends RefCounted

var left := false
var right := false
var up := false
var down := false
var dash_forward_pressed := false
var backdash_pressed := false
var guard_held := false
var light_pressed := false
var medium_pressed := false
var heavy_pressed := false
var special_pressed := false
var throw_pressed := false
var resource_pressed := false
var ultimate_pressed := false


func horizontal_axis() -> int:
	return int(right) - int(left)
