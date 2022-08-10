extends Spatial

var dialogueScene = preload("res://scenes/menus/dialogueBox.tscn")

export var dialogueName = "test"
export var oneOff = false

func _ready():
	if (pg.firstTimeInWartwood == false):
		queue_free()

func _on_cameraTrigger_area_entered(area):
	var newDialogue = dialogueScene.instance()
	get_node("/root/wartwood").add_child(newDialogue)
	newDialogue.initialize("wartwood_intro", "Anne")
	pg.firstTimeInWartwood = false
	self.queue_free()
