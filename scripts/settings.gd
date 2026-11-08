extends Node

const PATH := "user://settings.cfg"

var master := 1.0
var music := 1.0
var sfx := 1.0
var fullscreen := false

func _ready() -> void:
	load_settings()
	apply()

func apply() -> void:
	_set_bus("Master", master)
	_set_bus("Music", music)
	_set_bus("SFX", sfx)
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen
		else DisplayServer.WINDOW_MODE_WINDOWED)

func _set_bus(bus_name: String, value: float) -> void:
	var i := AudioServer.get_bus_index(bus_name)
	if i == -1:
		return
	AudioServer.set_bus_volume_db(i, linear_to_db(value))
	AudioServer.set_bus_mute(i, value <= 0.001)

func save_settings() -> void:
	var c := ConfigFile.new()
	c.set_value("audio", "master", master)
	c.set_value("audio", "music", music)
	c.set_value("audio", "sfx", sfx)
	c.set_value("video", "fullscreen", fullscreen)
	c.save(PATH)

func load_settings() -> void:
	var c := ConfigFile.new()
	if c.load(PATH) != OK:
		return
	master = c.get_value("audio", "master", 1.0)
	music = c.get_value("audio", "music", 1.0)
	sfx = c.get_value("audio", "sfx", 1.0)
	fullscreen = c.get_value("video", "fullscreen", false)
