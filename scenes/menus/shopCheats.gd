extends Control

var dialogueScene = preload("res://scenes/menus/dialogueBox.tscn")

onready var main = get_node("main")

# buttons
onready var easy = $main/diff/easy
onready var normal = $main/diff/normal
onready var hard = $main/diff/hard
onready var one = $main/lives/one
onready var default = $main/lives/default
onready var unlimited = $main/lives/unlimited
onready var cashOn = $main/cash/cashOn
onready var cashOff = $main/cash/cashOff
onready var charsOn = $main/chars/charOn
onready var charsOff = $main/chars/charOff

var curButtonDesc = ""

# used to prevent opening menus while unloading the store
var loading = false




# Called when the node enters the scene tree for the first time.
func _ready():
	
	refreshShop()
	
	# plays music for shop
	soundManager.playMusic("map")
	
	# signals from buttons
	easy.connect("focus_entered", self, "_on_button_focus_entered", ["Players deal more damage and take less damage."])
	normal.connect("focus_entered", self, "_on_button_focus_entered", ["Players deal and receive regular damage."])
	hard.connect("focus_entered", self, "_on_button_focus_entered", ["Players receive double damage."])
	easy.connect("pressed", self, "_on_button_pressed", ["easy"])
	normal.connect("pressed", self, "_on_button_pressed", ["normal"])
	hard.connect("pressed", self, "_on_button_pressed", ["hard"])
	
	# intro dialogue
	if (pg.seenToadstool):
		playDialogue("fel_enter")
	else:
		playDialogue("fel_enter")
	
	get_node("main/buttonExit").grab_focus()
	
func refreshShop():
	# changes description at bottom of screen
	get_node("NinePatchRect/description").text = curButtonDesc
	# Difficulty buttons
	if (pg.easyMode) and (pg.hardMode): #just in case ;)
		pg.easyMode = false
		pg.hardMode = false
	if (pg.easyMode):
		easy.pressed   = true
		normal.pressed = false
		hard.pressed   = false
	elif (pg.hardMode):
		easy.pressed   = false
		normal.pressed = false
		hard.pressed   = true
	else:
		easy.pressed   = false
		normal.pressed = true
		hard.pressed   = false
	# Lives buttons
	if (pg.unlimitedLives) and (pg.hardcoreMode): #just in case ;)
		pg.unlimitedLives = false
		pg.hardcoreMode   = false
	if (pg.unlimitedLives):
		unlimited.pressed = true
		default.pressed   = false
		one.pressed       = false
	elif (pg.hardcoreMode):
		unlimited.pressed = false
		default.pressed   = false
		one.pressed       = true
	else:
		unlimited.pressed = false
		default.pressed   = true
		one.pressed       = false
	# cash buttons
	if (pg.unlimitedMoney):
		cashOn.pressed  = true
		cashOff.pressed = false
	else:
		cashOn.pressed  = false
		cashOff.pressed = true
	# character buttons
	if (pg.allCharsMode):
		charsOn.pressed  = true
		charsOff.pressed = false
	else:
		charsOn.pressed  = false
		charsOff.pressed = true
	
	#print("easy: " + str(pg.easyMode) + "   |   hard: " + str(pg.hardMode))

func _on_buttonExit_focus_entered():
	curButtonDesc = "Return to Wartwood?"
	refreshShop()

func _on_buttonExit_pressed():
	if (loading):
		return
	# sets timer (timer is paused durring dialogue
	loading = true
	get_node("Timer").start()
	playDialogue("fel_exit")
	
func playDialogue(dialogueName):
	# finds first alive player
	var playerName = "Anne"
	for i in range(0, 4):
		if (pg.playerAlive[i]):
			playerName = pg.playerCharacter[i]
			break
	var newDialogue = dialogueScene.instance()
	self.add_child(newDialogue)
	newDialogue.initialize(dialogueName, playerName)

# handles "back" button presses
#func _process(delta):
#	pass

func _on_Timer_timeout():
	tran.loadLevel("res://maps/wartwood.tscn")


func _on_button_focus_entered(desc):
	curButtonDesc = desc
	refreshShop()
	
func _on_button_pressed(buttonName):
	match buttonName:
		"easy":
			pg.easyMode = true
			pg.hardMode = false
		"normal":
			pg.easyMode = false
			pg.hardMode = false
		"hard":
			pg.easyMode = false
			pg.hardMode = true
	
	refreshShop()	


