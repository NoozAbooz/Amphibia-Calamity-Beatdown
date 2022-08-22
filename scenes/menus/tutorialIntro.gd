extends Control

var loading = false


# Called when the node enters the scene tree for the first time.
func _ready():
	soundManager.FadeOutSong("menu")
	$"buttons".hide()
	loading = false
	
func _process(_delta):
	# skips
	if (Input.is_action_just_pressed("pause") == true) or (Input.is_action_just_pressed("ui_accept") == true):
		_on_AnimationPlayer_animation_finished("default")
	
func playSound():
	soundManager.playSound("switch")

func _on_AnimationPlayer_animation_finished(anim_name):
	$"buttons".show()
	$"label".text = "Would you like to watch the tutorial?"
	$"buttons/noButton".grab_focus()
	$"AnimationPlayer".play("idle")

func _on_yesButton_pressed():
	if not loading:
		tran.loadLevel("res://scenes/menus/tutorial.tscn")
		loading = true


func _on_noButton_pressed():
	if not loading:
		tran.loadLevel("res://scenes/menus/mapOpen.tscn")
		loading = true
