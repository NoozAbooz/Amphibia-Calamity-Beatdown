extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("startButton").grab_focus()
	soundManager.playMusicIfDiff("menu")

func _on_startButton_pressed():
	get_tree().change_scene("res://scenes/menus/mapScreen.tscn")
	self.queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://scenes/menus/mapScreen.tscn")
	self.queue_free()


