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
var COST0 = 300
var COST1 = 250
var COST2 = 250
var COST3 = 200
var COST4 = 200

var curItem = item.new()
var item0 = null
var item1 = null
var item2 = null
var item3 = null
var item4 = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# unlimied money code
	if (pg.unlimitedMoney):
		COST0 = 0
		COST1 = 0
		COST2 = 0
		COST3 = 0
		COST4 = 0
		
	# available items
	item0 = item.new()
	item0.num = 0
	item0.title = "Double Jump"
	item0.cost = COST0
	item0.desc = "Jump again while in mid-air to extend combos and get to hard to reach places."
	item0.dialogue = "fel_dj"
	
	item1 = item.new()
	item1.num = 1
	item1.title = "Spin Attack"
	item1.cost = COST1
	item1.desc = "Perform a multi-hit area attack after a 3-hit combo to knock away surrounding enemies."
	item1.dialogue = "fel_spin"
	
	item2 = item.new()
	item2.num = 2
	item2.title = "Shell Breaker"
	item2.cost = COST2
	item2.desc = "Perform a devastating slam attack after an arial 3-hit combo that also damages enemies below you."
	item2.dialogue = "fel_breaker"
	
	item3 = item.new()
	item3.num = 3
	item3.title = "Counter Attack"
	item3.cost = COST3
	item3.desc = "Block just before taking a hit to negate all damage and send nearby foes skyward. Follow up with air or ground attacks for even more damage!"
	item3.dialogue = "fel_counter"
	
	item4 = item.new()
	item4.num = 4
	item4.title = "Tackle"
	item4.cost = COST4
	item4.desc = "Knock enemies back and deal more damage with this heavier version of the slide attack."
	item4.dialogue = "fel_tackle"
	
	refreshShop()
	
	# plays music for shop
	soundManager.playMusic("map")
	
	# hides confirmation menu for now
	get_node("confirm").hide()
	
	# intro dialogue
	playDialogue("fel_enter")
	
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
			pg.hasDJ = true
		1:
			pg.hasSpin = true
		2:
			pg.hasAirSpin = true
		3:
			pg.hasCounter = true
		4:
			pg.hasSlide = true
		_:
			pass
	playDialogue(item.dialogue)
	switchToMain()
	
func refreshShop():
	# changes description at bottom of screen
	get_node("NinePatchRect/description").text = curItem.desc
	
	# updates total
	get_node("pockets/totalMoney").text = str(pg.totalMoney)
	
	# shows/hides buttons and costs depending on global flags
	if (pg.hasDJ):
		get_node("main/options/buttonItem0").disabled = true
		get_node("main/options/buttonItem0").text = "PURCHASED"
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
		
	if (pg.hasSpin):
		get_node("main/options/buttonItem1").disabled = true
		get_node("main/options/buttonItem1").text = "PURCHASED"
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
		
	if (pg.hasAirSpin):
		get_node("main/options/buttonItem2").disabled = true
		get_node("main/options/buttonItem2").text = "PURCHASED"
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
		
	if (pg.hasCounter):
		get_node("main/options/buttonItem3").disabled = true
		get_node("main/options/buttonItem3").text = "PURCHASED"
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
	
	if (pg.hasSlide):
		get_node("main/options/buttonItem4").disabled = true
		get_node("main/options/buttonItem4").text = "PURCHASED"
		get_node("main/options/cost4").hide()
		item4.desc = ""
	elif (pg.totalMoney < COST4):
		get_node("main/options/buttonItem4").disabled = true
		get_node("main/options/cost4").show()
		get_node("main/options/cost4").text = str(COST4)
	else:
		get_node("main/options/buttonItem4").disabled = false
		get_node("main/options/cost4").show()
		get_node("main/options/cost4").text = str(COST4)
		

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
	
func _on_buttonItem4_focus_entered():
	curItem = item4
	refreshShop()

func _on_buttonExit_focus_entered():
	get_node("NinePatchRect/description").text = "Return to Wartwood?"

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
