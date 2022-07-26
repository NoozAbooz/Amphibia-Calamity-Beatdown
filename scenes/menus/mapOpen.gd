extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("startButton").grab_focus()
	get_node("bg").play()
	soundManager.playMusicIfDiff("menu")

func _on_startButton_pressed():
	get_tree().change_scene("res://scenes/menus/mapScreen.tscn")

func _on_bg_animation_finished():
	#get_tree().change_scene("res://scenes/menus/mapScreen.tscn")
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://scenes/menus/mapScreen.tscn")
