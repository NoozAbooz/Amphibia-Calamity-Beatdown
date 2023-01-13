extends Node

# player variables
var playerStartingMaxHP = 100 #100
var playerStartingLives = 3 #3
var totalMoney = 1237
var newMoney = 0
var kills = 0 # Used to count in ambushes
var killsTotal = 0 # Used to count total kills

# upgrades
var healthUpgrades = 0 # 20 per upgrade, max 3
var livesUpgrades  = 0 # 1 life per upgrade, max 3
var damageUpgrades = 0 # 20% per upgrade, max 3
var luckUpgrades   = 0 # increase coin drop by 1 and drop chances by 5%, max 3. Influences barrel drops.
const healthBoost  = 20
const livesBoost   = 1
const damageBoost  = 0.2
const coinBoost    = 1
const dropBoost    = 0.05
const techBoost    = 0.20


# attack unlocks
var hasSpin    = false
var hasSlide   = false
var hasAirSpin = false
var hasDJ      = false
var hasCounter = false

# numer of players / player inputs
var availableInputs = ["k0"]
var playerActive = [false, false, false, false]
var playerReady = [true, true, true, true]
var playerAlive = [false, false, false, false]
var playerInput = ["X", "X", "X", "X"]
var playerCharacter = ["Anne", "Anne", "Anne", "Anne"]
var playerLives = [0, 0, 0, 0]
var playerCoins = [0, 0, 0, 0]
var numPlayers = 1
var playerFixPos = [false, false, false, false]

# cheats
var unlimitedLives = false
var unlimitedMoney = false
var hardcoreMode   = false
var allCharsMode   = true
var easyMode       = false
var hardMode       = false
 
# destination level info
var levelName = "test"
var levelNameDisc = "test"
var levelMusic = "ripple"
var levelNum = 0

# playable characters
var hasMarcy  = false
var hasSasha  = false
var hasSprig = true
var hasMaggie = false
var hasGrime = false
var availableChars = ["Anne"]

# Completed levels
#                     [Wartwood, Test,  l1,    l2,    l3,    l4,    l5,    l6,    l7,    l8,    l9,   final]
var completedLevels = [  true,   true, true, false, false, false, false, false, false, false, false, false]
var unlockedFinalLevel = false

# game over stuff
var GOCount = 0

# pauses player for cutscenes/other events
var dontMove = false
var inCutscene = false

# wartwood flags
var seenToadstool = false
var seenMaddie = false
var firstTimeInWartwood = true
var currentStore = 0 # 0 = none; 1 = city hall; 2 = Maddie; 3 = Felicia

# debug flags
var debugCameraAvailable = false

func recalcInfo():
	# characters
	availableChars = ["Anne"]
	if hasSprig or allCharsMode:
		availableChars.append("Sprig")
	if hasSasha or allCharsMode:
		availableChars.append("Sasha")
	if hasMarcy or allCharsMode:
		availableChars.append("Marcy")
	if hasGrime or allCharsMode:
		availableChars.append("Grime")
	if hasMaggie or allCharsMode:
		availableChars.append("Maggie")
	# inputs
	checkAvailableInputs()

func checkAvailableInputs():
	availableInputs = ["k0"]
	for i in range(0, len(Input.get_connected_joypads())):
		availableInputs.append(str(i))

	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(_delta):
	# checks for keyboard presses for options
	if(Input.is_action_just_pressed("fullscreen") == true):
		OS.set_window_fullscreen(!OS.window_fullscreen)
	if(Input.is_action_just_pressed("mute") == true):
		var busIndex = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(busIndex, !AudioServer.is_bus_mute(busIndex))
		#print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

func countPlayers():
	var count = 0
	for i in playerAlive:
		if i:
			count += 1
	return count

# returns number of completed levels. Note Wartwood and the test playground are levels
# 0 and 1 and are not included in the count
func countCompletedLevels():
	var count = 0
	for i in completedLevels:
		if i:
			count += 1
	#removes levels 0 and 1
	count -= 2
	if count <= 0:
		count = 0
	return count
	

func backToMapLose():
	soundManager.stopMusic()
	tran.loadLevel("res://scenes/menus/mapOpen.tscn")
	
func endLevel():
	# prevents player actions
	dontMove = true
	# stops music
	soundManager.FadeOutSong(levelMusic)
	# plays transitioner to fade and open tally scene
	tran.endLevel()
	
func spend(amount):
	totalMoney -= amount
	if (totalMoney <= 0):
		totalMoney = 0
