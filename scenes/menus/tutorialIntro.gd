extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	soundManager.FadeOutSong("menu")
	$"buttons".hide()
	
func playSound():
	soundManager.playSound("switch")

func _on_AnimationPlayer_animation_finished(anim_name):
	$"buttons".show()
	$"label".text = "Would you like to watch the tutorial?"
	$"buttons/noButton".grab_focus()

func _on_yesButton_pressed():
	tran.loadLevel("res://scenes/menus/tutorial.tscn")


func _on_noButton_pressed():
	tran.loadLevel("res://scenes/menus/mapOpen.tscn")
