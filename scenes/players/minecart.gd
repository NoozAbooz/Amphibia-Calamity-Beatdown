extends KinematicBody

var vfxScene = preload("res://scenes/vfx.tscn")

var coinScene = preload("res://maps/minecart/coinDropped.tscn")

var jump = "cart_jump"

onready var wheels = [get_node("zeroPoint/wheels/wheel0"), get_node("zeroPoint/wheels/wheel1"), get_node("zeroPoint/wheels/wheel2"), get_node("zeroPoint/wheels/wheel3")]
onready var anim = get_node("AnimationPlayer")
onready var sprite = get_node("zeroPoint/AnimatedSprite3D")
var mainCharacter = "none"

# look of cart
var cartType = 0

# player variables
var hpMax = 0
var playerHealth = [0, 0, 0, 0]
var playerCoins = [0, 0, 0, 0]
var playerLives = [0, 0, 0, 0]
var playerCharacter = ["Anne", "Anne", "Anne", "Anne"]

# speed variables/constants
var forceGrav = 135.0
var forceJump = 45.0
var forceHurtLaunch = 36.0
var forceWind = 0
var forceRoll = 20
var forceHurtX = 36
var defaultMaxSpeed = 25
var velocity = Vector3.ZERO
var zPOS = 0
var desAngle = 0
var actAngle = 0

# max speed control
var actMaxSpeed = defaultMaxSpeed
var desMaxSpeed = defaultMaxSpeed
var speedFactor = 1

#input buffer stuff
var inputBuffTimer = 0
var inputBuffMax = 8
var inputJump = false

# state machine
enum {SPAWN, IDLE, JUMP, RISING, FALLING, BOUNCE, LAND, HURTLAUNCH, HURTRISING, CRASH}
var state = IDLE
var nextState = IDLE
var changedState = false
var finishedLanding = false

# hurting
var justHurt = false
var tempInvincible = false
var damage = 0
var hurtDamageMulti = 1

# hitting
var hitStun = false
var bounced = false

# animations
var animFinished = false

# keeps track of who gets next coin
var nextCoinReceiver = 0

# y value to send to cam
var floorHeight = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func initialize(spawnLocation, type):
	var hasFoundMainCharacter = false
	# Parameter stuff
	translation = spawnLocation
	floorHeight = spawnLocation.y
	zPOS = translation.z
	# Stores important values
	playerHealth = pg.playerHealth
	playerCoins = pg.playerCoins
	playerLives = pg.playerLives
	playerCharacter = pg.playerCharacter
	hpMax = pg.playerStartingMaxHP + (pg.healthUpgrades * pg.healthBoost)
	# sets GUI stuff
	for i in range(0, 4):
		# skips if no alive player
		if (pg.playerAlive[i] == false):
			get_node("playerInfo" + str(i)).queue_free()
			continue
		#picks player sprite
		if not hasFoundMainCharacter:
			hasFoundMainCharacter = true
			mainCharacter = playerCharacter[i]
			sprite.play(mainCharacter + "_idle")
		# Player GUI stuff
		var playerPan = "playerInfo" + str(i)
		# sets up player healthbar/lives/coins
		get_node(playerPan + "/lifeBar").margin_left = get_node(playerPan + "/lifeBar").margin_right - hpMax
		get_node(playerPan + "/lifeOutline").margin_left = get_node(playerPan + "/lifeOutline").margin_right - (hpMax + 8)
		get_node(playerPan + "/lifeBar").value = 100 * float(playerHealth[i]/hpMax)
		get_node(playerPan + "/coinCounter").text = str(playerCoins[i]).pad_zeros(3)
		if (playerLives[i] > 9):
			get_node(playerPan + "/lifeCounter").text = " "
		else:
			get_node(playerPan + "/lifeCounter").text = str(playerLives[i])
		# sets up panel face and name
		if playerCharacter[i] == "Sprig":
			get_node(playerPan + "/charName").text = "Plantars"
		else:
			get_node(playerPan + "/charName").text = playerCharacter[i]
		get_node(playerPan + "/face").play("idle" + playerCharacter[i])
	# damage scaling
	hurtDamageMulti = 1
	if (pg.easyMode):
		hurtDamageMulti *= 0.5
	elif (pg.hardMode):
		hurtDamageMulti *= 2
	# nerfs for multiplayer mode
	var numExtras = (pg.countPlayers() - 1)
	if (numExtras >= 1):
		hurtDamageMulti = hurtDamageMulti * pow(1.2, numExtras)
	updateGUI()
	# look of cart
	cartType = type
	match cartType:
		0:
			$zeroPoint/shop/cart_earth.queue_free()
		1:
			$zeroPoint/shop/cart_newt.queue_free()
		
func updateGUI():
	# sets GUI stuff
	for i in range(0, 4):
		# skips if no alive player
		if (pg.playerAlive[i] == false):
			continue
		# Player GUI stuff
		var playerPan = "playerInfo" + str(i)
		# sets up player healthbar/lives/coins
		get_node(playerPan + "/lifeBar").value = 100 * float(playerHealth[i])/float(hpMax)
		get_node(playerPan + "/coinCounter").text = str(playerCoins[i]).pad_zeros(3)
		if (playerLives[i] > 9):
			get_node(playerPan + "/lifeCounter").text = " "
		else:
			get_node(playerPan + "/lifeCounter").text = str(playerLives[i])
		# sets up panel face
		var condition = "idle"
		if isInState([HURTLAUNCH, HURTRISING]):
			condition = "hurt"
		elif ( (float(playerHealth[i])/float(hpMax)) <= 0.35):
			condition = "low"
		get_node(playerPan + "/face").play(condition + playerCharacter[i])
		
func spawnCoins():
	for i in range(0, 4):
		# skips if no alive player
		if (pg.playerAlive[i] == false):
			continue
		var coinsLeft = playerCoins[i]
		while (coinsLeft > 0):
			if (coinsLeft >= 20):
				var coins = coinScene.instance()
				get_parent().add_child(coins)
				coins.initialize(translation + Vector3(0, 1, 0), 20)
				coinsLeft -= 20
			elif (coinsLeft >= 5):
				var coins = coinScene.instance()
				get_parent().add_child(coins)
				coins.initialize(translation + Vector3(0, 1, 0), 5)
				coinsLeft -= 5
			else:
				var coins = coinScene.instance()
				get_parent().add_child(coins)
				coins.initialize(translation + Vector3(0, 1, 0), 1)
				coinsLeft -= 1
	playerCoins = [0, 0, 0, 0]
	pg.playerCoins = [0, 0, 0, 0]
	updateGUI()
	
func hitEnemy():
	hitStun = true
	$hitTimer.start(0.1)
	
func bounce():
	bounced = true
	
	
func clearInputBuffer():
	inputBuffTimer = 0
	inputJump = false

func updateInputBuffer(delta):
	# increments timer and resets if necessary
	if (inputBuffTimer <= 0):
		clearInputBuffer()
	else:
		inputBuffTimer -= 60 * delta
	# if a key is pressed, re-starts timer and stores key
	if (Input.is_action_just_pressed(jump) == true):
		inputBuffTimer = inputBuffMax
		inputJump = true
		
func addHealth(amount):
	for i in range(0, 4):
		# skips if dead player
		if (pg.playerAlive[i] == false):
			continue
		playerHealth[i] += amount
		if (playerHealth[i]  <= 1):
			playerHealth[i]  = 1
		elif (playerHealth[i]  >= hpMax):
			playerHealth[i]  = hpMax
	updateGUI()

func everyoneIsDead():
	var everyoneIsDead = true
	for i in range(0, 4):
		# skips if dead player
		if (pg.playerAlive[i] == false):
			continue
		if (playerHealth[i]  > 1):
			everyoneIsDead = false
	return everyoneIsDead

func addCoins(amount):
	var coinsToDishOut = amount
	while (coinsToDishOut > 0):
		if (pg.playerAlive[nextCoinReceiver] == false):
			nextCoinReceiver += 1
		else:
			playerCoins[nextCoinReceiver] += 1
			coinsToDishOut -= 1
			nextCoinReceiver += 1
		if (nextCoinReceiver >= 4):
			nextCoinReceiver = 0
#		for i in range(0, 4):
#			# skips if dead player
#			if (pg.playerAlive[i] == false):
#				continue
#			else:
#				playerCoins[i] += amount
#				return
	updateGUI()


func isInState(list):
	var found = false
	for i in list:
		if state == i:
			found = true
	return found

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
		
	var snapVect  = Vector3.ZERO
	
	# input buffer
	updateInputBuffer(delta)

	# state changes ----------------------------------------------
	match state:
		SPAWN:
			nextState = IDLE
		IDLE:
			if (inputJump):
				clearInputBuffer()
				nextState = JUMP
			elif not is_on_floor():
				nextState = FALLING
			elif justHurt:
				nextState = HURTLAUNCH
			elif bounced:
				bounced = false
				nextState = BOUNCE
			else:
				state = IDLE
		JUMP:
			nextState = RISING
			soundManager.pitchSound("jump", 1.0)
			soundManager.playSound("jump")
		BOUNCE:
			nextState = RISING
			soundManager.pitchSound("jump", 1.2)
			soundManager.playSound("jump")
		RISING:
			if (velocity.y <= 0):
				nextState = FALLING
			elif justHurt:
				nextState = HURTLAUNCH
			elif bounced:
				bounced = false
				nextState = BOUNCE
			else:
				nextState = RISING
		FALLING:
			if is_on_floor():
				nextState = LAND
			elif justHurt:
				nextState = HURTLAUNCH
			elif bounced:
				bounced = false
				nextState = BOUNCE
			else:
				nextState = FALLING
		LAND:
			if (finishedLanding):
				nextState = IDLE
				finishedLanding = false
			elif (inputJump):
				clearInputBuffer()
				nextState = JUMP
			elif bounced:
				bounced = false
				nextState = BOUNCE
			elif justHurt:
				nextState = HURTLAUNCH
			else:
				nextState = LAND
		HURTLAUNCH:
			nextState = HURTRISING
		HURTRISING:
#			if (animFinished) and (velocity.y <= 0):
#				nextState = FALLING
#			elif (animFinished) and (velocity.y > 0):
#				nextState = RISING
			if is_on_floor() and everyoneIsDead():
				nextState = CRASH
				spawnCoins()
				$crashTimer.start(3)
			elif bounced:
				bounced = false
				nextState = BOUNCE
			elif is_on_floor():
				nextState = LAND
			else:
				nextState = HURTRISING
		CRASH:
			nextState = CRASH
		_:
			pass
	if state != nextState:
		changedState = true
	else:
		changedState = false
	state = nextState
	# taking damage ---------------------------------------
	if isInState([HURTLAUNCH]):
		addHealth(-1 * damage * hurtDamageMulti)
		soundManager.playSound("hurt2")
		justHurt = false
	# resets animFinished if in looping animation state to prevent bugs
	if (isInState([IDLE, RISING, FALLING])):
		animFinished = false
	# Y movement -------------------------------------
	# gravity/wind
	if (forceWind == 0):
		velocity.y -= forceGrav * delta
	else:
		velocity.y -= forceGrav * delta * -1 * forceWind
	# caps y speed
	if (velocity.y >= 70):
		velocity.y = 70
	if (velocity.y <= -60):
		velocity.y = -60
	# launched
	if isInState([JUMP, BOUNCE]):
		velocity.y = forceJump
	if isInState([HURTLAUNCH]):
		velocity.y = forceHurtLaunch
	# X movement -----------------------------------------
	#{SPAWN, IDLE, JUMP, RISING, FALLING, BOUNCE, LAND, HURTLAUNCH, HURTRISING}
	if isInState([SPAWN]):
		velocity.x = 0
	elif isInState([IDLE, JUMP, BOUNCE, RISING, FALLING, LAND]):
		if (velocity.x == actMaxSpeed):
			pass
		elif (abs(velocity.x - actMaxSpeed) <= 1):
			velocity.x = actMaxSpeed
		elif (velocity.x >= actMaxSpeed):
			velocity.x -= forceRoll * delta
		else:
			velocity.x += forceRoll * delta
	elif isInState([HURTLAUNCH, HURTRISING]):
		#print("slow")
		velocity.x -= forceHurtX * delta
		if (velocity.x <= 0):
			velocity.x = 0
	# locks in XY plane
	translation.z = zPOS
	velocity.z = 0
	# prevent movment after going back to map via pause menu
	if get_parent().get_node("pauseScreen").loading:
		velocity = Vector3.ZERO
	# prevent movment if crashed
	if isInState([CRASH]):
		velocity = Vector3.ZERO
	# move and slide
	if isInState([JUMP, BOUNCE, RISING, HURTLAUNCH, HURTRISING]):
		snapVect = Vector3.ZERO
	else:
		snapVect = Vector3(0, -2, 0)
	if not hitStun:
		velocity.y = move_and_slide_with_snap(velocity, snapVect, Vector3.UP, true, 4, 1.05).y
	# gets angle
	if is_on_floor():
		var tempVect = get_floor_normal()
		if (tempVect.x >= 0): 
			desAngle = rad2deg(get_floor_angle(Vector3.UP))
		else:
			desAngle = -1 * rad2deg(get_floor_angle(Vector3.UP))
	elif isInState([JUMP, BOUNCE, RISING, HURTLAUNCH, HURTRISING]):
		desAngle = -20
	elif isInState([FALLING]):
		desAngle = 15
	
	# turns model
	actAngle += sign(desAngle - actAngle) + 0.2*(desAngle - actAngle)
	if (abs(desAngle -  actAngle) < 1):
		actAngle = desAngle
	#get_node("zeroPoint").set_rotation_degrees(Vector3(actAngle, 0, 0))
	set_rotation_degrees(Vector3(actAngle, 90, 0))
	# control system for max speed
	if is_on_floor():
		actMaxSpeed += (desMaxSpeed - actMaxSpeed) * speedFactor
		if (abs(desMaxSpeed - actMaxSpeed) < 1):
			actMaxSpeed = desMaxSpeed
		#print("vel: " + str(velocity.x) + " | actualMax: " + str(actMaxSpeed) + " | desiredMax: " + str(desMaxSpeed))
	# calculates height of floor below character for the camera
	if ($RayCast.is_colliding()):
		floorHeight = $RayCast.get_collision_point().y
	# spins wheels
	for wheel in wheels:
		wheel.rotate_x(deg2rad(velocity.x * 0.3))
	# characterSprite
	if changedState:
		match state: #SPAWN, IDLE, JUMP, RISING, FALLING, BOUNCE, LAND, HURTLAUNCH, HURTRISING, CRASH
			SPAWN:
				sprite.play(mainCharacter + "_idle")
				anim.play("idle")
			IDLE:
				sprite.play(mainCharacter + "_idle")
				anim.play("idle")
			JUMP:
				sprite.play(mainCharacter + "_rising")
				anim.play("jump")
			BOUNCE:
				sprite.play(mainCharacter + "_rising")
				anim.play("jump")
			RISING:
				sprite.play(mainCharacter + "_rising")
				#anim.play("jump")
			FALLING:
				sprite.play(mainCharacter + "_falling")
				anim.play("still")
			LAND:
				sprite.play(mainCharacter + "_landing")
				anim.play("land")
			HURTLAUNCH:
				sprite.play(mainCharacter + "_hurt")
				anim.play("still")
			HURTRISING:
				sprite.play(mainCharacter + "_hurt")
				anim.play("still")
			CRASH:
				sprite.play(mainCharacter + "_dead")
				anim.play("dead")
			_:
				sprite.play(mainCharacter + "_idle")
				anim.play("idle")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"land":
			finishedLanding = true	


func _on_hurtbox_area_entered(area):
	if area.is_in_group("death"):
		justHurt = true
		damage = 15
		tempInvincible = true
		get_node("invTimer").start(3)
		$effects.play("flash")
		translation = area.respawnLocation
		velocity.x = 0
		return
	if area.is_in_group("windboxes"):
		forceWind = area.magnitude
		return
	# pickups
	elif area.is_in_group("coins"):
		if isInState([CRASH]):
			return
		addCoins(area.get_parent().value)
		# makes visual effect
		var vfx = vfxScene.instance()
		get_parent().add_child(vfx)
		vfx.playEffect("coin", 0.5*(translation + area.get_parent().translation))
		# removes coin
		area.get_parent().queue_free()
		# plays sfx
		soundManager.pitchSound("coin1", rng.rand.randf_range(0.9, 1.2))
		soundManager.playSound("coin1")
		updateGUI()
		return
	elif area.is_in_group("healthSmall"):
		if isInState([CRASH]):
			return
		addHealth(0.10*hpMax)
		# makes visual effect
		var vfx = vfxScene.instance()
		get_parent().add_child(vfx)
		vfx.playEffect("health", 0.5*(translation + area.get_parent().translation))
		# removes item
		area.get_parent().queue_free()
		# plays sfx
		soundManager.playSound("pickup")
		updateGUI()
		return
	elif area.is_in_group("healthBig"):
		if isInState([CRASH]):
			return
		addHealth(0.5*hpMax)
		# makes visual effect
		var vfx = vfxScene.instance()
		get_parent().add_child(vfx)
		vfx.playEffect("health", 0.5*(translation + area.get_parent().translation))
		# removes item
		area.get_parent().queue_free()
		# plays sfx
		soundManager.playSound("pickup")
		updateGUI()
		return
	if not tempInvincible:
		justHurt = true
		damage = area.get_parent().get_parent().hitDamage
		tempInvincible = true
		get_node("invTimer").start(3)
		$effects.play("flash")
		var vfx = vfxScene.instance()
		get_parent().add_child(vfx)
		vfx.playEffect("hit", 0.5*(translation + area.get_parent().get_parent().translation + Vector3(0, 0, 1.5)))


func _on_invTimer_timeout():
	tempInvincible = false
	$effects.play("idle")
	updateGUI()


func _on_crashTimer_timeout():
	get_parent().get_node("minecartWarp")._on_minecartWarp_area_entered(null)


func _on_hitTimer_timeout():
	hitStun = false
