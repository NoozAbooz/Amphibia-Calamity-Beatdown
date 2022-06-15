extends Control


var posDes = Vector2(360, 640)
var zoomDes = Vector2(0.5, 0.5)
var phonePosDes = Vector2(0, 500)
var markerOffset = -21
var buttonScale = 0.5
var currentButton = null
onready var cam = get_node("cam")
onready var marker = get_node("marker")
onready var phone = get_node("cam/phone")
var loading = false
var infoScreen = false
var lastLevel = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	posDes = get_node("lvl0").rect_position
	soundManager.playMusicIfDiff("menu")
	get_node("lvl0").grab_focus()
	cam.zoom = Vector2(1,1)
	loading = false

func _process(delta):
	#positions camera and marker
	marker.position = Vector2(posDes.x, posDes.y + markerOffset)
	cam.position.x += 0.085*(posDes.x - cam.position.x)
	cam.position.y += 0.085*(posDes.y - cam.position.y)
	cam.zoom.x += 0.09*(zoomDes.x - cam.zoom.x)
	cam.zoom.y += 0.09*(zoomDes.y - cam.zoom.y)
	# "back" Inputs
	if !infoScreen:
		if (Input.is_action_just_pressed("k0_leave") == true) and (loading == false):
			loading = true
			tran.loadLevel("res://scenes/menus/title.tscn")
		for i in range(0, 3):
			if (Input.is_action_just_pressed(str(i) + "_leave") == true) and (loading == false):
				loading = true
				tran.loadLevel("res://scenes/menus/title.tscn")
	else: # if infoscreen is active
		if (Input.is_action_just_pressed("k0_leave") == true):
			infoScreen = false
			get_node("lvl" + str(pg.levelNum)).grab_focus()
			get_node("cam/phone/playButton").hide()
		for i in range(0, 3):
			if (Input.is_action_just_pressed(str(i) + "_leave") == true) and (loading == false):
				infoScreen = false
				get_node("lvl" + str(pg.levelNum)).grab_focus()
				get_node("cam/phone/playButton").hide()
	# Phone positioning
	if infoScreen:
		phonePosDes = Vector2(0, 0)
	else:
		phonePosDes = Vector2(0, 500)
	phone.position.y += 0.1*(phonePosDes.y - phone.position.y)
	# check box for level completion
	if (pg.levelNum == 0):
		$cam/phone/checkBox.play("none")
	elif pg.completedLevels[pg.levelNum]:
		$cam/phone/checkBox.play("check")
	else:
		$cam/phone/checkBox.play("uncheck")
	



func _on_lvl_pressed():
	infoScreen = true
	get_node("cam/phone/playButton").show()
	$cam/phone/playButton.grab_focus()
	
func fucusOnButton(buttonNode):
	posDes = buttonNode.rect_position + buttonScale*Vector2(buttonNode.rect_size / 2)
	
func _on_playButton_pressed():
	if (loading == false):
		loading = true
		tran.loadLevel("res://scenes/menus/charSelect.tscn")
	else:
		pass
	
func _on_lvl0_focus_entered():
	fucusOnButton(get_node("lvl0"))
	pg.levelName = "wartwood"
	pg.levelMusic = "ripple"
	pg.levelNum = 0
	$cam/phone/levelName.text = "Wartwood"
	$cam/phone/levelPic.play("wartwood")
	
func _on_lvl1_focus_entered():
	fucusOnButton(get_node("lvl1"))
	pg.levelName = "playground"
	pg.levelMusic = "marcy"
	pg.levelNum = 1
	$cam/phone/levelName.text = "Beta Playground"
	$cam/phone/levelPic.play("playground")

func _on_lvl2_focus_entered():
	fucusOnButton(get_node("lvl2"))
	pg.levelName = "bestFronds"
	pg.levelMusic = "swamp"
	pg.levelNum = 2
	$cam/phone/levelName.text = "Trip to the Lake"
	$cam/phone/levelPic.play("bestFronds")



