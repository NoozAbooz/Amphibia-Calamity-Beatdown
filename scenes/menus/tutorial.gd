extends Control

var messagePercent = 0
var messageLength = 0
var messageText = ""
onready var messageNode = get_node("label")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("startButton").grab_focus()
	soundManager.playMusicIfDiff("tutorial")


func _process(delta):
	# Advances text
	if (messageText != messageNode.text):
		messageNode.text = messageText
	if (messageLength > 0) and (messagePercent != 100):
		messagePercent += delta * (100 / (messageLength * 0.025))
	if (messagePercent > 100):
		messagePercent = 100
	messageNode.percent_visible = (messagePercent* 0.01)
	# skips
	if (Input.is_action_just_pressed("pause") == true) or (Input.is_action_just_pressed("k0_enter") == true):
		tran.loadLevel("res://scenes/menus/mapOpen.tscn")
	if (Input.is_action_just_pressed("ui_accept") == true):
		var animationNum = get_node("AnimationPlayer").current_animation
		_on_AnimationPlayer_animation_finished(animationNum)

func speak(dialogue):
	messagePercent = 0
	messageText = dialogue
	messageLength = len(dialogue)
	
	
func _on_startButton_pressed():
	pass
	#tran.loadLevel("res://scenes/menus/mapOpen.tscn")

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "15"):
		finished()
	else:
		var nextAnim = int(anim_name) + 1
		$"AnimationPlayer".play(str(nextAnim))
	
func finished():
	$"AnimationPlayer".stop()
	tran.loadLevel("res://scenes/menus/mapOpen.tscn")
