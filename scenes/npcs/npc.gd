extends Spatial

var dialogueScene = preload("res://scenes/menus/dialogueBox.tscn")

export var defaultDialogeFile = "test"

export var changeDialogueWithProgression = false

export var levelSpecificDialogeFiles = ["", "", "", "", "", "", "", "", "", ""]

var dialogue = "test"

var nearbyPlayers = []


func _ready():
	# decides which dialogue file to use
	if (changeDialogueWithProgression):
		var numCompletedLevels = pg.countCompletedLevels()
		dialogue = levelSpecificDialogeFiles[numCompletedLevels]
	else:
		dialogue = defaultDialogeFile
	
func _process(_delta):
	# speach bubble
	if (len(nearbyPlayers) > 0):
		get_node("bubble").show()
	else:
		get_node("bubble").hide()
	# checks for input and creates dialogue node
	for player in nearbyPlayers:
		if (Input.is_action_pressed("light_attack_" + str(pg.playerInput[player.playerNum]) )):
			# turns toward player
			if (player.translation.x > self.translation.x):
				get_node("character").flip_h = false
			else:
				get_node("character").flip_h = true
			playDialogue()
	
func playDialogue():
	var newDialogue = dialogueScene.instance()
	get_node("/root/" + pg.levelName).add_child(newDialogue)
	newDialogue.initialize(defaultDialogeFile)

func _on_talkZone_area_entered(area):
	# sets player flag so they cant attack
	var player = area.get_parent().get_parent()
	player.nearNPC = true
	var playerNum = player.playerNum
	# updates in range player list
	nearbyPlayers.append(player)


func _on_talkZone_area_exited(area):
	# sets player flag so they cant attack
	var player = area.get_parent().get_parent()
	player.nearNPC = false
	var playerNum = player.playerNum
	# updates in range player list
	nearbyPlayers.erase(player)

