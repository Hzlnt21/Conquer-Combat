class_name AudioDirector
extends Node

const MIX_RATE := 44100

var master_volume := 0.78
var music_enabled := true
var sounds: Dictionary[StringName, AudioStreamWAV] = {}
var music_player: AudioStreamPlayer


func _ready() -> void:
	sounds[&"ui"] = _make_tone(520.0, 760.0, 0.075, 0.22, 0.0)
	sounds[&"attack"] = _make_tone(230.0, 120.0, 0.085, 0.24, 0.34)
	sounds[&"hit"] = _make_tone(105.0, 48.0, 0.14, 0.48, 0.58)
	sounds[&"block"] = _make_tone(680.0, 310.0, 0.11, 0.3, 0.22)
	sounds[&"special"] = _make_tone(260.0, 920.0, 0.24, 0.34, 0.12)
	sounds[&"burst"] = _make_tone(90.0, 980.0, 0.32, 0.48, 0.4)
	sounds[&"ultimate"] = _make_tone(72.0, 540.0, 0.62, 0.58, 0.2)
	sounds[&"round"] = _make_tone(330.0, 660.0, 0.38, 0.38, 0.0)
	music_player = AudioStreamPlayer.new()
	music_player.name = "AmbientMusic"
	music_player.stream = _make_ambient_loop()
	add_child(music_player)
	_sync_music_volume()
	music_player.play()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_sync_music_volume()


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	_sync_music_volume()


func play_ui() -> void:
	_play(&"ui", -5.0)


func process_events(events: Array[Dictionary]) -> void:
	for event in events:
		match event.get("type", &""):
			&"attack_started":
				_play(&"attack", -12.0)
			&"hit_connected":
				_play(&"hit", -2.0)
			&"attack_blocked":
				_play(&"block", -5.0)
			&"throw_teched":
				_play(&"block", -1.0)
			&"delayed_effect_started", &"conquer_art_started", &"shift_cancel":
				_play(&"special", -5.0)
			&"burst_activated":
				_play(&"burst", -1.0)
			&"ultimate_started":
				_play(&"ultimate", 0.0)
			&"round_ended", &"match_ended":
				_play(&"round", -2.0)


func _play(sound_id: StringName, volume_offset_db := 0.0) -> void:
	if not sounds.has(sound_id) or master_volume <= 0.001:
		return
	var player := AudioStreamPlayer.new()
	player.stream = sounds[sound_id]
	player.volume_db = linear_to_db(master_volume) + volume_offset_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _sync_music_volume() -> void:
	if music_player == null:
		return
	music_player.volume_db = -80.0 if not music_enabled or master_volume <= 0.001 else linear_to_db(master_volume) - 18.0


func _exit_tree() -> void:
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
	sounds.clear()


func _make_tone(start_frequency: float, end_frequency: float, duration: float, amplitude: float, noise_mix: float) -> AudioStreamWAV:
	var frame_count := maxi(1, int(MIX_RATE * duration))
	var data := PackedByteArray()
	data.resize(frame_count * 4)
	var phase := 0.0
	for frame in range(frame_count):
		var progress := frame / float(frame_count)
		var frequency := lerpf(start_frequency, end_frequency, progress)
		phase += TAU * frequency / MIX_RATE
		var envelope := pow(1.0 - progress, 2.2) * minf(1.0, progress * 30.0)
		var noise := sin(float(frame * frame * 17 + 31))
		var waveform := lerpf(sin(phase), noise, noise_mix) * envelope * amplitude
		var sample := clampi(int(waveform * 32767.0), -32768, 32767)
		data.encode_s16(frame * 4, sample)
		data.encode_s16(frame * 4 + 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = true
	stream.data = data
	return stream


func _make_ambient_loop() -> AudioStreamWAV:
	var duration := 6.0
	var frame_count := int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(frame_count * 4)
	var notes := [55.0, 65.41, 73.42, 49.0]
	for frame in range(frame_count):
		var time := frame / float(MIX_RATE)
		var note_index := mini(notes.size() - 1, int(time / 1.5))
		var base: float = notes[note_index]
		var pulse := 0.62 + 0.38 * sin(TAU * 0.5 * time)
		var pad := sin(TAU * base * time) * 0.045
		pad += sin(TAU * base * 1.5 * time + 0.7) * 0.022
		pad += sin(TAU * base * 2.0 * time + 1.4) * 0.012
		var shimmer := sin(TAU * (base * 4.0) * time) * 0.006 * pulse
		var sample := clampi(int((pad + shimmer) * 32767.0), -32768, 32767)
		data.encode_s16(frame * 4, sample)
		data.encode_s16(frame * 4 + 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = true
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = frame_count
	stream.data = data
	return stream
