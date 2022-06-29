extends Control

enum {IDLE, READ, MOVINGIN, SPEAKING, WAITING, MOVINGOUT, DONE}

var state = IDLE
var nextState = IDLE

var dialogue = []
var dialogueIndex = 0
var numLines = 0

onready var messageNode = get_node("label")
var messageLength = 0
var messagePercent = 0.0

onready var arrow = get_node("arrow")

var pos = ""
var message = ""
var movementIn = ""
var movementOut = ""

var animationFinishedLeft = false
var animationFinishedRight = false

var activeChar = null
var activeAnim = null



func _ready():
	# sets appropriate global flags
	pg.inCutscene = true
	pg.dontMove = true
	# clears out sprites
	get_node("leftChar").play("empty")
	get_node("rightChar").play("empty")
	get_node("leftCharAnim").play("offScreen")
	get_node("rightCharAnim").play("offScreen")
	arrow.play("hide")
	# for testing
	initialize("test")

func initialize(dialogeName):
	# loads the correct dialoge json
	var filePath = "res://dialogue/" + dialogeName + ".json"
	var file = File.new()
	
	# Pauses the game
	get_tree().paused = true
	
	# checks if file even exists
	if file.file_exists(filePath) == false:
		print("dialogue not found!")
	
	#loads and sotres JSON
	file.open(filePath, file.READ)
	dialogue = parse_json(file.get_as_text())
	numLines = len(dialogue)
	
	# starts FSM
	state = READ

func endDialogue():
	pg.inCutscene = false
	pg.dontMove = false
	get_tree().paused = false
	queue_free()

func skip():
	if (Input.is_action_just_pressed("ui_accept") == true) or (Input.is_action_just_pressed("ui_cancel") == true):
		return true
	else:
		return false
	
func _process(delta):
	match state:
		IDLE:
			pass
		READ:
			# ends if necessary
			if (dialogueIndex >= numLines):
				endDialogue()
				nextState = DONE
				dialogueIndex = 0
			# sets position
			pos = dialogue[dialogueIndex]['pos']
			# sets message
			message = dialogue[dialogueIndex]['text']
			messageNode.percent_visible = 0
			messageNode.text = message
			messageLength = len(message)
			# sets character Sprite and animatioPlayer
			activeChar = get_node(pos + "Char")
			activeChar.play(dialogue[dialogueIndex]['sprite'])
			activeAnim = get_node(pos + "CharAnim")
			# sets movement type
			movementIn = dialogue[dialogueIndex]['move_in']
			movementOut = dialogue[dialogueIndex]['move_out']
			# sets next state and increments
			dialogueIndex += 1
			nextState = MOVINGIN
			# starts move in animation
			activeAnim.play(movementIn + "_in")
		MOVINGIN:
			messageNode.percent_visible = 0.0
			if (animationFinishedLeft or animationFinishedRight):
				nextState = SPEAKING
				animationFinishedLeft = false
				animationFinishedRight = false
			if skip():
				activeAnim.play("still_in")
				animationFinishedLeft = false
				animationFinishedRight = false
				nextState = SPEAKING
		SPEAKING:
			if skip():
				messagePercent = 100
			messagePercent += delta * (100 / (messageLength * 0.025))
			if (messagePercent > 100):
				messagePercent = 100
				nextState = WAITING
				arrow.play("blink")
			messageNode.percent_visible = (messagePercent* 0.01)
		WAITING:
			if skip():
				messagePercent = 0
				nextState = MOVINGOUT
				arrow.play("hide")
				if (movementOut != "none"):
					activeAnim.play(movementOut + "_out")
				else:
					animationFinishedLeft = true
					animationFinishedRight = true
		MOVINGOUT:
			messageNode.percent_visible = 0.0
			if (animationFinishedLeft or animationFinishedRight):
				animationFinishedLeft = false
				animationFinishedRight = false
				nextState = READ
			if skip():
				get_node("leftCharAnim").play("offScreen")
				get_node("rightCharAnim").play("offScreen")
				animationFinishedLeft = false
				animationFinishedRight = false
				nextState = READ
		DONE:
			nextState = DONE
		_:
			pass
	state = nextState

func _on_leftCharAnim_animation_finished(anim_name):
	animationFinishedLeft = true
	

func _on_rightCharAnim_animation_finished(anim_name):
	animationFinishedRight = true
