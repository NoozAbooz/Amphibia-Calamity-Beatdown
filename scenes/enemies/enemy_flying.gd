extends KinematicBody

var vfxScene = preload("res://scenes/vfx.tscn")
var coinScene = preload("res://scenes/pickups/coin.tscn")
var khaoScene = preload("res://scenes/pickups/khao.tscn")
var mushScene = preload("res://scenes/pickups/mush.tscn")

export var speedWalk = 5
export var damage = 5
export var attackSpeed = 30

export var weakAttacker = false

export var printVals = false

export var maxCoins = 3
export var minCoins = 1
export var oddsDrop = 0.10 # 0.10
export var oddsKhao = 0.20 
export var broke = false
export var infEnemy = false #if true, enemy does not count towards kills. Used for spawners and summons
export var ambushEnemy = false

export var hp = 30

var velocity = Vector3.ZERO
var direction = Vector2.ZERO
var lookRight = false
var mini_jump_boost = 20
var force_grav = 125.0
var snapVect  = Vector3.ZERO

var hitDamage = 0
var hitType = 0
var hitDir = Vector3.ZERO

var justHurt = false
var invincible = false
var hurtAgain = false
var hurtDamage = 0
var hurtType = 0
var hurtDir = Vector3.ZERO
var invincibleState = false
var deathFloorHeight = -30

var target = null
var targetFound = false
var aggroReset = false
var walkTo = Vector3.ZERO
var targetOffset = 4
var attackWaitCounter = 0
var attackResetTime = 1.0
var attackOdds = 0.25
var attackEndCounter = 0
var attackEndResetTime = 0.3
var attackDirection = Vector3.ZERO
var fleeWaitCounter = 30
var fleeResetTime = 30
var floatHeight = 5

var enemyPush = Vector3.ZERO

var windVect = Vector3.ZERO

var swayTimer = 0
var swayDes = Vector3(1, 0, 0)
var rotationVector = Vector3(1, 0, 0)
var rotationCCW = false

enum {IDLE, WALK, HURT, HURTLAUNCH, HURTRISING, HURTFALLING, HURTFLOOR, ATTACKPREP, ATTACK, BLOCK, BLOCKHIT, KO, FLEE}
enum {KB_WEAK, KB_STRONG, KB_ANGLED, KB_AIR, KB_STRONG_RECOIL, KB_AIR_UP}
enum {LIGHT, HEAVY, VERYHEAVY}

export var weight = LIGHT

var state = IDLE
var nextState = IDLE

onready var anim = $"AnimationPlayer"
onready var sprite = $"zeroPoint/AnimatedSprite3D"
onready var ray = $"floatRay"
onready var rayLong = $"tooHighRay"
onready var zeroP = $"zeroPoint"

var animFinished = false

var onRightWall = false
var onLeftWall = false

func isInState(list):
	var found = false
	for i in list:
		if state == i:
			found = true
	return found

func setHitBox(attackDamage, type, dir):
	hitDamage = attackDamage
	hitType = type
	hitDir = dir # for direction, +x and +y means away and up. ~10 for magnitude
	if (lookRight == false):
		hitDir.x *= -1
		
func despawn():
	# Adds 1 to kill counter
	if (infEnemy == false):
		pg.killsTotal += 1
	if (ambushEnemy== true):
		pg.kills += 1
	# update drop counts/odds
	minCoins += (pg.luckUpgrades * pg.coinBoost)
	if (minCoins > maxCoins):
		minCoins = maxCoins
	oddsDrop += (pg.luckUpgrades * pg.dropBoost)
	#print(oddsDrop)
	queue_free()
	# spawns items/money
	if broke:
		return
	else:
		var coinsLeft = rng.rand.randi_range(minCoins, maxCoins)
		while (coinsLeft > 0):
			if (coinsLeft >= 20):
				var coins = coinScene.instance()
				get_parent().add_child(coins)
				coins.initialize(translation + zeroP.translation, 20)
				coinsLeft -= 20
			elif (coinsLeft >= 5):
				var coins = coinScene.instance()
				get_parent().add_child(coins)
				coins.initialize(translation + zeroP.translation, 5)
				coinsLeft -= 5
			else:
				var coins = coinScene.instance()
				get_parent().add_child(coins)
				coins.initialize(translation + zeroP.translation, 1)
				coinsLeft -= 1
#		for i in rng.rand.randi_range(minCoins, maxCoins):
#			var coins = coinScene.instance()
#			get_parent().add_child(coins)
#			coins.initialize(translation)
		if (rng.rand.randf() <= oddsDrop):
			var food = mushScene.instance()
			if (rng.rand.randf() <= oddsKhao):
				food = khaoScene.instance()
			get_parent().add_child(food)
			food.initialize(translation + zeroP.translation)

	
func checkIfAttack(targetPlayer):
	if (targetPlayer != null):
		if(rng.rand.randf() <= attackOdds):
			return true
		else:
			return false
			
func attackCounterReady():
	if (attackWaitCounter <= 0):
		attackWaitCounter = attackResetTime
		return true
	else:
		return false
		
func attackEndCounterReady():
	if (attackEndCounter <= 0):
		attackEndCounter = attackEndResetTime
		return true
	else:
		return false
		
func getAttackDirection(tempTarget):
	if (tempTarget == null):
		attackDirection = Vector3.ZERO
	else:
		attackDirection = tempTarget.translation - translation
		attackDirection = attackSpeed * attackDirection.normalized()
	return
		
func fleeCounterReady():
	if (fleeWaitCounter <= 0):
		fleeWaitCounter = fleeResetTime
		return true
	else:
		return false
		
func reduce(value, amount):
	if (abs(value) <= amount):
		value = 0
	elif value > 0:
		value -= amount
	else:
		value += amount
	return value

func _ready():
	if (rng.rand.randi() % 2):
		rotationCCW = true
	else:
		rotationCCW = false

#func initialize(loc, vel, spd, dam, hlth, wgt, maxC, minC, oddsD = 0.1, oddsK = 0.2, brk = false, weakA = false, infVision = false):
#	translation = loc
#	velocity = vel
#	speedWalk = spd
#	damage = dam
#	hp = hlth
#	weight = wgt
#	maxCoins = maxC
#	minCoins = minC
#	oddsDrop = oddsD
#	oddsKhao = oddsK
#	broke = brk
#	weakAttacker = weakA
#	if infVision:
#		#$aggro/CollisionShape.shape.radius = 100
#		targetFound = true
#		# picks a random target
#		target = rng.rand.randi_range(0, 3)
#		while (pg.playerAlive[target] == false):
#			target = rng.rand.randi_range(0, 3)
#		target = get_parent().get_node_or_null("Player" + str(target))

func initialize(type, loc, vel = Vector3.ZERO, brk = false, infVis = false, infEn = false):
	translation = loc
	velocity = vel
	broke = brk
	infEnemy = infEn
	speedWalk = type.spd
	damage = type.dam
	hp = type.hlth
	weight = type.wgt
	maxCoins = type.maxC
	minCoins = type.minC
	oddsDrop = type.oddsD
	oddsKhao = type.oddsK
	weakAttacker = type.weakA
	# automatically targets a random player instead of waiting for one to enter the aggro zone
	# use when spawning enemies on screen
	if infVis:
		get_node("aggro/CollisionShape").get_shape().radius = 100
		targetFound = true
		# picks a random target
		target = rng.rand.randi_range(0, 3)
		while (pg.playerAlive[target] == false):
			target = rng.rand.randi_range(0, 3)
		target = get_node_or_null("/root/" + pg.levelName + "/Player" + str(target))

func _physics_process(delta):
	
	# state changes
	match state:
		IDLE:
			if (targetFound) and (attackCounterReady()):
				nextState = WALK
			else:
				nextState = IDLE
		WALK:
			if (targetFound == false):
				nextState = IDLE
			elif attackCounterReady() and checkIfAttack(target):
				nextState = ATTACKPREP
			else:
				nextState = WALK
		HURT:
			if is_on_floor() == false:
				nextState = HURTFALLING
			elif (animFinished):
				animFinished = false
				nextState = FLEE
			else:
				nextState = HURT
		HURTLAUNCH:
			nextState = HURTRISING
		HURTRISING:
			if (velocity.y <= 0):
				nextState = HURTFALLING
			else:
				nextState = HURTRISING
		HURTFALLING:
			if is_on_floor():
				nextState = HURTFLOOR
			else:
				nextState = HURTFALLING
		HURTFLOOR:
			if (hp <= 0):
				nextState = KO
			elif is_on_floor() == false:
				nextState = HURTFALLING
			elif (animFinished):
				animFinished = false
				nextState = FLEE
			else:
				nextState = HURTFLOOR
		ATTACKPREP:
			if animFinished:
				getAttackDirection(target)
				nextState = ATTACK
				animFinished = false
			else:
				nextState = ATTACKPREP
		ATTACK:
			if is_on_floor() or attackEndCounterReady():
				nextState = FLEE
			else:
				nextState = ATTACK
#		BLOCK:
#			if (blockCounterReady()):
#				nextState = IDLE
#			else:
#				nextState = BLOCK
#		BLOCKHIT:
#			if (animFinished):
#				nextState = BLOCK
#				animFinished = false
#			else:
#				nextState = BLOCKHIT
		KO:
			nextState = KO
			if (animFinished):
				animFinished = false
				despawn()
		FLEE:
			if (fleeCounterReady()):
				nextState = IDLE
			else:
				nextState = FLEE
		_:
			state = IDLE
			nextState = IDLE
	# taking damage
	if (isInState([KO])):
		invincibleState = true
	else:
		invincibleState = false
	if (justHurt):
		justHurt = false
		#print("HIT")
		if isInState([BLOCK]):
			nextState = BLOCKHIT
			hurtDamage = 0
		elif isInState([BLOCKHIT]):
			hurtAgain = true
			nextState = BLOCKHIT
			hurtDamage = 0
		elif (weight == VERYHEAVY) and (hp >= 0):
			pass
		elif (hurtType == KB_STRONG) or (hurtType == KB_ANGLED):
			if (weight == LIGHT) or (hp <= 0):
				nextState = HURTLAUNCH
			elif isInState([HURT]):
				hurtAgain = true
				nextState = HURT
			else:
				nextState = HURT
		elif isInState([HURT]):
			hurtAgain = true
			nextState = HURT
		else:
			nextState = HURT
		hp -= hurtDamage
	state = nextState
	
	# resets animFinished if in looping animation state to prevent bugs
	if (isInState([IDLE, HURTFALLING, HURTRISING, BLOCK])):
		animFinished = false

	# attack counters
	attackWaitCounter -= delta
	if (isInState([ATTACK])):
		attackEndCounter -= delta
	else:
		attackEndCounter = attackEndResetTime
		
	# fleeing delay
	if (isInState([FLEE])):
		fleeWaitCounter -= rng.rand.randf()
	
	# turns on/off enemy only ground for walk off barriers
	if (isInState([WALK, IDLE])):
		set_collision_mask_bit(11, true)
	else:
		set_collision_mask_bit(11, false)
		
	# sets up hitbox
	if isInState([ATTACK]):
		if weakAttacker:
			setHitBox(damage, KB_WEAK, Vector3(10, 15, 0))
		else:
			setHitBox(damage, KB_STRONG, Vector3(10, 15, 0))
	
	# Y movement
	if (isInState([IDLE, WALK, FLEE])):
		if ray.is_colliding():
			velocity.y = 4
		elif rayLong.is_colliding() and (rayLong.get_collision_point() - translation).y < -6:
			velocity.y = -6 # lowers wasp if above ground and higher than 6 units above ground
		else:
			velocity.y = 0
	elif (isInState([ATTACKPREP])):
		velocity.y = 0
	elif (isInState([ATTACK])):
		velocity.y = attackDirection.y
	else:
		velocity.y -= force_grav * delta

	# XZ movement
	if isInState([WALK]):
		# determines where the enemy should walk to (which side of the player
		if (translation > target.translation):
			walkTo = target.translation + Vector3(targetOffset, 0, 0)
		else:
			walkTo = target.translation - Vector3(targetOffset, 0, 0)
		# sets direction
		direction.x = walkTo.x - translation.x
		direction.y = walkTo.z - translation.z
		# normalizes vector or sets to zero if at destination
		if (direction.length() < 0.2):
			direction = Vector2.ZERO
		else:
			direction = direction.normalized()
		# sets velocity
		velocity.x = speedWalk * direction.x
		velocity.z = speedWalk * direction.y
		# sets look direction
		if (target.translation.x  > translation.x):
			lookRight = true
		elif (target.translation.x  < translation.x):
			lookRight = false
	elif isInState([FLEE]):
		# sets direction
		if (target == null):
			direction.x = 0
			direction.y = 0
		else:
			direction.x = translation.x - target.translation.x
			direction.y = translation.z - target.translation.z 
			direction = direction.normalized()
		# sets velocity
		velocity.x = 1.5 * speedWalk * direction.x
		velocity.z = 1.5 * speedWalk * direction.y
		# sets look direction
		if (target != null):
			if (target.translation.x  > translation.x):
				lookRight = true
			elif (target.translation.x  < translation.x):
				lookRight = false
	elif isInState([ATTACK]):
		velocity.x = attackDirection.x
		velocity.z = attackDirection.z
	elif isInState([HURTLAUNCH, HURTRISING, HURTFALLING]):
		pass
	else:
		velocity.x = 0
		velocity.z = 0
	
	# knockback
	if isInState([HURTLAUNCH]):
		velocity.x = hurtDir.x
		velocity.y = hurtDir.y
		velocity.z = hurtDir.z
	
	# enemy pushback
	enemyPush = Vector3.ZERO
	for area in $enemyPushback.get_overlapping_areas():
		enemyPush.x += translation.x - area.get_parent().translation.x
		enemyPush.z += translation.z - area.get_parent().translation.z
	if (isInState([WALK])):
		enemyPush = 5*enemyPush.normalized()
	elif (isInState([ATTACKPREP, ATTACK])):
		enemyPush = Vector3.ZERO
	else:
		enemyPush = 2*enemyPush.normalized()
	velocity.x += enemyPush.x
	velocity.z += enemyPush.z
	
	# barrier pushback / bounceback
	if isInState([HURTLAUNCH, HURTRISING, HURTFALLING]):
		if onRightWall and (velocity.x > 0) and ambushEnemy:
			velocity = Vector3(-25, 15, 0)
		elif onLeftWall and (velocity.x < 0) and ambushEnemy:
			velocity = Vector3(25, 15, 0)
	else:
		if onRightWall and (velocity.x > 0) and ambushEnemy:
			velocity.x = 0
		elif onLeftWall and (velocity.x < 0) and ambushEnemy:
			velocity.x = 0
	
	# snapping setup
	if isInState([HURTLAUNCH, HURTRISING, IDLE, WALK, FLEE]):
		snapVect = Vector3.ZERO
	else:
		snapVect = Vector3(0, -5, 0)
	# move and slide
	move_and_slide(windVect, Vector3.UP, true)
	velocity = move_and_slide_with_snap(velocity, snapVect, Vector3.UP, true)
	
	# mirror enemy if necessary
	if (lookRight == true):
		sprite.set_rotation_degrees(Vector3(-15, 90, 0))
		zeroP.set_rotation_degrees(Vector3(0, 180, 0))
	else:
		sprite.set_rotation_degrees(Vector3(15, 90, 0))
		zeroP.set_rotation_degrees(Vector3(0, 0, 0))
	
	# adds sway to movement
	swayTimer += delta
	if (swayTimer >= 120):
		#resets timer and sets new desired position for the sway position
		swayTimer = rng.rand.randi_range(0, 80)
		if (rotationVector == Vector3(1, 0, 0)):
			rotationVector = Vector3(0, 0, 1)
		else:
			rotationVector = Vector3(1, 0, 0)
	# y axis roataion
	if rotationCCW:
		swayDes = swayDes.rotated(Vector3(0, 1, 0), rng.rand.randf() * 0.2)
	else:
		swayDes = swayDes.rotated(Vector3(0, 1, 0), rng.rand.randf() * -0.2)
	# other axis rotation
	swayDes = swayDes.rotated(rotationVector, rng.rand.randf()*0.2)
	# "sways" the enemy is in a certain state
	if isInState([IDLE, WALK, FLEE]):
		zeroP.translation += 0.1 * (swayDes - zeroP.translation)
	# Moves other nodes to match zero point (putting them as children would mess up other scripts)
	$"CollisionShapeGround".translation = zeroP.translation + Vector3(0.22, 1.2, 0)
	$"enemyPushback".translation = zeroP.translation
	
	# animations
	if isInState([IDLE, WALK, FLEE]):
		anim.play("idle")
	elif isInState([HURT]):
		anim.play("hurt")
		if (hurtAgain):
			hurtAgain = false
			anim.seek(0)
	elif isInState([HURTRISING, HURTFALLING]):
		anim.play("hurt_air")
	elif isInState([HURTFLOOR]):
		anim.play("hurt_floor")
#	elif isInState([BLOCK]):
#		anim.play("block")
#	elif isInState([BLOCKHIT]):
#		anim.play("block_hit")
#		if (hurtAgain):
#			hurtAgain = false
#			anim.seek(0)
	elif isInState([ATTACKPREP]):
		anim.play("attack_prep")
	elif isInState([ATTACK]):
		anim.play("attack")
	elif isInState([KO]):
		anim.play("dead")
	
	# fall off world
	if (translation.y <= deathFloorHeight):
		despawn()
	
	# waits for a cycle before turning aggro box back on
	if (aggroReset):
		aggroReset = false
		get_node("aggro/CollisionShape").disabled = false
	if (get_node("aggro/CollisionShape").disabled == true):
		aggroReset = true
	
	# labels/prints for testing
	if (printVals == true) and (target != null):
		$Label.text = str(state) + "\n" + str(hp) + "\n" + str(targetFound) + "\n" + str(target.translation)
	elif (printVals == true):
		$Label.text = str(state) + "\n" + str(hp) + "\n" + str(targetFound) + "\n"


func _on_AnimationPlayer_animation_finished(_anim_name):
	animFinished = true
	# note: only applies nor non-looping animations

func _on_hurtbox_area_entered(area):
	# one way barriers for ambushes
	if area.is_in_group("oneWayRight"):
		onLeftWall = true
		return
	elif area.is_in_group("oneWayLeft"):
		onRightWall = true
		return
	# environmental stuff
	elif area.is_in_group("windboxes"):
		windVect = area.direction.normalized() * area.magnitude
		return
	# identifies attacker
	var attacker = area.get_parent().get_parent()
	# returns if in an invincible state (just got hit)
	if (invincible == false) and (invincibleState == false):
		justHurt = true
	else:
		return
	# makes enemy unhittable until it leaves a hitbox
	invincible = true
	# Produces hit vfx
	var vfx = vfxScene.instance()
	get_parent().add_child(vfx)
	vfx.playEffect("hit", 0.5*(translation + attacker.translation))
	# sets attacker as the target
	target = attacker
	# stores damage/knockback variables
	hurtDamage = attacker.hitDamage
	hurtType = attacker.hitType
	hurtDir = attacker.hitDir
	# tells attacker that the hit occurred
	attacker.hitLanded = true
	# changes knockback values depending on the type and situation (type should end up as either weak or strong):
	# changes x-z knokback angle to be away from player if an angled attack
	if (hurtType == KB_ANGLED):
		var mag = abs(attacker.hitDir.x)
		var ve = Vector2(translation.x, translation.z)
		var vp = Vector2(attacker.translation.x, attacker.translation.z)
		var newDir = Vector2.ZERO
		newDir = ve - vp
		newDir = newDir.normalized() * mag
		hurtDir.x = newDir.x
		hurtDir.z = newDir.y
	# changes attack type to weak if hit with air attack while grounded (and attacker is not rising)
	elif (hurtType == KB_AIR) and (is_on_floor() and (attacker.velocity.y <= 0)):
		hurtType = KB_WEAK
	# changes attack type to strong and sets knock back equal to player movement if hit with air attack in mid air or rising attack while grounded
	elif (hurtType == KB_AIR):
		hurtType = KB_STRONG
		# adds an additional boost if player is falling
		if attacker.velocity.y <= mini_jump_boost:
			hurtDir = Vector3(attacker.velocity.x, mini_jump_boost, attacker.velocity.z)
			attacker.mini_jump_boost = mini_jump_boost # caused player to get velocity boost too
		else:
			hurtDir = attacker.velocity
	# changes attack type to strong and signals attacker if hit with a move that has knockback
	elif (hurtType == KB_STRONG_RECOIL):
		hurtType = KB_STRONG
		attacker.recoilStart = true
	# changes attack type to strong and signals attacker if hit with a move that has knockback	
	elif (hurtType == KB_AIR_UP):
		hurtType = KB_STRONG
		hurtDir = Vector3(attacker.velocity.x, hurtDir.y, attacker.velocity.z)
	if (hurtType == KB_WEAK) and (hp <= 0):
		hurtType = KB_ANGLED
		hurtDir = Vector3(hurtDir.x * 10, 30, 0)
	# makes enemy look at attacker
	if (attacker.translation.x > translation.x):
		lookRight = true
	else:
		lookRight = false
	# plays sfx
	soundManager.playSound(attacker.hitSound)
		
func _on_hurtbox_area_exited(area):
	if area.is_in_group("oneWayRight"):
		onLeftWall = false
		return
	elif area.is_in_group("oneWayLeft"):
		onRightWall = false
		return
	elif area.is_in_group("windboxes"):
		windVect = Vector3.ZERO
		return
	else:
		invincible = false


func _on_aggro_area_entered(area):
	if (targetFound == false):
		target = area.get_parent().get_parent()
		targetFound = true

func _on_aggro_area_exited(area):
	if (area.get_parent().get_parent() == target):
		targetFound = false
		target = null
		get_node("aggro/CollisionShape").disabled = true

