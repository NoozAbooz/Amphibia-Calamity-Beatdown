extends Control

enum {BASIC, DROP, VERIFY, OPTIONS, COMBOS}
var state = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func despawnPlayer(num):
	pg.playerAlive[num] = false
	get_parent().get_node("Player" + str(num)).queue_free()

func showDropButtons():
	for i in range(0, pg.playerAlive.size()):
		if pg.playerAlive[i]:
			get_node("dropMenu/buttonP" + str(i+1)).disabled = false
		else:
			get_node("dropMenu/buttonP" + str(i+1)).disabled = true

func _process(_delta):
	if (pg.inCutscene):
		return
	# handles pause menu appearing/dissapearing
	if (Input.is_action_just_pressed("pause") == true):
		if (get_tree().paused):
			get_tree().paused = false
			soundManager.resumeMusic()
		else:
			soundManager.playSound("pause")
			soundManager.pauseMusic()
			get_tree().paused = true
			$basicMenu.show()
			$dropMenu.hide()
			$verifyMenu.hide()
			$optionsMenu.hide()
			$basicMenu/buttonResume.grab_focus()
			state = BASIC
	# "back" button
	if (get_tree().paused) and (Input.is_action_just_pressed("ui_cancel") == true):
		match state:
			BASIC:
				get_tree().paused = false
				soundManager.resumeMusic()
			DROP:
				_on_buttonBack_pressed()
			COMBOS:
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
			$verifyMenu.hide()
			$optionsMenu.hide()
			$combosMenu.hide()
			if (pg.countPlayers() > 1):
				$basicMenu/buttonDrop.disabled = false
			else:
				$basicMenu/buttonDrop.disabled = true
		DROP:
			$labelMain.text = "DROP WHICH PLAYER"
			$basicMenu.hide()
			$dropMenu.show()
			$verifyMenu.hide()
			$optionsMenu.hide()
			$combosMenu.hide()
			showDropButtons()
		VERIFY:
			$basicMenu.hide()
			$dropMenu.hide()
			$verifyMenu.show()
			$optionsMenu.hide()
			$combosMenu.hide()
		OPTIONS:
			$basicMenu.hide()
			$dropMenu.hide()
			$verifyMenu.hide()
			$optionsMenu.show()
			$combosMenu.hide()
		COMBOS:
			$basicMenu.hide()
			$dropMenu.hide()
			$verifyMenu.hide()
			$optionsMenu.hide()
			$combosMenu.show()
			# scrolling
			if Input.is_action_pressed("ui_up"):
				$combosMenu/namesContainer.scroll_vertical -= 6
				$combosMenu/symbolsContainer.scroll_vertical -= 6
			if Input.is_action_pressed("ui_down"):
				$combosMenu/namesContainer.scroll_vertical += 6
				$combosMenu/symbolsContainer.scroll_vertical += 6
			if $combosMenu/namesContainer.scroll_vertical != $combosMenu/symbolsContainer.scroll_vertical:
				$combosMenu/namesContainer.scroll_vertical = $combosMenu/symbolsContainer.scroll_vertical
			# add/remove unlockable moves
			if pg.hasSpin:
				$combosMenu/namesContainer/names/nameSpin.show()
				$combosMenu/symbolsContainer/symbols/symSpin.show()
			else:
				$combosMenu/namesContainer/names/nameSpin.hide()
				$combosMenu/symbolsContainer/symbols/symSpin.hide()
			if pg.hasAirSpin:
				$combosMenu/namesContainer/names/nameAirSpin.show()
				$combosMenu/symbolsContainer/symbols/symAirSpin.show()
			else:
				$combosMenu/namesContainer/names/nameAirSpin.hide()
				$combosMenu/symbolsContainer/symbols/symAirSpin.hide()
			if pg.hasSlide:
				$combosMenu/namesContainer/names/nameTackle.show()
				$combosMenu/symbolsContainer/symbols/symTackle.show()
			else:
				$combosMenu/namesContainer/names/nameTackle.hide()
				$combosMenu/symbolsContainer/symbols/symTackle.hide()
			if pg.hasCounter:
				$combosMenu/namesContainer/names/nameCounter.show()
				$combosMenu/symbolsContainer/symbols/symCounter.show()
			else:
				$combosMenu/namesContainer/names/nameCounter.hide()
				$combosMenu/symbolsContainer/symbols/symCounter.hide()


func _on_buttonResume_pressed():
	get_tree().paused = false


func _on_buttonMap_pressed():
	get_tree().paused = false
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
	$combosMenu/buttonBack.grab_focus()

