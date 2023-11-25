extends Node3D

const TIME_RUNNING_OUT = 100
const  SPEED_UP_FACTOR = 1.1

var timer_value = 0
var time_interval = 1.0
var runningOut = false

@onready var timeValueLabel = $"CanvasLayer/VBoxContainer/TIME value"

func _ready():
	$CanvasLayer/ColorRect.color = Color(0, 0, 0, 255)
	timeValueLabel.set_text(str(timer_value))

	if get_node("Player").isLuigi:
		get_node("CanvasLayer/TextureRect2").call_deferred("set_texture", load("res://assets/textures/Luigi HUD.png"))

func _process(delta):
	timer_value += delta
	var timeStr = str(round(timer_value))
	if timeStr.length() < 2:
		timeStr = "00" + timeStr
	elif timeStr.length() < 3:
		timeStr = "0" + timeStr
	timeValueLabel.set_text(timeStr)
	
	if !runningOut and timer_value > TIME_RUNNING_OUT:
		speedUp()

func speedUp():
	runningOut = true
	$Music.pitch_scale = SPEED_UP_FACTOR
	$UndergroundMusic.pitch_scale = SPEED_UP_FACTOR
	$Music.seek(1.82)
	$UndergroundMusic.seek(0)

func HideMountains(isHiding):
	$"Yoshi's Island 1".visible = !isHiding
	var mountains = get_tree().get_nodes_in_group("Mountains")
	for mountain in mountains:
		mountain.visible = !isHiding
