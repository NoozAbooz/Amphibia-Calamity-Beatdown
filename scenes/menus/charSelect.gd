extends Control

var charBlockScene = preload("res://scenes/menus/characterBlock.tscn")

var nextOpen = 0

var loading = false

# a flag that exists so controllers that count as 2 inputs (Newer XBox) don't 
# create two character blocks and thus two characters
var DoublesCheckReady = true 

func findNextSlot():
	nextOpen = 0
	for i in range(0, pg.playerActive.size()):
		if (pg.playerActive[i] == false):
			nextOpen = i
			return
	nextOpen = 5
	print(nextOpen)

# Called when the node enters the scene tree for the first time.
func _ready():
	# sets global player arrays to default
	pg.playerActive = [false, false, false, false]
	pg.playerReady = [true, true, true, true]
	pg.playerInput = ["X", "X", "X", "X"]
	pg.playerCharacter = ["Anne", "Anne", "Anne", "Anne"]
	# focus
	#$mapButton.grab_focus()

func createBlock(playerNumber, inp):
	if (DoublesCheckReady == false):
		return
	var block = charBlockScene.instance()
	add_child(block)
	block.initialize(playerNumber, inp)
	DoublesCheckReady = false
	get_node("noDoublesTimer").start()
	#print(DoublesCheckReady)

func _process(_delta):
	# prevents more actions if a new scene is being loaded
	if loading:
		return
	# jumps to level if all ready
	if (pg.playerReady == [true, true, true, true]) and (pg.playerActive != [false, false, false, false]):
		goToStage()
		return
	#adds controler players (keyboard players in function below)
	findNextSlot()
	if (Input.is_action_just_pressed("k0_enter") == true) and (pg.playerInput.has("k0") == false) and (nextOpen <= 3):
		createBlock(nextOpen, "k0")
	findNextSlot()
	if (Input.is_action_just_pressed("0_enter") == true) and (pg.playerInput.has("0") == false) and (nextOpen <= 3):
		createBlock(nextOpen, "0")
	findNextSlot()
	if (Input.is_action_just_pressed("1_enter") == true) and (pg.playerInput.has("1") == false) and (nextOpen <= 3):
		createBlock(nextOpen, "1")
	findNextSlot()
	if (Input.is_action_just_pressed("2_enter") == true) and (pg.playerInput.has("2") == false) and (nextOpen <= 3):
		createBlock(nextOpen, "2")
	# returns to map if back is pressed by k0 or 0 and they are not picking a character
	if (pg.playerInput.has("k0") == false) and (Input.is_action_just_pressed("k0_leave") == true):
		goBack()
	for i in range(0, 3):
		if (pg.playerInput.has(str(i)) == false) and (Input.is_action_just_pressed(str(i) + "_leave") == true):
			goBack()
	

func goToStage():
	if (pg.playerActive != [false, false, false, false]):
		loading = true
		tran.loadLevel("res://maps/" + pg.levelName + ".tscn")


func goBack():
	loading = true
	tran.loadLevel("res://scenes/menus/mapScreen.tscn")


func _on_noDoublesTimer_timeout():
	DoublesCheckReady = true
