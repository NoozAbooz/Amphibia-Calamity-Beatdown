extends Control

var loading = false
var waitingOnIntro = false

enum {MAIN, CONTROLS, CREDITS}
var showGamepad = false

onready var introAnim = get_node("introAnim")

var state = MAIN

# Called when the node enters the scene tree for the first time.
func _ready():
	loading = true
	waitingOnIntro = true
	soundManager.playMusicIfDiff("menu")
	discordRPC.updateLevel("Main Menu")
	#$mainMenu/startButton.grab_focus()
	#_on_lockButton_toggled(false)
	$lockButton.pressed = false
	#_on_hitboxButton_toggled(false)
	$hitboxButton.pressed = false
	loading = false


func _process(delta):
	# intro skip
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")) and waitingOnIntro:
		_on_introAnim_animation_finished("intro")
		if Input.is_action_just_pressed("ui_down"):
			$mainMenu/controlsButton.grab_focus()
	# backing out of menus
	if (Input.is_action_just_pressed("ui_cancel") == true) and (state != MAIN) and (!loading):
		state = MAIN
		$mainMenu/startButton.grab_focus()
	# FSM
	if loading:
		state = MAIN
	match state:
		MAIN:
			$mainMenu.show()
			$creditsMenu.hide()
			$controlsMenu.hide()
		CREDITS:
			$mainMenu.hide()
			$creditsMenu.show()
			$controlsMenu.hide()
			# scrolling
			if Input.is_action_pressed("ui_up"):
				$creditsMenu/namesCredits.scroll_vertical -= 6
			if Input.is_action_pressed("ui_down"):
				$creditsMenu/namesCredits.scroll_vertical += 6
		CONTROLS:
			$mainMenu.hide()
			$creditsMenu.hide()
			$controlsMenu.show()
			if (showGamepad):
				$controlsMenu/type.text = "Gamepad"
				$controlsMenu/board.hide()
				$controlsMenu/pad.show()
			else:
				$controlsMenu/type.text = "Keyboard"
				$controlsMenu/board.show()
				$controlsMenu/pad.hide()
			if (Input.is_action_just_pressed("ui_left") == true) or (Input.is_action_just_pressed("ui_right") == true):
				showGamepad = !showGamepad

func _on_startButton_pressed():
	if waitingOnIntro:
		return
	if not loading:
		loading = true
		if !pg.seenTutorial:
			tran.loadLevel("res://scenes/menus/tutorialIntro.tscn")
		else:
			tran.loadLevel("res://scenes/menus/mapOpen.tscn")
		
	


func _on_lockButton_toggled(button_pressed):
	pass
#	if (button_pressed):
#		$lockButton/Label.text = "Disable All Upgrades"
#		pg.healthUpgrades = 3 # 20 per upgrade, max 3
#		pg.livesUpgrades  = 3 # 1 life per upgrade, max 3
#		pg.damageUpgrades = 3 # 20% per upgrade, max 3
#		pg.luckUpgrades   = 3 # increase coin drop by 1 and drop chances by 5%
#		pg.hasSpin    = true
#		pg.hasSlide   = true
#		pg.hasAirSpin = true
#		pg.hasDJ      = true
#		pg.hasCounter = true
#	else:
#		$lockButton/Label.text = "Enable All Upgrades"
#		pg.healthUpgrades = 0 # 20 per upgrade, max 3
#		pg.livesUpgrades  = 0 # 1 life per upgrade, max 3
#		pg.damageUpgrades = 0 # 20% per upgrade, max 3
#		pg.luckUpgrades   = 0 # increase coin drop by 1 and drop chances by 5%
#		pg.hasSpin    = false
#		pg.hasSlide   = false
#		pg.hasAirSpin = false
#		pg.hasDJ      = false
#		pg.hasCounter = false
		
	#print("Unlocks changed!")

func _on_hitboxButton_toggled(button_pressed):
	if waitingOnIntro:
		return
	if (button_pressed):
		$hitboxButton/Label.text = "Disable Hitboxes"
		get_tree().set_debug_collisions_hint(true)
		
	else:
		$hitboxButton/Label.text = "Enable Hitboxes"
		get_tree().set_debug_collisions_hint(false)
		
	#print("hitboxes changed!")


func _on_controlsButton_pressed():
	if waitingOnIntro:
		return
	state = CONTROLS
	$controlsMenu/buttonBack.grab_focus()

func _on_creditsButton_pressed():
	if waitingOnIntro:
		return
	state = CREDITS
	$creditsMenu/buttonBack.grab_focus()

func _on_exitButton_pressed():
	if waitingOnIntro:
		return
	get_tree().quit()

func _on_buttonBack_pressed():
	if waitingOnIntro:
		return
	state = MAIN
	$mainMenu/startButton.grab_focus()

func _on_introAnim_animation_finished(anim_name):
	$mainMenu/startButton.grab_focus()
	#_on_lockButton_toggled(false)
	$lockButton.pressed = false
	#_on_hitboxButton_toggled(false)
	$hitboxButton.pressed = false
	loading = false
	waitingOnIntro = false
	if (anim_name == "intro"):
		introAnim.play("idle")
