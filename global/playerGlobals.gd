extends Node

# player variables
var playerStartingMaxHP = 100 #100
var playerStartingLives = 3 #3
var totalMoney = 0
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

# cheats
var unlimitedLives = false
var unlimitedMoney = false
var hardcoreMode   = false

# destination level info
var levelName = "test"
var levelMusic = "ripple"
var levelNum = 0

# playable characters
var hasMarcy  = true
var hasSasha  = true
var hasSprig = true
var hasMaggie = false
var availableChars = ["Anne"]

# Completed levels
var completedLevels = [true, true, false, false, false, false, false, false, false, false, false,]

# game over stuff
var GOCount = 0

# pauses player for cutscenes/other events
var dontMove = false


func recalcInfo():
	# characters
	availableChars = ["Anne"]
	if hasMarcy:
		availableChars.append("Marcy")
	if hasSasha:
		availableChars.append("Sasha")
	if hasSprig:
		availableChars.append("Sprig")
	if hasMaggie:
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
	
#func _process(_delta):
	#pass
	

func countPlayers():
	var count = 0
	for i in playerAlive:
		if i:
			count += 1
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
