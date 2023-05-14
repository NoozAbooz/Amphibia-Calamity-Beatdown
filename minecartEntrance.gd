extends Spatial

var active = false
var hasFoundMainCharacter = false
var cam = null
var mainCharNumber = 0
var exiting = false

export (int, "newt", "earth") var cartType

onready var sprite = $zeroPoint/AnimatedSprite3D
onready var anim = $AnimationPlayer

# NOTE: MINECART ENTRANCE/EXIT/WARP MUST BE AN IMEDIATE CHILD OF THE MAP NODE

# Called when the node enters the scene tree for the first time.
func _ready():
	match cartType:
		0:
			$zeroPoint/shop/cart_earth.queue_free()
		1:
			$zeroPoint/shop/cart_newt.queue_free()
	sprite.play("empty")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# moves only the main character with the cart to prevent double loading bug
	if active and exiting:
		for i in range(0, 4):
			if has_node("../Player" + str(i)):
				get_node("../Player" + str(i)).translation = translation + $zeroPoint.translation + Vector3(0, 1, 0)
	elif active:
			get_node("../Player" + str(mainCharNumber)).translation = translation + $zeroPoint.translation + Vector3(0, 1, 0)


func _on_hurtbox_area_entered(area):
	if pg.dontMove:
		return
		# prevents getting in minecart while a warp or cutscene is already active
	if active:
		return
	pg.dropPlayerEnabled = false
	active = true
	# camera
	cam = get_node("/root/" + pg.levelName + "/camera_pivot/Camera")
	#cam.inAmbush = true
	cam.cutsceneTarget = translation + $zeroPoint.translation
	#cam.ambushTarget   = camLocation
	cam.ambushSpawnPoint = translation + Vector3(0, 5, 0)
	cam.startCutscene()
	# makes players invisible
	for i in range(0, 4):
			if has_node("../Player" + str(i)):
				get_node("../Player" + str(i)).visible = false
			# picks player sprite, puts fake player in car
			if not hasFoundMainCharacter:
				hasFoundMainCharacter = true
				mainCharNumber = i
				sprite.play(get_node("../Player" + str(i)).playerChar + "_idle")
	# puts characters at cart starting location
	for i in range(0, 4):
			if has_node("../Player" + str(i)):
				get_node("../Player" + str(i)).translation = translation + $zeroPoint.translation + Vector3(0, 1, 0)
	# removes arrow
	$bubble.queue_free()
	# moves cart
	anim.play("go")
	
	


func _on_hurtbox_area_entered_exiting(area):
	pg.dontMove = true
	exiting = true
	if active:
		return
	active = true
	for i in range(0, 4):
			if has_node("../Player" + str(i)):
				get_node("../Player" + str(i)).visible = false
			# picks player sprite, puts fake player in car
			if not hasFoundMainCharacter:
				hasFoundMainCharacter = true
				mainCharNumber = i
				sprite.play(get_node("../Player" + str(i)).playerChar + "_idle")
	# puts characters at cart starting location
	for i in range(0, 4):
			if has_node("../Player" + str(i)):
				get_node("../Player" + str(i)).translation = translation + $zeroPoint.translation + Vector3(0, 1, 0)
	# moves cart
	anim.play("go")
	# removes trigger
	$zeroPoint/hurtbox.queue_free()
	# locks cam
	cam = get_node("/root/" + pg.levelName + "/camera_pivot/Camera")
	cam.lockedHeight = true
	
func freePlayers():
	$zeroPoint/AnimatedSprite3D.queue_free()
	pg.dontMove = false
	pg.dropPlayerEnabled = true
	active = false
	exiting = false
	# play sfx
	soundManager.pitchSound("jump", 1.0)
	soundManager.playSound("jump")
	for i in range(0, 4):
			if has_node("../Player" + str(i)):
				get_node("../Player" + str(i)).follwingAirbornePlayer = true
				get_node("../Player" + str(i)).visible = true
				get_node("../Player" + str(i)).bouncing = true
				get_node("../Player" + str(i)).bounceHeight = 30
	# unlocks camera
	cam = get_node("/root/" + pg.levelName + "/camera_pivot/Camera")
	cam.lockedHeight = false
