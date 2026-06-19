extends Node

var _hit_stop_version := 0
var _hit_stop_active := false
var _hit_stop_restore_scale := 1.0
var _shake_strength := 0.0
var _shake_end_ms := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return

	if Time.get_ticks_msec() < _shake_end_ms:
		var offset := Vector2(
			randf_range(-_shake_strength, _shake_strength),
			randf_range(-_shake_strength, _shake_strength)
		).round()
		camera.offset = offset
	else:
		camera.offset = Vector2.ZERO
		_shake_strength = 0.0


func hit_stop(duration := 0.05, time_scale := 0.05) -> void:
	_hit_stop_version += 1
	var version := _hit_stop_version
	if not _hit_stop_active:
		_hit_stop_restore_scale = Engine.time_scale
		_hit_stop_active = true

	Engine.time_scale = minf(Engine.time_scale, time_scale)
	await get_tree().create_timer(duration, true, false, true).timeout

	if version == _hit_stop_version:
		Engine.time_scale = _hit_stop_restore_scale
		_hit_stop_active = false


func shake(strength := 2.0, duration := 0.1) -> void:
	_shake_strength = maxf(_shake_strength, strength)
	_shake_end_ms = maxi(
		_shake_end_ms,
		Time.get_ticks_msec() + int(duration * 1000.0)
	)


func impact(
	stop_duration := 0.05,
	shake_strength := 2.0,
	shake_duration := 0.1
) -> void:
	hit_stop(stop_duration)
	shake(shake_strength, shake_duration)
