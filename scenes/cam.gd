extends Camera

export var offsetX = 0
export var offsetY = 12
export var offsetZ = 28

var shakeX = 0
var shakeY = 0
var shakeZ = 0
var shaking = false

var tempX = 0
var tempY = 0
var tempZ = 0
var desX = 0
var desY = 0
var desZ = 0
var actX = 0
var actY = 0
var actZ = 0
var minY = 0
var maxZ = 0

var debugMode = false

onready var pivot = get_parent_spatial()

var playerPositions = PoolVector3Array()
var playerShadows = []

var playerCount = 0
var wallsRemoved = false

var inAmbush = false
var ambushTarget = Vector3.ZERO
var inCutscene = false
var cutsceneTarget = Vector3.ZERO
var oldTarget = Vector3.ZERO
var ambushSpawnPoint = Vector3.ZERO
var returning = false
var canTriggerAmbush = true

var onLeftWall  = false
var onRightWall = false

func initialize(loc):
	actX = loc.x
	actY = loc.y
	actZ = loc.z
	pivot.translation.x = loc.x + offsetX
	pivot.translation.y = loc.y + offsetY
	pivot.translation.z = loc.z + offsetZ
	
func checkRespawnPoint():
	get_parent().get_node("spawnFinder/pivot/rays/RayCast").force_raycast_update()
	get_parent().get_node("spawnFinder/pivot/rays/RayCast2").force_raycast_update()
	get_parent().get_node("spawnFinder/pivot/rays/RayCast3").force_raycast_update()
	get_parent().get_node("spawnFinder/pivot/rays/RayCast4").force_raycast_update()
	if (get_parent().get_node("spawnFinder/pivot/rays/RayCast").is_colliding()) and (get_parent().get_node("spawnFinder/pivot/rays/RayCast2").is_colliding()) and (get_parent().get_node("spawnFinder/pivot/rays/RayCast3").is_colliding()) and (get_parent().get_node("spawnFinder/pivot/rays/RayCast4").is_colliding()):
		return true
	else:
		return false
		
func findSpawnPoint(loc):
	if (inAmbush or inCutscene):
		return ambushSpawnPoint
	var pivotPoint = get_parent().get_node("spawnFinder/pivot")
	var rays = get_parent().get_node("spawnFinder/pivot/rays")
	var angle = 0
	var dist = 0
	var loopCount = 0
	# positions spawn finder on the last spot the player tounched the ground
	get_parent().get_node("spawnFinder").global_transform.origin = loc + Vector3(0, 75, 0)
	#print("SpawnFinder: " + str(get_parent().get_node("spawnFinder").global_transform.origin))
	# zeros the seeker position
	pivotPoint.rotation_degrees = Vector3.ZERO
	rays.translation = Vector3.ZERO
	# scans for a safe spot to land the player
	while (checkRespawnPoint() == false):
		if (angle >= 180):
			dist += 1
			angle = -179
		angle += 5
		loopCount += 1
		rays.translation.x = dist
		pivotPoint.rotation_degrees.y = angle 
		if (loopCount >= 30000):
			#print("not found! - " + str(dist) + " - " + str(angle))
			return Vector3(0, 5, 0)
	# saves found position as spawnPoint
	var spawnPoint = get_parent().get_node("spawnFinder/pivot/rays").global_transform.origin
	spawnPoint.y = get_parent().get_node("spawnFinder/pivot/rays/RayCast").get_collision_point().y
	print("found! - " + str(dist) + "m - " + str(angle) + "deg - " + str(loopCount) + "counts")
	print("loc: " + str(loc) + " - spawn: " + str(spawnPoint))
	return spawnPoint

func disableBarriers(choice):
	get_parent().get_node("leftWall/CollisionShape").disabled = choice
	#get_parent().get_node("leftWall/passThroughL/CollisionShape2").disabled = choice
	get_parent().get_node("rightWall/CollisionShape").disabled = choice
	#get_parent().get_node("rightWall/passThroughR/CollisionShape2").disabled = choice

# cutscene functions
func startCutscene():
	disableBarriers(true)
	pg.dontMove = true
	inCutscene = true
	canTriggerAmbush = false
	oldTarget.x = actX
	oldTarget.y = actY
	oldTarget.z = actZ
func endCutscene():
	inCutscene = false
	returning = true
func reEnablePlay():
	disableBarriers(false)
	pg.dontMove = false
	returning = false
	inCutscene = false
	canTriggerAmbush = true
	
# camera shake
func shake(sec):
	shaking = true
	get_node("Timer").start(sec)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	self.fov = 30
	
func _process(_delta):
	# Debug mode activate/deactivate
	if ((Input.is_action_just_pressed("cam_mode") == true)) and (pg.debugCameraAvailable):
		if debugMode:
			debugMode = false
			print("Camera Freed")
			disableBarriers(false)
		else:
			debugMode = true
			print("Camera Locked")
			disableBarriers(true)
	
	# checks for active players and makes array of player positions
	playerPositions = []
	playerShadows = []
	playerCount = 0
	if has_node("../../Player0"):
		playerPositions.append(get_node("../../Player0").translation)
		playerShadows.append(get_node("../../Player0").secondaryY)
		playerCount += 1
	if has_node("../../Player1"):
		playerPositions.append(get_node("../../Player1").translation)
		playerShadows.append(get_node("../../Player1").secondaryY)
		playerCount += 1
	if has_node("../../Player2"):
		playerPositions.append(get_node("../../Player2").translation)
		playerShadows.append(get_node("../../Player2").secondaryY)
		playerCount += 1
	if has_node("../../Player3"):
		playerPositions.append(get_node("../../Player3").translation)
		playerShadows.append(get_node("../../Player3").secondaryY)
		playerCount += 1
	if (playerPositions.size() == 0):
		return
	
		
	# puts camera at average position
	tempX = 0 #sum of x values
	tempY = 0
	tempZ = 0
	minY = playerShadows[0] #minimum floor height of players
	maxZ = playerPositions[0].z
	
	for player in playerPositions:
		tempX += player.x
		if (maxZ < player.z):
			maxZ = player.z
	for shadow in playerShadows:
		if (minY > shadow):
			minY = shadow
	
	if (returning):
		desX = oldTarget.x
		desY = oldTarget.y
		desZ = oldTarget.z
	elif (inCutscene):
		desX = cutsceneTarget.x
		desY = cutsceneTarget.y
		desZ = cutsceneTarget.z
	elif (inAmbush):
		desX = ambushTarget.x
		desY = ambushTarget.y
		desZ = ambushTarget.z
	else:
		desX = tempX/playerPositions.size()
		desY = minY
		desZ = maxZ
		
	# x correction for camera walls
	if (onLeftWall) and (desX < actX):
		desX = actX
	elif (onRightWall) and (desX > actX):
		desX = actX
		
	# randomizes shake effect
	if shaking:
		shakeX = rng.rand.randf_range(-0.5, 0.5)
		shakeY = rng.rand.randf_range(-0.5, 0.5)
		shakeZ = rng.rand.randf_range(-0.5, 0.5)
	else:
		shakeX = 0
		shakeY = 0
		shakeZ = 0
	
	if (debugMode == false):
		actX += 0.1*(desX - actX) 
		actY += 0.05*(desY - actY) 
		actZ += 0.1*(desZ - actZ) 
		pivot.translation.x = actX + offsetX + shakeX
		pivot.translation.y = actY + offsetY + shakeY
		pivot.translation.z = actZ + offsetZ + shakeZ
	else:
		# debug camera moveable with arrow keys
		if (Input.is_action_pressed("move_left_k1") == true):
			pivot.translation.x -= 0.2
		elif (Input.is_action_pressed("move_right_k1") == true):
			pivot.translation.x += 0.2
		elif (Input.is_action_pressed("move_away_k1") == true):
			pivot.translation.y += 0.2
		elif (Input.is_action_pressed("move_in_k1") == true):
			pivot.translation.y -= 0.2
	
	# checks if cam has returned to previous position after a cutscene, and if yer re-enables movement
	if (returning):
		if (abs(actX - oldTarget.x) < 0.1) and (abs(actY - oldTarget.y) < 0.1) and (abs(actZ - oldTarget.z) < 0.1):
			reEnablePlay()


func _on_Timer_timeout():
	shaking = false
