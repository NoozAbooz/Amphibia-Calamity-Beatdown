extends KinematicBody

onready var anim2 = $"anim2"
onready var zone = $"zone"

var glowColor = Color(1, 1, 1, 1)
var glowAlpha = 0
var glowHue = 0
var glowActivated = false

var cam = null
var camOffset = Vector3(0, 0, 6)

var activated = false
var alreadyHit = false

export var gravOn = false
var force_grav = 100#120.0
var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	anim2.play("idle")
	$hurtBox/CollisionShape.disabled = true
	velocity = Vector3.ZERO

func _process(delta):
	if activated:
		# Hue cycle
		glowHue += 2 * delta
		if (glowHue >= 1):
			glowHue = 0
		# Alpha fade-in
		if (glowAlpha >= 0.8):
			glowAlpha = 0.65
		elif glowActivated:
			glowAlpha += 1 * delta
		# sets color
		glowColor = Color.from_hsv(glowHue, 0.5, 0.75, glowAlpha)
		$glow.get_active_material(0).albedo_color = glowColor
	if gravOn:
		# Gravity
		velocity.y -= force_grav * delta
		velocity = move_and_slide(velocity, Vector3.UP, true)
		
	

func startGlowEffect():
	glowActivated = true


func _on_zone_area_entered(area):
	# activated box so it will fall/respond to attacks
	activated = true
	$hurtBox/CollisionShape.disabled = false
	#anim2.play("open")
	# removes area detection for goal
	zone.queue_free()
	# removes ability to pause
	#get_parent().get_node("pauseScreen").queue_free()
	# fades out music
	soundManager.FadeOutSong(pg.levelMusic)
	# positions camera
	cam = get_node("/root/" + pg.levelName + "/camera_pivot/Camera")
	cam.inAmbush = true
	cam.ambushTarget = translation + camOffset
	cam.ambushSpawnPoint = translation + Vector3(0, 2, 0)
	
func _on_hurtBox_area_entered(area):
	if (not activated) or alreadyHit:
		return
	alreadyHit = true
	soundManager.playSound("hit2")
	anim2.play("open")
	
func freeze():
	# stops players
	pg.dontMove = true

func boxSoundStart():
	soundManager.playSound("musicBox")
	
func victoryMusic():
	soundManager.playMusic("stats")

func triggerFadeOut():
	# updates global player values from player nodes
	pg.playerLives = [0, 0, 0, 0]
	pg.playerCoins = [0, 0, 0, 0]
	for i in range(0, 4):
		if has_node("../Player" + str(i)):
			pg.playerLives[i] = get_node("../Player" + str(i)).lives
			pg.playerCoins[i] = get_node("../Player" + str(i)).coins
	# runs end level function in playerGlobals
	pg.endLevel()
