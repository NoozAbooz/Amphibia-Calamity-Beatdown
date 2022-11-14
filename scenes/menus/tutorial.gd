extends Control

var messagePercent = 0
var messageLength = 0
var messageText = ""
onready var messageNode = get_node("label")

var animationNum = -3

var skippable = false

var loading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("startButton").grab_focus()
	soundManager.playMusicIfDiff("tutorial")
	$"arrowContinue".hide()


func _process(delta):
	# Advances text
	if (messageText != messageNode.text):
		messageNode.text = messageText
	if (messageLength > 0) and (messagePercent != 100):
		messagePercent += delta * (100 / (messageLength * 0.025))
	if (messagePercent > 100):
		messagePercent = 100
		$"arrowContinue".show()
	messageNode.percent_visible = (messagePercent* 0.01)
	# skips
	if (Input.is_action_just_pressed("pause") == true):
		tran.loadLevel("res://scenes/menus/mapOpen.tscn")
	if (Input.is_action_just_pressed("ui_accept") == true):
#		var animationNum = get_node("AnimationPlayer").current_animation
#		_on_AnimationPlayer_animation_finished(animationNum)
		advance()
		
func advance():
	if not skippable:
		return
	elif (animationNum == 16):
		finished()
	else:
		animationNum = animationNum + 1
		$"AnimationPlayer".play(str(animationNum))
		$"arrowContinue".hide()

func speak(dialogue):
	messagePercent = 0
	messageText = dialogue
	messageLength = len(dialogue)
	
	
func _on_startButton_pressed():
	pass
	#tran.loadLevel("res://scenes/menus/mapOpen.tscn")

func _on_AnimationPlayer_animation_finished(anim_name):
	skippable = true
#	if (anim_name == "16"):
#		finished()
#	else:
#		var nextAnim = int(anim_name) + 1
#		$"AnimationPlayer".play(str(nextAnim))
	
func finished():
	if not loading:
		loading = true
		$"AnimationPlayer".stop()
		tran.loadLevel("res://scenes/menus/mapOpen.tscn")
	else:
		pass
