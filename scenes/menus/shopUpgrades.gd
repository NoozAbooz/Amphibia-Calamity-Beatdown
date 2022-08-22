extends Control

var dialogueScene = preload("res://scenes/menus/dialogueBox.tscn")

onready var main = get_node("main")
onready var conf = get_node("confirm")

var boughtSomething = false

var state = "main"

# used to prevent opening menus while unloading the store
var loading = false

class item:
	var title = ""
	var cost = 0
	var desc = ""
	var vid
	var num = 0
	var dialogue = "wally_boom"

# costs
var defaultCost = 100
var costIncrement = 75
var COST0 = 0
var COST1 = 0
var COST2 = 0
var COST3 = 0

var curItem = item.new()
var item0 = null
var item1 = null
var item2 = null
var item3 = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# unlimied money code
	if (pg.unlimitedMoney):
		COST0 = 0
		COST1 = 0
		COST2 = 0
		COST3 = 0
		
	# available items
	item0 = item.new()
	item0.num = 0
	item0.title = "Health Upgrade"
	item0.cost = COST0
	item0.desc = "Increases max HP by 20 percent"
	item0.dialogue = "mad_hp"
	
	item1 = item.new()
	item1.num = 1
	item1.title = "Extra Lives Upgrade"
	item1.cost = COST1
	item1.desc = "Start with 1 additional extra life in every level."
	item1.dialogue = "mad_lives"
	
	item2 = item.new()
	item2.num = 2
	item2.title = "Damage Upgrade"
	item2.cost = COST2
	item2.desc = "Increases damage from all attacks by 20 percent"
	item2.dialogue = "mad_dam"
	
	item3 = item.new()
	item3.num = 3
	item3.title = "Luck Upgrade"
	item3.cost = COST3
	item3.desc = "Increases odds of enemies and barrels dropping better items."
	item3.dialogue = "mad_luck"
	
	refreshShop()
	
	# plays music for shop
	soundManager.playMusic("map")
	
	# hides confirmation menu for now
	get_node("confirm").hide()
	
	# intro dialogue
	playDialogue("mad_enter")
	
	get_node("main/buttonExit").grab_focus()
	
func switchToConfirm():
	state = "confirm"
	get_node("main").hide()
	get_node("confirm").show()
	get_node("confirm/NinePatchRect/buttonNo").grab_focus()
	get_node("confirm/NinePatchRect/description").text = "Purchase " + str(curItem.title) + " for " + str(curItem.cost) + " Coppers?"

func switchToMain():
	state = "main"
	get_node("main").show()
	get_node("confirm").hide()
	get_node("main/buttonExit").grab_focus()
	refreshShop()
	
func buyItem(item):
	pg.spend(item.cost)
	match item.num:
		0:
			pg.healthUpgrades += 1
		1:
			pg.livesUpgrades  += 1
		2:
			pg.damageUpgrades += 1
		3:
			pg.luckUpgrades   += 1
		_:
			pass
	playDialogue(item.dialogue)
	switchToMain()
	
func refreshShop():
	# changes description at bottom of screen
	get_node("NinePatchRect/description").text = curItem.desc
	
	# updates total
	get_node("pockets/totalMoney").text = str(pg.totalMoney)
	
	# determines costs of available upgrades
	COST0 = defaultCost + (costIncrement * pg.healthUpgrades)
	COST1 = defaultCost + (costIncrement * pg.livesUpgrades)
	COST2 = defaultCost + (costIncrement * pg.damageUpgrades)
	COST3 = defaultCost + (costIncrement * pg.luckUpgrades)
	# unlimied money code
	if (pg.unlimitedMoney):
		COST0 = 0
		COST1 = 0
		COST2 = 0
		COST3 = 0
	# sets items costs
	item0.cost = COST0
	item1.cost = COST1
	item2.cost = COST2
	item3.cost = COST3
	
	# shows/hides buttons and costs depending on global flags
	if (pg.healthUpgrades >= 3):
		get_node("main/options/buttonItem0").disabled = true
		get_node("main/options/cost0").hide()
		item0.desc = ""
	elif (pg.totalMoney < COST0):
		get_node("main/options/buttonItem0").disabled = true
		get_node("main/options/cost0").show()
		get_node("main/options/cost0").text = str(COST0)
	else:
		get_node("main/options/buttonItem0").disabled = false
		get_node("main/options/cost0").show()
		get_node("main/options/cost0").text = str(COST0)
		
	if (pg.livesUpgrades >= 3):
		get_node("main/options/buttonItem1").disabled = true
		get_node("main/options/cost1").hide()
		item1.desc = ""
	elif (pg.totalMoney < COST1):
		get_node("main/options/buttonItem1").disabled = true
		get_node("main/options/cost1").show()
		get_node("main/options/cost1").text = str(COST1)
	else:
		get_node("main/options/buttonItem1").disabled = false
		get_node("main/options/cost1").show()
		get_node("main/options/cost1").text = str(COST1)
		
	if (pg.damageUpgrades >= 3):
		get_node("main/options/buttonItem2").disabled = true
		get_node("main/options/cost2").hide()
		item2.desc = ""
	elif (pg.totalMoney < COST2):
		get_node("main/options/buttonItem2").disabled = true
		get_node("main/options/cost2").show()
		get_node("main/options/cost2").text = str(COST2)
	else:
		get_node("main/options/buttonItem2").disabled = false
		get_node("main/options/cost2").show()
		get_node("main/options/cost2").text = str(COST2)
		
	if (pg.luckUpgrades >= 3):
		get_node("main/options/buttonItem3").disabled = true
		get_node("main/options/cost3").hide()
		item3.desc = ""
	elif (pg.totalMoney < COST3):
		get_node("main/options/buttonItem3").disabled = true
		get_node("main/options/cost3").show()
		get_node("main/options/cost3").text = str(COST3)
	else:
		get_node("main/options/buttonItem3").disabled = false
		get_node("main/options/cost3").show()
		get_node("main/options/cost3").text = str(COST3)
		
	# indicators
	get_node("main/options/ind0").play(str(pg.healthUpgrades))
	get_node("main/options/ind1").play(str(pg.livesUpgrades))
	get_node("main/options/ind2").play(str(pg.damageUpgrades))
	get_node("main/options/ind3").play(str(pg.luckUpgrades))

func _on_buttonItem0_focus_entered():
	curItem = item0
	refreshShop()

func _on_buttonItem1_focus_entered():
	curItem = item1
	refreshShop()

func _on_buttonItem2_focus_entered():
	curItem = item2
	refreshShop()

func _on_buttonItem3_focus_entered():
	curItem = item3
	refreshShop()
	

func _on_buttonExit_focus_entered():
	curItem.desc = "Return to Wartwood?"
	get_node("NinePatchRect/description").text = "Return to Wartwood?"

func _on_buttonExit_pressed():
	if (loading):
		return
	# sets timer (timer is paused during dialogue)
	get_node("Timer").start()
	loading = true
	playDialogue("mad_exit")
	
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


func _on_buttonYes_pressed():
	buyItem(curItem)

func _on_buttonNo_pressed():
	switchToMain()

func _on_buttonItem_pressed():
	if (loading):
		return
	switchToConfirm()

# handles "back" button presses
func _process(delta):
	if (Input.is_action_just_pressed("ui_cancel") == true):
#		if (state == "main"):
#			_on_buttonExit_pressed()
		# removed to players don't spam b durring cutscene and leave
		if (state == "confirm"):
			_on_buttonNo_pressed()


func _on_Timer_timeout():
	tran.loadLevel("res://maps/wartwood.tscn")
