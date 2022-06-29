extends Spatial

var dialogueScene = preload("res://scenes/menus/dialogueBox.tscn")

export var dialogueName = "test"

func _ready():
	pass 


func _on_cameraTrigger_area_entered(area):
	var newDialogue = dialogueScene.instance()
	get_tree().add_child(newDialogue)
	newDialogue.initialize(dialogueName)
	self.queue_free()
