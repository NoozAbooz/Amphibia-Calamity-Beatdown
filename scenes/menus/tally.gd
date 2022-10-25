extends Control

onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("timer")
onready var endTimer = get_node("endTimer")
onready var totalCoins = get_node("labelTotal")

var state = "wait"

var stillCounting = false

var tallyBlockScene = preload("res://scenes/menus/tallyBlock.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("intro")
	soundManager.playMusicIfDiff("stats")
	
func _process(_delta):
	totalCoins.text = "Total Coppers: " + str(pg.totalMoney)
	# counts down money and adds it to total from each tally block
	if (state == "counting"):
		stillCounting = false #flag to see if counting is finished
		for i in range(0, 4):
			if has_node("block" + str(i)):
				if get_node("block" + str(i)).coppers > 0:
					get_node("block" + str(i)).coppers -= 1
					pg.totalMoney += 1
					stillCounting = true
		# skip
		if (Input.is_action_just_pressed("ui_accept") == true):
			for i in range(0, 4):
				if has_node("block" + str(i)):
					pg.totalMoney += get_node("block" + str(i)).coppers
					get_node("block" + str(i)).coppers = 0
					stillCounting = false
	# check if done and delay for 2 seconds
	if (stillCounting == false) and (state == "counting") and (endTimer.is_stopped()):
		endTimer.start(2.0)


func loadBlocks():
	print(pg.playerLives)
	print(pg.playerCoins)
	for i in range(0, 4):
		# skips of there is no player present in that slot
		if (pg.playerActive[i] == false):
			continue
		# instances a block scene and initializes it
		var block = tallyBlockScene.instance()
		add_child_below_node(get_node("bg"), block)
		block.initialize(pg.playerCharacter[i], pg.playerLives[i], pg.playerCoins[i], pg.playerAlive[i], i)
		block.set_name("block" + str(i))
	
func returnToMap():
	pg.completedLevels[pg.levelNum] = true
	soundManager.FadeOutSong("stats")
	tran.loadLevel("res://scenes/menus/mapOpen.tscn")

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "intro"):
		loadBlocks()
		timer.start(2.0)
	elif (anim_name == "coinCounter"):
		state = "counting"

func _on_timer_timeout():
	anim.play("coinCounter")


func _on_endTimer_timeout():
	returnToMap()
