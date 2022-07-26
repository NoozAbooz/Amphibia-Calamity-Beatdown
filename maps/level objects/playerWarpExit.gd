extends Spatial

# For warps to work, there must be a warp scene as a sibling of the exit, and the
# warp node must be named "warpX" where is is the number assigned to this exit.
# 

var warpEnt = null
export var warpNum = 0
export var isVisible = false
onready var anim = get_node("AnimationPlayer")
var players = [null, null, null, null]
var cam = null
var offset = Vector3.ZERO
var destination = Vector3.ZERO

func _ready():
	warpEnt = get_parent().get_node("warp" + str(warpNum))
	# connects to corresponding warp entrance and listens for signal
	warpEnt.connect("area_entered", self, "_on_area_entered")
	# hides markers
	if (isVisible == false):
		get_node("markers").hide()
		warpEnt.get_node("MeshInstance").queue_free()
	# hide fadeing
	anim.play("idle")
	# sets destination
	destination = self.global_transform.origin
	

func _on_area_entered(_area):
	getPlayers()
	pausePlayers()
	anim.play("fadeToBlack")
	
func getPlayers():
	for i in range(0, 4):
		players[i] = get_node_or_null("/root/" + pg.levelName + "/Player" + str(i))
	#cam = get_parent().get_parent().get_node("camera_pivot/Camera")
	cam = get_node("/root/" + pg.levelName + "/camera_pivot/Camera")
	
	
func pausePlayers():
	pg.dontMove = true

func movePlayers():
	for i in range(0, 4):
		var player = players[i]
		if (player == null):
			continue
		# resets player state
		player.state = player.IDLE
		player.nextState = player.IDLE
		# Determines player position
		match i:
			0:
				offset = Vector3(-3, 0, -3)
			1:
				offset = Vector3(3, 0, -3)
			2:
				offset = Vector3(-3, 0, 3)
			3:
				offset = Vector3(3, 0, 3)
			_:
				offset = Vector3.ZERO
		# moves player
		player.translation = destination + offset
		print(str(destination + offset))
	#moves camera
	cam.initialize(destination)
	
func unpausePlayers():
	pg.dontMove = false


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fadeToBlack":
			anim.play("wait")
			movePlayers()
		"wait":
			anim.play("fadeToClear")
		"fadeToClear":
			anim.play("idle")
			unpausePlayers()
			

