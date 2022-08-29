extends Control

var playerNumber = 0
var playerChoice = "Anne"
var playerChoiceIndex = 0
var playerInput = "k0"
var playerInputIndex = 0
var ready = false
var superReady = false
var readyTimer = 0
var dotTimer = 0
var dotText = ""
var hue = 0.630

func incChoiceIndex(num):
	# increments index
	playerChoiceIndex += num
	if (playerChoiceIndex < 0):
		playerChoiceIndex = pg.availableChars.size() - 1
	if (playerChoiceIndex >= pg.availableChars.size()):
		playerChoiceIndex = 0
	# sets choice based on new index
	playerChoice = pg.availableChars[playerChoiceIndex]
	# updates globals
	pg.playerCharacter[playerNumber] = playerChoice
	# plays a sound
	soundManager.playSound("counter")
	
func incInputIndex(num):
	# increments index
	playerInputIndex += num
	if (playerInputIndex < 0):
		playerInputIndex = pg.availableInputs.size() - 1
	if (playerInputIndex >= pg.availableInputs.size()):
		playerInputIndex = 0
	# sets input based on new index
	playerInput = pg.availableInputs[playerInputIndex]
	# updates globals
	pg.playerInput[playerNumber] = playerInput

func setHue():
	if (playerChoice == "Anne"):
		hue = 0.630
	elif (playerChoice == "Marcy"):
		hue = 0.364
	elif (playerChoice == "Sasha"):
		hue = 0.883
	elif (playerChoice == "Maggie"):
		hue = 0.053
	
# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass
	
func initialize(number, inp):
	playerNumber = number
	# makes sure unlocked characters are available
	pg.recalcInfo()
	# updates inputs list
	pg.checkAvailableInputs()
	# updates active player global array
	pg.playerActive[playerNumber] = true
	pg.playerReady[playerNumber] = false
	# positions player panel
	self.anchor_left = playerNumber * 0.25
	# removes delete button for player 1
	#if (playerNumber == 0):
		#$buttonRemove.hide()
	# sets default input
	if (inp != "k0"):
		playerInputIndex = int(inp) + 1
		playerInput = inp
		pg.playerInput[playerNumber] = playerInput
	else:
		playerInputIndex = 0
		playerInput = inp
		pg.playerInput[playerNumber] = playerInput
	# plays idle animation for face
	$AnimationPlayer.play("idle")


func _process(_delta):
	# sets character face, labels, bg, etc
	$faces.play(playerChoice)
	$labelPlayer.text = ("PLAYER " + str(playerNumber + 1))
	$labelCharacter.text = (str(playerChoice))
	if (playerInput == "k0"):
		$labelInput.text = ("Keyboard")
	else:
		$labelInput.text = ("Controller " + str(int(playerInput) + 1))
	setHue()
	$bg.color = Color.from_hsv(hue, 0.75, 0.75, 1)
	
	# removes characters with esc/select
	if (Input.is_action_just_pressed(playerInput + "_leave") == true):
		if ready:
			ready = false
			$AnimationPlayer.play("idle")
		else:
			_on_buttonRemove_pressed()
	# cyles through characters
	if (Input.is_action_just_pressed("move_left_" + playerInput) == true) and (ready == false):
		incChoiceIndex(-1)
	if (Input.is_action_just_pressed("move_right_" + playerInput) == true) and (ready == false):
		incChoiceIndex(1)
	# ready to go!
	if (Input.is_action_just_pressed(playerInput + "_enter") == true):
		if (ready == false):
			ready = true
			get_parent().justPicked = true
			$AnimationPlayer.play("bounce")
			#$AnimationPlayer.play("light")
			soundManager.playSound("1up")
		else:
			readyTimer += 180
	if ready:
		$arrows.visible = false
		$labelDots.visible = false
		readyTimer += 1
		$labelReady.text = "READY!"
	else:
		$arrows.visible = true
		$labelDots.visible = true
		readyTimer = 0
		$labelReady.text = "Selecting\nCharacter"
	# makes "selecting" text change
	if ready:
		dotTimer = 0
		dotText = ""
	else:
		dotTimer += 1
		if (dotTimer >= 30):
			dotTimer = 0
			dotText = (dotText + ".")
		if (dotText == "...."):
			dotText = ""
		$labelDots.text = dotText
	# flags that player is reeady and waited 3 sec
	if (readyTimer >= 150):
		pg.playerReady[playerNumber] = true
	else:
		pg.playerReady[playerNumber] = false
	# testing
	#print(readyTimer)
	


func _on_buttonRight_pressed():
	incChoiceIndex(1)


func _on_buttonLeft_pressed():
	incChoiceIndex(-1)


func _on_buttonRemove_pressed():
	# updates player global arrays to default
	pg.playerActive[playerNumber] = false
	pg.playerInput[playerNumber] = "X"
	pg.playerCharacter[playerNumber] = "Anne"
	readyTimer = 200 # so the player ready flag doesn;t reset to false before unloading
	ready = true
	pg.playerReady[playerNumber] = true
	get_parent().resetPlayerLeftTimer()
	queue_free()
