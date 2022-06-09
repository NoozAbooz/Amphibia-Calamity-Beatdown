extends Control


var posDes = Vector2(360, 640)
var zoomDes = Vector2(0.5, 0.5)
var markerOffset = -21
var buttonScale = 0.5
var currentButton = null
onready var cam = get_node("cam")
onready var marker = get_node("marker")
var loading = false


# Called when the node enters the scene tree for the first time.
func _ready():
	posDes = get_node("lvl0").rect_position
	soundManager.playMusicIfDiff("map")
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
	# returns to map if back is pressed by k0 or 0 and they are not picking a character
	if (Input.is_action_just_pressed("k0_leave") == true) and (loading == false):
		loading = true
		tran.loadLevel("res://scenes/menus/title.tscn")
	for i in range(0, 3):
		if (Input.is_action_just_pressed(str(i) + "_leave") == true) and (loading == false):
			loading = true
			tran.loadLevel("res://scenes/menus/title.tscn")

#func _on_startButton_pressed():
#	tran.loadLevel("res://scenes/menus/charSelect.tscn")
	
func _on_lvl_pressed():
	if (loading == false):
		loading = true
		tran.loadLevel("res://scenes/menus/charSelect.tscn")
	else:
		pass
	
func fucusOnButton(buttonNode):
	posDes = buttonNode.rect_position + buttonScale*Vector2(buttonNode.rect_size / 2)
	
func _on_lvl0_focus_entered():
	fucusOnButton(get_node("lvl0"))
	pg.levelName = "wartwood"
	pg.levelMusic = "ripple"
	
func _on_lvl1_focus_entered():
	fucusOnButton(get_node("lvl1"))
	pg.levelName = "playground"
	pg.levelMusic = "ripple"

func _on_lvl2_focus_entered():
	fucusOnButton(get_node("lvl2"))
	pg.levelName = "bestFronds"
	pg.levelMusic = "ripple"
