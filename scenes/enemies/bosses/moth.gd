#===============================================================
#MOTH
#===============================================================

extends Spatial

var cam = null
var cameraOffset = Vector3(0, 5, 25)
var cameraOffsetIntro = Vector3(0, -8, -8)
var vfxScene = preload("res://scenes/vfx.tscn")
var barrelScene = preload("res://maps/level objects/barrelDropped.tscn")
var countDown = 180
var aggro = false
var defeated = false

export var bossMusic = "boss2"

var hitDamage = 0
var hitType = 0
var hitDir = Vector3.ZERO
export var hpMax = 400
var hp = 0
var invincible = false

enum {WAIT, INTRO, IDLEPREP, IDLE, OFFSCREEN, SLAMPREP, SLAM, SWOOPFROMLEFTPREP, SWOOPFROMLEFT, SWOOPFROMRIGHTPREP, SWOOPFROMRIGHT, SWOOPFROMBACKPREP, SWOOPFROMBACK, GRABBARREL, GUSTFROMLEFT, BARRELDROP, HIGHSLAMPREP, HIGHSLAM, HURTAIR, HURTFLOOR, DEAD, UNLOAD}
enum {KB_WEAK, KB_STRONG, KB_ANGLED, KB_AIR, KB_STRONG_RECOIL, KB_AIR_UP, KB_WEAK_PIERCE, KB_STRONG_PIERCE, KB_ANGLED_PIERCE}

var state = WAIT
var nextState = WAIT
var phase = 0
var bossAnimFinished = false

var idleTimer = 3
var attackDelayTimer = 3
var minionCount = 0

var target = null

var hitGeyser = false

var prevAttack = SWOOPFROMLEFTPREP
var prevAttackOff = IDLEPREP

var followingAnimSetpoint = [true, true, true, true] # [X, Y, Z, Rot]
var bossCodePosSetpoint = Vector3.ZERO
var bossCodeRotSetpoint = Vector3.ZERO
var POSkp = 0.25
var ROTkp = 5
var velocity = Vector3.ZERO
var prevLoopYAngle = 0

onready var bossAnim = $"bossAnimationPlayer"
onready var mainAnim  = $"mainAnimationPlayer"
onready var modelAnim = $"boss/model/AnimationPlayer"
onready var boss = $"boss"
onready var model = $"boss/model"
onready var bossAnimSetpoint = $"bossPositionSetpoint"
onready var shadow = $"shadowMaker"

# prevents enemies hit by friendly fire from targetting the robot
var playerChar = "proj" 
var hitLanded = false
var hitSound = "hit4"

func setHitBox(attackDamage, type, dir):
	hitDamage = attackDamage
	hitType = type
	hitDir = dir # for direction, +x and +y means away and up. ~10 for magnitude
	
func equalOdds(stateArray):
	while (prevAttack in stateArray):
		stateArray.erase(prevAttack)
	while (prevAttackOff in stateArray):
		stateArray.erase(prevAttackOff)
	var i = rng.rand.randi_range(0, len(stateArray)-1)
	return stateArray[i]
	
func rollAttackFromIdle():
	var tempState = SLAMPREP
	# forces attack
#	attackDelayTimer = 2
#	return GUSTFROMLEFT
	# normal rolls
	phase = findPhase()
	# picks attack
	match phase:
		0:
			tempState = equalOdds([SLAMPREP, SWOOPFROMBACKPREP, SWOOPFROMLEFTPREP, SWOOPFROMRIGHTPREP])
		1:
			tempState = equalOdds([SLAMPREP, SWOOPFROMBACKPREP, SWOOPFROMBACKPREP, SWOOPFROMLEFTPREP, SWOOPFROMRIGHTPREP, GRABBARREL, GRABBARREL])
		2:
			tempState = equalOdds([SLAMPREP, SLAMPREP, SWOOPFROMBACKPREP, SWOOPFROMBACKPREP, SWOOPFROMLEFTPREP, SWOOPFROMRIGHTPREP,  GRABBARREL, GRABBARREL, GUSTFROMLEFT, GUSTFROMLEFT])
	# sets appropriate delay
	match tempState:
		SLAMPREP:
			attackDelayTimer = 1.5#rng.rand.randf_range(1.0, 2.5)
		SWOOPFROMBACKPREP:
			attackDelayTimer = 2#rng.rand.randf_range(1.5, 3)
		SWOOPFROMLEFTPREP, SWOOPFROMRIGHTPREP:
			attackDelayTimer = 2#rng.rand.randf_range(1.0, 2)
	prevAttack = tempState
	return tempState
			
func rollAttackFromOff():
	var tempState = SLAMPREP
	# forces attack
#	attackDelayTimer = rng.rand.randf_range(3, 3.5)
#	return BARRELDROP
	# normal rolls
	phase = findPhase()
	# picks attack
	match phase:
		0:
			tempState = IDLEPREP
		1:
			tempState = equalOdds([IDLEPREP, HIGHSLAMPREP])
		2:
			tempState = equalOdds([BARRELDROP, HIGHSLAMPREP])
	# sets appropriate delay
	match tempState:
		HIGHSLAMPREP:
			attackDelayTimer = 1.5#rng.rand.randf_range(1.5, 2.5)
	prevAttackOff = tempState
	return tempState
		
#func rollAttackPad():
#	if not inRange():
#		return ENTERWATER
#	elif (biteCount >= 2):
#		return JUMP
#	match phase:
#		0:
#			if (rng.rand.randf() <= 0.666):
#				return BITE
#		1: 
#			if (rng.rand.randf() <= 0.5):
#				return BITE
#			elif (rng.rand.randf() <= 0.5):
#				return JUMP
#		2:
#			if (rng.rand.randf() <= 0.4):
#				return BITE
#			else:
#				return JUMP
#		_:
#			return ENTERWATER
#	return ENTERWATER

func activateGeysers(turnOn = true):
	for i in range(1, 4):
		var geyser = get_node("geyser" + str(i))
		geyser.activate(turnOn)
		
func removeBridge():
	if get_node_or_null("bridge") != null:
		get_node("bridge").queue_free()
		
func setBarrelZ(num, randOffset = false):
	get_node("bar" + str(num)).global_transform.origin.z = target.translation.z
	if randOffset:
		get_node("bar" + str(num)).translation.z += rng.rand.randf_range(-4, 4)
	if (get_node("bar" + str(num)).translation.z >= 17):
		get_node("bar" + str(num)).translation.z = 17
	elif (get_node("bar" + str(num)).translation.z <= -17):
		get_node("bar" + str(num)).translation.z = -17

func spawnBarrel(type = 0):
	var bar = barrelScene.instance()
	get_parent().add_child(bar)
	var tempAngle
	var launchVel
	var spawnOffset
	if (type == 0):
		tempAngle = atan2((target.translation.x - boss.global_transform.origin.x), (target.translation.z - boss.global_transform.origin.z))
		launchVel = Vector3(0, 16, 18).rotated(Vector3.UP, tempAngle)
		spawnOffset = Vector3.ZERO
	elif (type == 1):
		launchVel = Vector3(50, 50, 0)
		spawnOffset = Vector3(-18, -6, 0)
	var roll = rng.rand.randi_range(0, 7)
	match roll:
		0, 1:
			bar.initialize(boss.global_transform.origin + spawnOffset, launchVel, boss.rotation_degrees.y, 3, 0, 0, 0, 0)
		2, 3:
			bar.initialize(boss.global_transform.origin + spawnOffset, launchVel, boss.rotation_degrees.y, 0, 2, 1, 0, 0)
		4, 5, 6:
			bar.initialize(boss.global_transform.origin + spawnOffset, launchVel, boss.rotation_degrees.y, 0, 0, 0, 2, 0)
		7:
			bar.initialize(boss.global_transform.origin + spawnOffset, launchVel, boss.rotation_degrees.y, 0, 0, 0, 0, 1)
	return
	

func pickRandomTarget():
	if pg.playerAlive == [false, false, false, false]:
		target = null
		return
	var potentialTargetNum = 9
	while (get_parent().get_node_or_null("Player" + str(potentialTargetNum)) == null):
		potentialTargetNum = rng.rand.randi_range(0, 3)
		#print("tried player" + str(potentialTargetNum))
	target = get_parent().get_node_or_null("Player" + str(potentialTargetNum))
	
func verifyTargetExists():
	if pg.playerAlive == [false, false, false, false]:
		target = null
		return
	elif target == null:
		pickRandomTarget()

func findPhase():
	if (float(hp)/float(hpMax)) >= 0.75:
		return 0
	elif (float(hp)/float(hpMax)) >= 0.4:
		return 1
	else:
		return 2
		
func isInState(list):
	var found = false
	for i in list:
		if state == i:
			found = true
	return found
	
func setRotkp(value = -1):
	if value == -1:
		ROTkp = 5
	else:
		ROTkp = value
		
func setPoskp(value = -1):
	if value == -1:
		POSkp = 0.25
	else:
		POSkp = value
		
func capVelocity(speed, ignoreY = false):
	if ignoreY:
		var XZVel = Vector2(velocity.x, velocity.z)
		if (speed < XZVel.length()):
			XZVel = XZVel.normalized() * speed
			velocity.x = XZVel.x
			velocity.z = XZVel.y
	else:
		if (speed < velocity.length()):
			velocity = velocity.normalized() * speed
		
	
func setFollowingAnimSetpoint(x, y, z, rot):
	followingAnimSetpoint = [x, y, z, rot]

#func rollAttackWater():
#	#print(safeAttackCount)
#	if (safeAttackCount >= 2):
#		safeAttackCount = 0
#		return EXITWATER
#	match phase:
#		0:
#			if ((rng.rand.randf() <= 0.25)):
#				safeAttackCount += 1
#				return FLIPWARN
#		1:
#			if ((rng.rand.randf() <= 0.35)):
#				if ((rng.rand.randf() <= 0.3)):
#					safeAttackCount += 1
#					return FLIPWARN
#				else:
#					safeAttackCount += 1
#					return SWEEP
#		2:
#			if ((rng.rand.randf() <= 0.4)):
#				if ((rng.rand.randf() <= 0.5)):
#					safeAttackCount += 1
#					return FLIPWARN
#				else:
#					safeAttackCount += 1
#					return SWEEP
#		_:
#			safeAttackCount = 0
#			return EXITWATER
#	safeAttackCount = 0
#	return EXITWATER

#func inRange():
#	if ((location == LEFT) or (location == RIGHT)) and (padMCount > 0):
#		return true
#	elif (location == MIDLEFT) and (padLCount > 0):
#		return true
#	elif (location == MIDRIGHT) and (padRCount > 0):
#		return true
#	else:
#		return false

# Called when the node enters the scene tree for the first time.
func _ready():
	state = WAIT
	nextState = WAIT
	hp = hpMax
	$"info/lifeBar".max_value = hpMax
	if pg.hardMode:
		get_node("boss/arrow").play("invis")
	else:
		get_node("boss/arrow").play("default")

# animation controlled functions
func startCutscene():
	cam.startCutscene()
func endCutscene():
	cam.endCutscene()
func playAndShake():
	cam.shake(1)
	soundManager.playSound("roar")
	if (state == INTRO):
		soundManager.playMusic(bossMusic)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#to prevent craches if current target dissapears
	if not isInState([WAIT, INTRO]):
		verifyTargetExists()
	
	# FSM
	match state:
		WAIT:
			if aggro:
				bossAnimFinished = false
				nextState = INTRO
			else:
				nextState = WAIT
		INTRO:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLEPREP
				activateGeysers()
				removeBridge()
		IDLEPREP:
			pickRandomTarget()
			idleTimer = rng.rand.randf_range(1.5, 3.5)
			nextState = IDLE
		IDLE:
			bossAnimFinished = false
			hitGeyser = false
			idleTimer -= delta
			if (idleTimer <= 0):
				nextState = rollAttackFromIdle()
			else:
				nextState = IDLE
		OFFSCREEN:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = rollAttackFromOff()
			else:
				nextState = OFFSCREEN
		SWOOPFROMBACKPREP:
			attackDelayTimer -= delta
			if (attackDelayTimer <= 0):
				bossAnimFinished = false
				nextState = SWOOPFROMBACK
			else:
				nextState = SWOOPFROMBACKPREP
		SWOOPFROMBACK:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = OFFSCREEN
			else:
				nextState = SWOOPFROMBACK
		SWOOPFROMLEFTPREP:
			attackDelayTimer -= delta
			if (attackDelayTimer <= 0):
				bossAnimFinished = false
				nextState = SWOOPFROMLEFT
			else:
				nextState = SWOOPFROMLEFTPREP
		SWOOPFROMLEFT:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = OFFSCREEN
			else:
				nextState = SWOOPFROMLEFT
		SWOOPFROMRIGHTPREP:
			attackDelayTimer -= delta
			if (attackDelayTimer <= 0):
				bossAnimFinished = false
				nextState = SWOOPFROMRIGHT
			else:
				nextState = SWOOPFROMRIGHTPREP
		SWOOPFROMRIGHT:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = OFFSCREEN
			else:
				nextState = SWOOPFROMRIGHT
		GUSTFROMLEFT:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLEPREP
			else:
				nextState = GUSTFROMLEFT
		SLAMPREP:
			attackDelayTimer -= delta
			if (attackDelayTimer <= 0):
				bossAnimFinished = false
				nextState = SLAM
			else:
				nextState = SLAMPREP
		SLAM:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLEPREP
			else:
				nextState = SLAM
		HIGHSLAMPREP:
			attackDelayTimer -= delta
			if (attackDelayTimer <= 0):
				bossAnimFinished = false
				nextState = HIGHSLAM
			else:
				nextState = HIGHSLAMPREP
		HIGHSLAM:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLEPREP
			else:
				nextState = HIGHSLAM
		GRABBARREL:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = BARRELDROP
			else:
				nextState = GRABBARREL
		BARRELDROP:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLEPREP
			else:
				nextState = BARRELDROP
		HURTAIR:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = HURTFLOOR
			else:
				nextState = HURTAIR
		HURTFLOOR:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = OFFSCREEN
			else:
				nextState = HURTFLOOR
		DEAD:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = UNLOAD
				unloadBoss()
		UNLOAD:
			nextState = UNLOAD
		_:
			state = IDLE
			nextState = IDLE

	if hitGeyser:
		hitGeyser = false
		bossAnimFinished = false
		nextState = HURTAIR
	
	state = nextState

	# plays animations
	match state:
		WAIT:
			bossAnim.play("wait")
			# handle model animations through boss animation player?
		INTRO:
			bossAnim.play("intro")
		IDLEPREP:
			bossAnim.play("idle")
			bossAnim.seek(rng.rand.randf_range(0, 6))
		IDLE:
			pass
		OFFSCREEN:
			bossAnim.play("offscreen")
		SWOOPFROMBACKPREP:
			bossAnim.play("swoop_back_prep")
		SWOOPFROMBACK:
			bossAnim.play("swoop_back")
		SWOOPFROMLEFTPREP:
			bossAnim.play("swoop_left_prep")
		SWOOPFROMLEFT:
			bossAnim.play("swoop_left")
		SWOOPFROMRIGHTPREP:
			bossAnim.play("swoop_right_prep")
		SWOOPFROMRIGHT:
			bossAnim.play("swoop_right")
		GUSTFROMLEFT:
			bossAnim.play("gust_left")
		SLAMPREP:
			bossAnim.play("slam_prep")
		SLAM:
			bossAnim.play("slam")
		HIGHSLAMPREP:
			bossAnim.play("high_slam_prep")
		HIGHSLAM:
			bossAnim.play("high_slam")
		GRABBARREL:
			bossAnim.play("grab_barrel")
		BARRELDROP:
			bossAnim.play("barrel")
		HURTAIR:
			bossAnim.play("hurt_air")
		HURTFLOOR:
			bossAnim.play("hurt_floor")
		DEAD:
			bossAnim.play("dead")
		UNLOAD:
			bossAnim.play("unloaded")
		_:
			bossAnim.play("wait")
	
	# prevents crashes is target disapears
	if (target == null) and (pg.playerAlive == [false, false, false, false]):
		return
	# sets code positions/rotation
	match state:
		WAIT:
			followingAnimSetpoint = [true, true, true, true]
			bossCodePosSetpoint = Vector3(0, -50, 0)
			bossCodeRotSetpoint = Vector3(0, 0, 0)
		INTRO:
			followingAnimSetpoint = [true, true, true, true]
		IDLEPREP:
			followingAnimSetpoint = [true, true, true, false]
			bossCodeRotSetpoint = Vector3(40, 0, 0)
			bossCodePosSetpoint = Vector3(0, 12, 0)
			setRotkp()
			setPoskp()
		IDLE:
			followingAnimSetpoint = [true, true, true, false]
			var tempAngle = rad2deg(atan2((target.translation.x - boss.global_transform.origin.x), (target.translation.z - boss.global_transform.origin.z)))
			bossCodeRotSetpoint = Vector3(40, tempAngle, 0)
			bossCodePosSetpoint = Vector3(0, 12, 0)
		OFFSCREEN:
			followingAnimSetpoint = [false, false, false, false]
			bossCodeRotSetpoint = Vector3(40, 0, 0)
			bossCodePosSetpoint = Vector3(0, 20, 0)
			setPoskp(1)
			setRotkp()
		SWOOPFROMBACKPREP:
			followingAnimSetpoint = [false, true, true, true]
			#bossCodeRotSetpoint = Vector3(40, 0, 0)
			bossCodePosSetpoint = Vector3(target.translation.x - translation.x, 0, 0)
			setPoskp(0.5)
		SWOOPFROMBACK:
			#followingAnimSetpoint = [false, true, true, true]
			#bossCodeRotSetpoint = Vector3(90, 1000, 0)
			#bossCodePosSetpoint = Vector3(0, 0, 0)
			setPoskp(1)
			setRotkp(5)
		SWOOPFROMLEFTPREP:
			followingAnimSetpoint = [true, true, false, false]
			var tempAngle = rad2deg(atan2((target.translation.x - boss.global_transform.origin.x), (target.translation.z - boss.global_transform.origin.z)))
			bossCodeRotSetpoint = Vector3(40, tempAngle, 0)
			bossCodePosSetpoint = Vector3(0, 0, target.translation.z - translation.z)
			setPoskp(0.5)
		SWOOPFROMLEFT:
			#followingAnimSetpoint = [true, true, false, true]
			#bossCodeRotSetpoint = Vector3(90, 1000, 0)
			#bossCodePosSetpoint = Vector3(0, 0, 0)
			setPoskp(1)
			setRotkp(5)
		SWOOPFROMRIGHTPREP:
			followingAnimSetpoint = [true, true, false, false]
			var tempAngle = rad2deg(atan2((target.translation.x - boss.global_transform.origin.x), (target.translation.z - boss.global_transform.origin.z)))
			bossCodeRotSetpoint = Vector3(40, tempAngle, 0)
			bossCodePosSetpoint = Vector3(0, 0, target.translation.z - translation.z)
			setPoskp(0.5)
		SWOOPFROMRIGHT:
			#followingAnimSetpoint = [true, true, false, true]
			#bossCodeRotSetpoint = Vector3(90, 1000, 0)
			#bossCodePosSetpoint = Vector3(0, 0, 0)
			setPoskp(1)
			setRotkp(5)
		GUSTFROMLEFT:
			followingAnimSetpoint = [true, true, true, true]
			setPoskp()
			setRotkp(2)
		SLAMPREP:
			followingAnimSetpoint = [false, true, false, true]
			bossCodeRotSetpoint = Vector3(40, 0, 0)
			bossCodePosSetpoint = Vector3(target.translation.x - translation.x, 0, target.translation.z - translation.z - 0.5)
			setPoskp(0.5)
		SLAM:
			var tempAngle = rad2deg(atan2((target.translation.x - boss.global_transform.origin.x), (target.translation.z - boss.global_transform.origin.z)))
			bossCodeRotSetpoint = Vector3(40, tempAngle, 0)
			#bossCodePosSetpoint = Vector3(0, 12, 0)
			setPoskp(0.5)
		HIGHSLAMPREP:
			followingAnimSetpoint = [false, true, false, true]
			bossCodeRotSetpoint = Vector3(40, 0, 0)
			bossCodePosSetpoint = Vector3(target.translation.x - translation.x, 0, target.translation.z - translation.z - 0.5)
			setPoskp(0.5)
		HIGHSLAM:
			var tempAngle = rad2deg(atan2((target.translation.x - boss.global_transform.origin.x), (target.translation.z - boss.global_transform.origin.z)))
			bossCodeRotSetpoint = Vector3(40, tempAngle, 0)
			#bossCodePosSetpoint = Vector3(0, 12, 0)
			setPoskp(0.5)
		BARRELDROP:
			followingAnimSetpoint = [true, true, true, false]
			var tempAngle = rad2deg(atan2((target.translation.x - boss.global_transform.origin.x), (target.translation.z - boss.global_transform.origin.z)))
			bossCodeRotSetpoint = Vector3(40, tempAngle, 0)
			bossCodePosSetpoint = Vector3(0, 12, 0)
			setRotkp()
			setPoskp()
		GRABBARREL:
			followingAnimSetpoint = [true, true, true, false]
			$bossPositionSetpoint2.look_at_from_position(boss.translation, (-1 * velocity), Vector3.UP)
			bossCodeRotSetpoint = $bossPositionSetpoint2.rotation_degrees + Vector3(90, 0, 0)
			setRotkp()
			setPoskp(0.2)
		HURTAIR:
			followingAnimSetpoint = [false, true, false, false]
			bossCodeRotSetpoint = Vector3(-90, -120, 0)
			bossCodePosSetpoint = Vector3(0, 0, 0)
			setRotkp()
			setPoskp(1)
		HURTFLOOR:
			followingAnimSetpoint = [true, true, true, true]
			bossCodeRotSetpoint = Vector3(0, 0, 0)
			bossCodePosSetpoint = Vector3(0, 0, 0)
			setRotkp(10)
			setPoskp(1)
		DEAD:
			bossCodeRotSetpoint = Vector3(-90, -120, 0)
			bossCodePosSetpoint = Vector3(0, 0, 0)
			$bossPositionSetpoint2.look_at_from_position(boss.translation, (-1 * velocity), Vector3.UP)
			bossCodeRotSetpoint = $bossPositionSetpoint2.rotation_degrees + Vector3(90, 0, 0)
			setRotkp(10)
			setPoskp(1)
		_:
			followingAnimSetpoint = [false, false, false, false]
			bossCodePosSetpoint = Vector3(0, -50, 0)
			bossCodeRotSetpoint = Vector3(0, 0, 0)
	# positioning via animations
	if followingAnimSetpoint[0]: #X pos
		velocity.x = (1.0/delta) * POSkp * (bossAnimSetpoint.translation.x - boss.translation.x)
	else:
		#boss.translation.x += POSkp * (bossCodePosSetpoint.x - boss.translation.x)
		velocity.x = (1.0/delta) * POSkp * (bossCodePosSetpoint.x - boss.translation.x)
	if followingAnimSetpoint[1]: #Y pos
		#boss.translation.y += POSkp * (bossAnimSetpoint.translation.y - boss.translation.y)
		velocity.y = (1.0/delta) * POSkp * (bossAnimSetpoint.translation.y - boss.translation.y)
	else:
		#boss.translation.y += POSkp* (bossCodePosSetpoint.y - boss.translation.y)
		velocity.y = (1.0/delta) * POSkp* (bossCodePosSetpoint.y - boss.translation.y)
	if followingAnimSetpoint[2]: #Z pos
		#boss.translation.z += POSkp * (bossAnimSetpoint.translation.z - boss.translation.z)
		velocity.z = (1.0/delta) * POSkp * (bossAnimSetpoint.translation.z - boss.translation.z)
	else:
		#boss.translation.z += POSkp * (bossCodePosSetpoint.z - boss.translation.z)
		velocity.z = (1.0/delta) * POSkp * (bossCodePosSetpoint.z - boss.translation.z)
	if followingAnimSetpoint[3]: #rotation
		boss.rotation.x = lerp_angle(boss.rotation.x, bossAnimSetpoint.rotation.x, ROTkp*delta)
		boss.rotation.y = lerp_angle(boss.rotation.y, bossAnimSetpoint.rotation.y, ROTkp*delta)
		boss.rotation.z = lerp_angle(boss.rotation.z, bossAnimSetpoint.rotation.z, ROTkp*delta)
		#boss.set_rotation_degrees(bossAnimSetpoint.get_rotation_degrees())
	else:
		boss.rotation.x = lerp_angle(boss.rotation.x, deg2rad(bossCodeRotSetpoint.x), ROTkp*delta)
		boss.rotation.y = lerp_angle(boss.rotation.y, deg2rad(bossCodeRotSetpoint.y), ROTkp*delta)
		boss.rotation.z = lerp_angle(boss.rotation.z, deg2rad(bossCodeRotSetpoint.z), ROTkp*delta)
		
	if isInState([IDLEPREP, IDLE]):
		capVelocity(15)
	elif isInState([SLAMPREP, SWOOPFROMBACKPREP, SWOOPFROMLEFTPREP, SWOOPFROMRIGHTPREP, GUSTFROMLEFT]):
		capVelocity(25)
	if isInState([HURTAIR]):
		capVelocity(20, true)
		
	velocity = boss.move_and_slide(velocity, Vector3.UP, true)
	
	get_node("bossPositionSetpoint2").rotation_degrees = bossCodeRotSetpoint
	get_node("bossPositionSetpoint2").translation = bossCodePosSetpoint
	
	# positions arrow  to ground if needed
	if isInState([SLAMPREP, SLAM, HIGHSLAMPREP, HIGHSLAM]):
		get_node("boss/arrow").global_transform.origin.x = boss.global_transform.origin.x 
		get_node("boss/arrow").global_transform.origin.y = translation.y + 1 
		get_node("boss/arrow").global_transform.origin.z = boss.global_transform.origin.z 

		
	# sets hitboxes
	match state:
		IDLE:
			setHitBox(0, KB_WEAK, Vector3(1, 0, 0))
		SLAM, HIGHSLAM:
			setHitBox(20, KB_ANGLED_PIERCE, Vector3(10, 25, 0))
		SWOOPFROMBACK:
			setHitBox(18, KB_ANGLED_PIERCE, Vector3(6, 35, 0))
		SWOOPFROMLEFT, SWOOPFROMRIGHT:
			setHitBox(15, KB_ANGLED, Vector3(6, 35, 0))
		HURTFLOOR:
			setHitBox(2, KB_ANGLED, Vector3(30, 15, 0))
		DEAD:
			setHitBox(50, KB_ANGLED, Vector3(0, 2, 0))
	



	# test prints
	#print("L: " + str(padLCount) + "   M: " + str(padMCount) + "   R: " + str(padRCount))
	#print(str(state))

	# health bar
	$"info/lifeBar".value = hp #* float(hp/hpMax)
	
	# makes cam follow boss durring "cutscene" moments
	if isInState([INTRO]):
		cam.cutsceneTarget = translation + boss.translation + cameraOffsetIntro
	elif isInState([DEAD]):
		cam.cutsceneTarget = translation + boss.translation + cameraOffsetIntro + Vector3(0, 3, 5)

	# handles death:
	if (hp <= 0) and (not defeated):
		soundManager.FadeOutSong(bossMusic)
		nextState = DEAD
		state = DEAD
		defeated = true
		activateGeysers(false)

	#sets boss phase
	phase = findPhase()
	
	# moves shadow
	shadow.translation = boss.translation + Vector3(0, 4, 0)


func _on_cameraTrigger_area_entered(area):
	# Camera positioning
	cam = area.get_parent()
	cam.inAmbush = true
	cam.ambushTarget = translation + cameraOffset
	cam.cutsceneTarget = translation + boss.translation + cameraOffsetIntro
	cam.ambushSpawnPoint = translation + Vector3(0, 0, 9)
	get_node("cameraTrigger").queue_free()
	aggro = true

func unloadBoss():
	# Drops box
	get_parent().get_node("goal").gravOn = true
#	# Frees camera
#	cam.inAmbush = false
#	# makes visual effect
#	var vfx = vfxScene.instance()
#	get_parent().add_child(vfx)
#	vfx.playEffect("go_arrow")
	# sets beaten flag
	defeated = true
	#re-plays level music
	#soundManager.playMusic(pg.levelMusic)

func _on_hurtbox_area_entered(area):
	# identifies attacker
	var attacker = area.get_parent().get_parent()
	if attacker == self:
		return
	# returns if in an invincible state (just got hit)
	if (invincible == true):
		return
	# makes enemy unhittable until it leaves a hitbox
	invincible = true
	# Produces hit vfx
	var vfx = vfxScene.instance()
	get_parent().add_child(vfx)
	vfx.playEffect("hit", 0.5*($"boss".translation + translation + attacker.translation))
	# deals damage
	# triggers hurt animation
	if area.is_in_group("geyser"):
		hitGeyser = true
		hp -= 5
	else:
		hp -= attacker.hitDamage
	# tells attacker that the hit occurred
	attacker.hitLanded = true
	# signals attacker if hit with a move that has knockback
	if (attacker.hitType == KB_STRONG_RECOIL):
		attacker.recoilStart = true
	# plays sfx
	soundManager.playSound(attacker.hitSound)


func _on_hurtbox_area_exited(area):
	invincible = false



func _on_mainAnimationPlayer_animation_finished(anim_name):
	pass # Replace with function body.


func _on_bossAnimationPlayer_animation_finished(anim_name):
	bossAnimFinished = true
