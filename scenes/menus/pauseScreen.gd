extends Control

enum {BASIC, DROP, VERIFY, OPTIONS, COMBOS, POS, CONTROLS}
enum {ANNE, SPRIG, SASHA, MARCY, MAGGIE, GRIME}
var state = 0

var chars = [ANNE, SPRIG]
var charState = ANNE
var charStateIndex = 0
var charPrev = SPRIG
var showGamepad = true
onready var namesNode = $combosMenu/namesContainer/namesAnne


# Called when the node enters the scene tree for the first time.
func _ready():
	chars = [ANNE, SPRIG]
	if pg.hasSasha or pg.allCharsMode:
		chars.append(SASHA)
	if pg.hasMarcy or pg.allCharsMode:
		chars.append(MARCY)
	if pg.hasMaggie or pg.allCharsMode:
		chars.append(MAGGIE)
	if pg.hasGrime or pg.allCharsMode:
		chars.append(GRIME)
	
	
func playMusic():
	get_node("pause_theme").play()
func stopMusic():
	get_node("pause_theme").stop()

func despawnPlayer(num):
	pg.playerAlive[num] = false
	get_parent().get_node("Player" + str(num)).queue_free()

func showDropButtons():
	for i in range(0, pg.playerAlive.size()):
		if pg.playerAlive[i]:
			get_node("dropMenu/buttonP" + str(i+1)).disabled = false
		else:
			get_node("dropMenu/buttonP" + str(i+1)).disabled = true

func showPosButtons():
	for i in range(0, pg.playerAlive.size()):
		if pg.playerAlive[i]:
			get_node("posMenu/buttonP" + str(i+1) + "Pos").disabled = false
		else:
			get_node("posMenu/buttonP" + str(i+1) + "Pos").disabled = true



func _process(_delta):
	if (pg.inCutscene):
		return
	# handles pause menu appearing/dissapearing
	if (Input.is_action_just_pressed("pause") == true):
		if (get_tree().paused):
			get_tree().paused = false
			stopMusic()
			soundManager.resumeMusic()
		else:
			soundManager.playSound("pause")
			playMusic()
			soundManager.pauseMusic()
			get_tree().paused = true
			$basicMenu.show()
			$dropMenu.hide()
			$verifyMenu.hide()
			$optionsMenu.hide()
			$basicMenu/buttonResume.grab_focus()
			raise()
			state = BASIC
	# "back" button
	if (get_tree().paused) and (Input.is_action_just_pressed("ui_cancel") == true):
		match state:
			BASIC:
				get_tree().paused = false
				stopMusic()
				soundManager.resumeMusic()
			DROP:
				_on_buttonBack_pressed()
			POS:
				_on_buttonBack_pressed()
			COMBOS:
				_on_buttonBack_pressed()
			VERIFY:
				_on_buttonBack_pressed()
			CONTROLS:
				_on_buttonBack_pressed()
			OPTIONS:
				_on_buttonBack_pressed()
				
	if (get_tree().paused):
		self.show()
	else:
		self.hide()
	# displays different menus
	match state:
		BASIC:
			$labelMain.text = "PAUSED"
			$basicMenu.show()
			$dropMenu.hide()
			$posMenu.hide()
			$verifyMenu.hide()
			$optionsMenu.hide()
			$combosMenu.hide()
			$controlsMenu.hide()
			if (pg.countPlayers() > 1):
				$basicMenu/buttonDrop.disabled = false
			else:
				$basicMenu/buttonDrop.disabled = true
		DROP:
			$labelMain.text = "DROP WHICH PLAYER?"
			$basicMenu.hide()
			$dropMenu.show()
			$posMenu.hide()
			$verifyMenu.hide()
			$optionsMenu.hide()
			$combosMenu.hide()
			$controlsMenu.hide()
			showDropButtons()
		POS:
			$labelMain.text = "WARP WHICH PLAYER?"
			$basicMenu.hide()
			$dropMenu.hide()
			$posMenu.show()
			$verifyMenu.hide()
			$optionsMenu.hide()
			$combosMenu.hide()
			$controlsMenu.hide()
			showPosButtons()
		VERIFY:
			$basicMenu.hide()
			$dropMenu.hide()
			$posMenu.hide()
			$verifyMenu.show()
			$optionsMenu.hide()
			$combosMenu.hide()
			$controlsMenu.hide()
		OPTIONS:
			$basicMenu.hide()
			$dropMenu.hide()
			$posMenu.hide()
			$verifyMenu.hide()
			$optionsMenu.show()
			$combosMenu.hide()
			$controlsMenu.hide()
		CONTROLS:
			$labelMain.text = ""
			$basicMenu.hide()
			$dropMenu.hide()
			$posMenu.hide()
			$verifyMenu.hide()
			$optionsMenu.hide()
			$combosMenu.hide()
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
		COMBOS:
			$labelMain.text = ""
			$basicMenu.hide()
			$dropMenu.hide()
			$posMenu.hide()
			$verifyMenu.hide()
			$optionsMenu.hide()
			$combosMenu.show()
			$controlsMenu.hide()
			# sets names and face depending on character if selection changed
			if (charState != charPrev):
				$combosMenu/namesContainer/namesAnne.hide()
				$combosMenu/namesContainer/namesSprig.hide()
				$combosMenu/namesContainer/namesSasha.hide()
				$combosMenu/namesContainer/namesMarcy.hide()
				$combosMenu/namesContainer/namesMaggie.hide()
				$combosMenu/namesContainer/namesGrime.hide()
				match charState:
					ANNE:
						namesNode = $combosMenu/namesContainer/namesAnne
					SPRIG:
						namesNode = $combosMenu/namesContainer/namesSprig
					MARCY:
						namesNode = $combosMenu/namesContainer/namesMarcy
					SASHA:
						namesNode = $combosMenu/namesContainer/namesSasha
					MAGGIE:
						namesNode = $combosMenu/namesContainer/namesMaggie
					GRIME:
						namesNode = $combosMenu/namesContainer/namesGrime
					_:
						namesNode = $combosMenu/namesContainer/namesAnne
				namesNode.show()
				charPrev = charState
				$combosMenu/face.play(str(charState))
			# scrolling
			if Input.is_action_pressed("ui_up"):
				$combosMenu/symbolsContainer.scroll_vertical -= 6
			if Input.is_action_pressed("ui_down"):
				$combosMenu/symbolsContainer.scroll_vertical += 6
			if namesNode.scroll_vertical != $combosMenu/symbolsContainer.scroll_vertical:
				namesNode.scroll_vertical = $combosMenu/symbolsContainer.scroll_vertical
			# add/remove unlockable moves
			if pg.hasSpin:
				namesNode.get_node("names/nameSpin").show()
				$combosMenu/symbolsContainer/symbols/symSpin.show()
			else:
				namesNode.get_node("names/nameSpin").hide()
				$combosMenu/symbolsContainer/symbols/symSpin.hide()
			if pg.hasAirSpin:
				namesNode.get_node("names/nameAirSpin").show()
				$combosMenu/symbolsContainer/symbols/symAirSpin.show()
			else:
				namesNode.get_node("names/nameAirSpin").hide()
				$combosMenu/symbolsContainer/symbols/symAirSpin.hide()
			if pg.hasSlide:
				namesNode.get_node("names/nameTackle").show()
				$combosMenu/symbolsContainer/symbols/symTackle.show()
			else:
				namesNode.get_node("names/nameTackle").hide()
				$combosMenu/symbolsContainer/symbols/symTackle.hide()
			if pg.hasCounter:
				namesNode.get_node("names/nameCounter").show()
				$combosMenu/symbolsContainer/symbols/symCounter.show()
			else:
				namesNode.get_node("names/nameCounter").hide()
				$combosMenu/symbolsContainer/symbols/symCounter.hide()
			# character selection inputs
			if (get_tree().paused) and (Input.is_action_just_pressed("ui_right") == true):
				charStateIndex += 1
				if (charStateIndex >= len(chars)):
					charStateIndex = 0
				charState = chars[charStateIndex]
			if (get_tree().paused) and (Input.is_action_just_pressed("ui_left") == true):
				charStateIndex -= 1
				if (charStateIndex < 0 ):
					charStateIndex = (len(chars) - 1)
				charState = chars[charStateIndex]


func _on_buttonResume_pressed():
	get_tree().paused = false
	stopMusic()
	soundManager.resumeMusic()

func _on_buttonMapAttempt_pressed():
	if pg.levelNum == 0:
		_on_buttonMap_pressed()
	else:
		state = VERIFY
		$verifyMenu/buttonBack.grab_focus()

func _on_buttonMap_pressed():
	get_tree().paused = false
	stopMusic()
	pg.backToMapLose()


func _on_buttonDrop_pressed():
	state = DROP
	$dropMenu/buttonBack.grab_focus()


func _on_buttonBack_pressed():
	state = BASIC
	$basicMenu/buttonResume.grab_focus()


func _on_buttonP1_pressed():
	despawnPlayer(0)
	state = BASIC
	$basicMenu/buttonResume.grab_focus()

func _on_buttonP2_pressed():
	despawnPlayer(1)
	state = BASIC
	$basicMenu/buttonResume.grab_focus()

func _on_buttonP3_pressed():
	despawnPlayer(2)
	state = BASIC
	$basicMenu/buttonResume.grab_focus()

func _on_buttonP4_pressed():
	despawnPlayer(3)
	state = BASIC
	$basicMenu/buttonResume.grab_focus()

func _on_buttonCombo_pressed():
	state = COMBOS
	charState = ANNE
	charPrev = SPRIG
	$combosMenu/face.play(str(0))
	$combosMenu/buttonBack.grab_focus()
	
func _on_buttonControls_pressed():
	state = CONTROLS
	$controlsMenu/buttonBack.grab_focus()

func _on_buttonPos_pressed():
	state = POS
	$posMenu/buttonBack.grab_focus()


func _on_buttonP1Pos_pressed():
	pg.playerFixPos[0] = true
	get_tree().paused = false
	stopMusic()
	soundManager.resumeMusic()


func _on_buttonP2Pos_pressed():
	pg.playerFixPos[1] = true
	get_tree().paused = false
	stopMusic()
	soundManager.resumeMusic()


func _on_buttonP3Pos_pressed():
	pg.playerFixPos[2] = true
	get_tree().paused = false
	stopMusic()
	soundManager.resumeMusic()


func _on_buttonP4Pos_pressed():
	pg.playerFixPos[3] = true
	get_tree().paused = false
	stopMusic()
	soundManager.resumeMusic()


func _on_buttonAllPos_pressed():
	pg.playerFixPos[0] = true
	pg.playerFixPos[1] = true
	pg.playerFixPos[2] = true
	pg.playerFixPos[3] = true
	get_tree().paused = false
	stopMusic()
	soundManager.resumeMusic()



