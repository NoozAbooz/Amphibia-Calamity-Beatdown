extends Spatial

var dialogueScene = preload("res://scenes/menus/dialogueBox.tscn")

export var dialogueName = "test"

func _ready():
	pass 

func _on_cameraTrigger_area_entered(area):
	# finds first alive player
	var playerName = "Anne"
	for i in range(0, 4):
		if (pg.playerAlive[i]):
			playerName = pg.playerCharacter[i]
			break
	var newDialogue = dialogueScene.instance()
	get_node("/root/" + pg.levelName).add_child(newDialogue)
	newDialogue.initialize(dialogueName, playerName)
	self.queue_free()
