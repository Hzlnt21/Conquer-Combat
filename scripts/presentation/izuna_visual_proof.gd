extends Node2D

const BASE_ART_SCALE := Vector2(0.57, 0.57)
const BASE_ART_POSITION := Vector2(640.0, 358.0)

@onready var art: Sprite2D = %Art
@onready var status_label: Label = %StatusLabel

var animation_time := 0.0
var animation_paused := false
var show_guides := true


func _ready() -> void:
	art.scale = BASE_ART_SCALE
	art.position = BASE_ART_POSITION
	_update_status()
	queue_redraw()


func _process(delta: float) -> void:
	if animation_paused:
		return
	animation_time += delta
	var breath := sin(animation_time * 2.1)
	var sway := sin(animation_time * 1.05)
	art.position = BASE_ART_POSITION + Vector2(sway * 1.5, breath * 2.5)
	art.rotation = deg_to_rad(sway * 0.25)
	art.scale = BASE_ART_SCALE * (1.0 + breath * 0.0025)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_SPACE:
		animation_paused = not animation_paused
		_update_status()
	elif event.keycode == KEY_F1:
		show_guides = not show_guides
		queue_redraw()
		_update_status()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("0d0a13"))
	draw_circle(Vector2(640, 255), 235, Color("211526"))
	draw_arc(Vector2(640, 255), 235, 0, TAU, 96, Color("5d3047"), 2.0)
	draw_rect(Rect2(0, 650, 1280, 70), Color("17121d"))
	draw_line(Vector2(0, 650), Vector2(1280, 650), Color("9b626c"), 3.0)

	if not show_guides:
		return
	draw_dashed_line(Vector2(340, 62), Vector2(340, 650), Color("5f97ae"), 1.0, 8.0)
	draw_dashed_line(Vector2(940, 62), Vector2(940, 650), Color("5f97ae"), 1.0, 8.0)
	draw_line(Vector2(632, 650), Vector2(648, 650), Color("ffd28a"), 3.0)
	draw_line(Vector2(640, 642), Vector2(640, 658), Color("ffd28a"), 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(24, 690), "Target body height: 560-590 px | floor y=650 | root x=640", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("aabdc7"))


func _update_status() -> void:
	var playback := "PAUSED" if animation_paused else "PLAYING"
	var guides := "ON" if show_guides else "OFF"
	status_label.text = "Idle presentation: %s | F1 guides %s | Space pause" % [playback, guides]
