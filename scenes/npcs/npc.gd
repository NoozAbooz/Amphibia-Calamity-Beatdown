extends Spatial

var dialogueScene = preload("res://scenes/menus/dialogueBox.tscn")

export var hasDialogue = true
export var dialogueName = "test"

export var startLeft = false

# decides if the npc is still around based on player progression
export var spawnAfterLevel = 0
export var removeAfterLevel = 99

var nearbyPlayers = []


func _ready():
	var levelsCompleted = pg.countCompletedLevels()
	# removes npc if player hasn't progressed enough
	if (levelsCompleted < spawnAfterLevel):
		queue_free()
		return
	# removes npc if player has progressed too far
	if (levelsCompleted >= removeAfterLevel):
		queue_free()
		return
	# flips if necessary
	if startLeft:
		get_node("character").flip_h = true
	else:
		get_node("character").flip_h = false
	# removes dialogue box if necessary
	if !hasDialogue:
		get_node("talkZone").queue_free()

func _process(_delta):
	# speach bubble
	if (len(nearbyPlayers) > 0):
		get_node("bubble").show()
	else:
		get_node("bubble").hide()
	# checks for input and creates dialogue node
	for player in nearbyPlayers:
		if (Input.is_action_just_pressed("light_attack_" + str(pg.playerInput[player.playerNum]))) and (player.isInState([player.IDLE, player.WALK])) and (pg.inCutscene == false):
			# turns toward player
			if (player.translation.x > self.translation.x):
				get_node("character").flip_h = false
			else:
				get_node("character").flip_h = true
			playDialogue(pg.playerCharacter[player.playerNum])
	
func playDialogue(playerName):
	var newDialogue = dialogueScene.instance()
	get_node("/root/" + pg.levelName).add_child(newDialogue)
	newDialogue.initialize(dialogueName, playerName)

func _on_talkZone_area_entered(area):
	# sets player flag so they cant attack
	var player = area.get_parent().get_parent()
	player.nearNPCs += 1
	var playerNum = player.playerNum
	# updates in range player list
	nearbyPlayers.append(player)


func _on_talkZone_area_exited(area):
	# sets player flag so they cant attack
	var player = area.get_parent().get_parent()
	player.nearNPCs -= 1
	var playerNum = player.playerNum
	# updates in range player list
	nearbyPlayers.erase(player)

