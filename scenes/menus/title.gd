extends Control

var loading = false

enum {MAIN, CONTROLS, CREDITS}
var showGamepad = false

var state = MAIN

# Called when the node enters the scene tree for the first time.
func _ready():
	soundManager.playMusicIfDiff("menu")
	$mainMenu/startButton.grab_focus()
	_on_lockButton_toggled(false)
	$lockButton.pressed = false
	_on_hitboxButton_toggled(false)
	$hitboxButton.pressed = false
	loading = false


func _process(delta):
	if (Input.is_action_just_pressed("ui_cancel") == true) and (state != MAIN) and (!loading):
		state = MAIN
		$mainMenu/startButton.grab_focus()
	match state:
		MAIN:
			$mainMenu.show()
			$creditsMenu.hide()
			$controlsMenu.hide()
		CREDITS:
			$mainMenu.hide()
			$creditsMenu.show()
			$controlsMenu.hide()
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
	if not loading:
		tran.loadLevel("res://scenes/menus/tutorialIntro.tscn")
		loading = true
	


func _on_lockButton_toggled(button_pressed):
	if (button_pressed):
		$lockButton/Label.text = "Disable All Upgrades"
		pg.healthUpgrades = 3 # 20 per upgrade, max 3
		pg.livesUpgrades  = 3 # 1 life per upgrade, max 3
		pg.damageUpgrades = 3 # 20% per upgrade, max 3
		pg.luckUpgrades   = 3 # increase coin drop by 1 and drop chances by 5%
		pg.hasSpin    = true
		pg.hasSlide   = true
		pg.hasAirSpin = true
		pg.hasDJ      = true
		pg.hasCounter = true
	else:
		$lockButton/Label.text = "Enable All Upgrades"
		pg.healthUpgrades = 0 # 20 per upgrade, max 3
		pg.livesUpgrades  = 0 # 1 life per upgrade, max 3
		pg.damageUpgrades = 0 # 20% per upgrade, max 3
		pg.luckUpgrades   = 0 # increase coin drop by 1 and drop chances by 5%
		pg.hasSpin    = false
		pg.hasSlide   = false
		pg.hasAirSpin = false
		pg.hasDJ      = false
		pg.hasCounter = false
		
	#print("Unlocks changed!")

func _on_hitboxButton_toggled(button_pressed):
	if (button_pressed):
		$hitboxButton/Label.text = "Disable Hitboxes"
		get_tree().set_debug_collisions_hint(true)
		
	else:
		$hitboxButton/Label.text = "Enable Hitboxes"
		get_tree().set_debug_collisions_hint(false)
		
	#print("hitboxes changed!")


func _on_controlsButton_pressed():
	state = CONTROLS
	$controlsMenu/buttonBack.grab_focus()

func _on_creditsButton_pressed():
	state = CREDITS
	$creditsMenu/buttonBack.grab_focus()

func _on_exitButton_pressed():
	get_tree().quit()

func _on_buttonBack_pressed():
	state = MAIN
	$mainMenu/startButton.grab_focus()
