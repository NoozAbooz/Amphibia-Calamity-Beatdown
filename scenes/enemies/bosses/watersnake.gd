extends Spatial

var cam = null
var cameraOffset = Vector3(0, 0, 15)
var cameraOffsetIntro = Vector3(0, 1, 7)
var vfxScene = preload("res://scenes/vfx.tscn")
var countDown = 180
var aggro = false
var defeated = false
var lookRight = false

export var bossMusic = "boss1"

var hitDamage = 0
var hitType = 0
var hitDir = Vector3.ZERO
export var hpMax = 350
var hp = 0
var invincible = false

enum {WAIT, INTROPREP, INTRO, IDLE, ENTERWATER, EXITWATER, MOVE, BITE, FLIPWARN, FLIP, DEAD, UNLOAD, SWEEP, JUMP}
enum {KB_WEAK, KB_STRONG, KB_ANGLED, KB_AIR, KB_STRONG_RECOIL, KB_AIR_UP, KB_WEAK_PIERCE, KB_STRONG_PIERCE, KB_ANGLED_PIERCE}
enum {LEFT, MIDLEFT, MIDRIGHT, RIGHT, PADLEFT, PADMID, PADRIGHT}

var state = WAIT
var nextState = WAIT
var phase = 0
var arenaAnimFinished = false
var bossAnimFinished = false
var location = MIDLEFT
var biteCount = 0
var safeAttackCount = 0

var padLCount = 0
var padMCount = 0
var padRCount = 0
var padMPlayers = []

onready var arenaAnim = $"ArenaAnimationPlayer"
onready var bossAnim  = $"BossAnimationPlayer"
onready var modelAnim = $"boss/model/snakeAnimated/AnimationPlayer"
onready var boss = $"boss"
onready var model = $"boss/model"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func setHitBox(attackDamage, type, dir):
	hitDamage = attackDamage
	hitType = type
	hitDir = dir # for direction, +x and +y means away and up. ~10 for magnitude
	if (lookRight == false):
		hitDir.x *= -1
		
func rollAttackPad():
	if not inRange():
		return ENTERWATER
	elif (biteCount >= 2):
		return JUMP
	match phase:
		0:
			if (rng.rand.randf() <= 0.666):
				return BITE
		1: 
			if (rng.rand.randf() <= 0.5):
				return BITE
			elif (rng.rand.randf() <= 0.5):
				return JUMP
		2:
			if (rng.rand.randf() <= 0.4):
				return BITE
			else:
				return JUMP
		_:
			return ENTERWATER
	return ENTERWATER

func checkForRespawningPlayer():
	if (padMCount <= 0):
		return false
	for player in padMPlayers:
		if player.isInState([player.HURTRISING, player.HURTFALLING, player.HURTFLOOR, player.KO]):
			return true
	return false

func rollLocation():
	if (padMCount > 0):
		if ((rng.rand.randf() <= 0.5)):
			return LEFT
		else:
			return RIGHT
	elif (padLCount > 0) and (padRCount > 0):
		if ((rng.rand.randf() <= 0.5)):
			return MIDLEFT
		else:
			return MIDRIGHT
	elif (padLCount > 0):
		return MIDLEFT
	else:
		return MIDRIGHT
		
func rollLocationFlip():
	if (padLCount > 0):
		return PADLEFT
	elif (padRCount > 0):
		return PADRIGHT
	else:
		return PADMID
		
func findPhase():
	if (float(hp)/float(hpMax)) >= 0.75:
		return 0
	elif (float(hp)/float(hpMax)) >= 0.33:
		return 1
	else:
		return 2

func rollAttackWater():
	#print(safeAttackCount)
	if (safeAttackCount >= 2):
		safeAttackCount = 0
		return EXITWATER
	match phase:
		0:
			if ((rng.rand.randf() <= 0.25)):
				safeAttackCount += 1
				return FLIPWARN
		1:
			if ((rng.rand.randf() <= 0.35)):
				if ((rng.rand.randf() <= 0.3)):
					safeAttackCount += 1
					return FLIPWARN
				else:
					safeAttackCount += 1
					return SWEEP
		2:
			if ((rng.rand.randf() <= 0.4)):
				if ((rng.rand.randf() <= 0.5)):
					safeAttackCount += 1
					return FLIPWARN
				else:
					safeAttackCount += 1
					return SWEEP
		_:
			safeAttackCount = 0
			return EXITWATER
	safeAttackCount = 0
	return EXITWATER

func inRange():
	if ((location == LEFT) or (location == RIGHT)) and (padMCount > 0):
		return true
	elif (location == MIDLEFT) and (padLCount > 0):
		return true
	elif (location == MIDRIGHT) and (padRCount > 0):
		return true
	else:
		return false

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
func _process(delta):
	# FSM
	match state:
		WAIT:
			location = MIDRIGHT
			if aggro:
				nextState = INTRO
			else:
				nextState = WAIT
		INTRO:
			location = MIDRIGHT
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = MOVE
		IDLE:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = rollAttackPad()
				if (nextState == BITE):
					biteCount += 1
				else:
					biteCount = 0
		ENTERWATER:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = MOVE
		EXITWATER:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLE
		MOVE:
			boss.set_rotation_degrees(Vector3(0, 180, 0))
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = rollAttackWater()
				if (nextState == FLIPWARN):
					location = rollLocationFlip()
				elif (nextState == SWEEP):
					location = MIDRIGHT
				else:
					location = rollLocation()
		BITE: 
			setHitBox(5, KB_WEAK, Vector3(0, 0, 0))
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLE
		SWEEP: 
			setHitBox(15, KB_ANGLED_PIERCE, Vector3(5, 30, 0))
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = MOVE
		JUMP: 
			setHitBox(15, KB_ANGLED_PIERCE, Vector3(20, 15, 0))
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = MOVE
		FLIPWARN:
			setHitBox(10, KB_ANGLED, Vector3(20, 50, 0))
			if checkForRespawningPlayer():
				nextState = MOVE
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = FLIP
		FLIP:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = MOVE
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
	state = nextState
	
	# plays animations
	match state:
		WAIT:
			bossAnim.play("wait")
			arenaAnim.play("wait")
			modelAnim.play("under_water")
		INTRO:
			bossAnim.play("intro")
			arenaAnim.play("intro")
			modelAnim.play("intro")
		IDLE:
			bossAnim.play("idle")
			modelAnim.play("idle")
		ENTERWATER:
			bossAnim.play("enter_water")
			modelAnim.play("enter_water")
		EXITWATER:
			bossAnim.play("exit_water")
			modelAnim.play("exit_water")
		MOVE:
			arenaAnim.play("idle")
			bossAnim.play("under_water")
			modelAnim.play("under_water")
		BITE: 
			bossAnim.play("bite")
			modelAnim.play("bite")
		JUMP: 
			bossAnim.play("jump")
			modelAnim.play("jump")
		SWEEP: 
			bossAnim.play("sweep")
			modelAnim.play("sweep")
		FLIPWARN:
			bossAnim.play("flip_warn")
			modelAnim.play("under_water")
			if (location == PADLEFT):
				arenaAnim.play("shakeL")
			elif (location == PADRIGHT):
				arenaAnim.play("shakeR")
			elif (location == PADMID):
				arenaAnim.play("shakeM")
		FLIP:
			bossAnim.play("flip")
			modelAnim.play("flip")
			if (location == PADLEFT):
				arenaAnim.play("flipL")
			elif (location == PADRIGHT):
				arenaAnim.play("flipR")
			elif (location == PADMID):
				arenaAnim.play("flipM")
		DEAD:
			bossAnim.play("dead")
			arenaAnim.play("exit")
			modelAnim.play("dead")
		UNLOAD:
			bossAnim.play("wait")
			modelAnim.play("under_water")
		_:
			bossAnim.play("wait")
			arenaAnim.play("wait")
			modelAnim.play("under_water")
			
			
	# positions the boss based on location variable
	match location:
		LEFT:
			boss.translation = Vector3(-11, 0, 11)
			lookRight = true
		MIDLEFT:
			boss.translation = Vector3(0, 0, 0)
			lookRight = false
		MIDRIGHT:
			boss.translation = Vector3(0, 0, 0)
			lookRight = true
		RIGHT:
			boss.translation = Vector3(11, 0, 11)
			lookRight = false
		PADLEFT:
			boss.translation = Vector3(-11, 0, 0)
			lookRight = false
		PADMID:
			boss.translation = Vector3(0, 0, 11)
			lookRight = false
		PADRIGHT:
			boss.translation = Vector3(11, 0, 0)
			lookRight = false
			
	# positions/mirrors boss if necessary
	if (state == SWEEP) or (state == INTRO):
		boss.set_rotation_degrees(Vector3(0, -90, 0))
	elif (lookRight == false):
		boss.set_rotation_degrees(Vector3(0, 180, 0))
	else:
		boss.set_rotation_degrees(Vector3(0, 0, 0))
		
	
		
	# test prints
	#print("L: " + str(padLCount) + "   M: " + str(padMCount) + "   R: " + str(padRCount))
	#print(str(state))
	
	# health bar
	$"info/lifeBar".value = hp #* float(hp/hpMax)
	
	# handles death:
	if (hp <= 0) and (not defeated):
		soundManager.FadeOutSong(bossMusic)
		nextState = DEAD
		state = DEAD
		defeated = true
		cam.cutsceneTarget = translation + cameraOffsetIntro + boss.translation + Vector3(0, 2, -2)
		
	#sets boss phase
	phase = findPhase()


func _on_cameraTrigger_area_entered(area):
	# Camera positioning
	cam = area.get_parent()
	cam.inAmbush = true
	cam.ambushTarget = translation + cameraOffset
	cam.cutsceneTarget = translation + cameraOffsetIntro
	cam.ambushSpawnPoint = translation + Vector3(0, 5, 9)
	get_node("cameraTrigger").queue_free()
	aggro = true

func unloadBoss():
	# Frees camera
	cam.inAmbush = false
	# makes visual effect
	var vfx = vfxScene.instance()
	get_parent().add_child(vfx)
	vfx.playEffect("go_arrow")
	# sets beaten flag
	defeated = true
	#re-plays level music
	soundManager.playMusic(pg.levelMusic)


func _on_ArenaAnimationPlayer_animation_finished(anim_name):
	if (anim_name == "exit"):
		arenaAnim.play("wait")

func _on_BossAnimationPlayer_animation_finished(anim_name):
	bossAnimFinished = true

func _on_hurtbox_area_entered(area):
	# identifies attacker
	var attacker = area.get_parent().get_parent()
	# returns if in an invincible state (just got hit)
	if (invincible == true):
		return
	# makes enemy unhittable until it leaves a hitbox
	invincible = true
	# Produces hit vfx
	var vfx = vfxScene.instance()
	get_parent().add_child(vfx)
	vfx.playEffect("hit", 0.5*($"boss".translation + translation + attacker.translation))
	# sdeals damage
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


func _on_playerCheckM_area_entered(area):
	padMCount += 1
	padMPlayers.append(area.get_parent().get_parent())

func _on_playerCheckM_area_exited(area):
	padMCount -= 1
	padMPlayers.erase(area.get_parent().get_parent())


func _on_playerCheckL_area_entered(area):
	padLCount += 1


func _on_playerCheckL_area_exited(area):
	padLCount -= 1


func _on_playerCheckR_area_entered(area):
	padRCount += 1


func _on_playerCheckR_area_exited(area):
	padRCount -= 1
