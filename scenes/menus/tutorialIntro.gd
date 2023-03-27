extends Control

var loading = false

var buttonsReady = false


# Called when the node enters the scene tree for the first time.
func _ready():
	soundManager.FadeOutSong("menu")
	$"buttons".hide()
	loading = false
	if pg.seenTutorial:
		_on_noButton_pressed()
	
func _process(_delta):
	# skips
	if ((Input.is_action_just_pressed("pause") == true) or (Input.is_action_just_pressed("ui_accept") == true)) and (buttonsReady == false):
		_on_AnimationPlayer_animation_finished("default")
	
func playSound():
	soundManager.playSound("switch")

func _on_AnimationPlayer_animation_finished(anim_name):
	$"buttons".show()
	$"label".text = "KEY_TUT_ASK"
	$"buttons/noButton".grab_focus()
	$"AnimationPlayer".play("idle")
	buttonsReady = true

func _on_yesButton_pressed():
	if not loading:
		tran.loadLevel("res://scenes/menus/tutorial.tscn")
		loading = true
		pg.seenTutorial = true


func _on_noButton_pressed():
	if not loading:
		tran.loadLevel("res://scenes/menus/mapOpen.tscn")
		loading = true
		pg.seenTutorial = true
