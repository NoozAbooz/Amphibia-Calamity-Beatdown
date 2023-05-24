#===============================================================
#MOTH
#===============================================================

extends Spatial

var cam = null
var cameraOffset = Vector3(0, 5, 25)
var cameraOffsetIntro = Vector3(0, -8, -8)
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

var state = WAIT
var nextState = WAIT
var phase = 0
var bossAnimFinished = false

var minionCount = 0

var followingAnimSetpoint = [true, true, true, true] # [X, Y, Z, Rot]

var bossCodePosSetpoint = Vector3.ZERO
var bossCodeRotSetpoint = Vector3.ZERO
var POSkp = 0.1
var ROTkp = 0.2

onready var bossAnim = $"bossAnimationPlayer"
onready var mainAnim  = $"mainAnimationPlayer"
onready var modelAnim = $"boss/model/AnimationPlayer"
onready var boss = $"boss"
onready var model = $"boss/model"
onready var bossAnimSetpoint = $"bossPositionSetpoint"

func setHitBox(attackDamage, type, dir):
	hitDamage = attackDamage
	hitType = type
	hitDir = dir # for direction, +x and +y means away and up. ~10 for magnitude
	if (lookRight == false):
		hitDir.x *= -1
		
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

func findPhase():
	if (float(hp)/float(hpMax)) >= 0.75:
		return 0
	elif (float(hp)/float(hpMax)) >= 0.33:
		return 1
	else:
		return 2
		
func isInState(list):
	var found = false
	for i in list:
		if state == i:
			found = true
	return found

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
func _process(delta):
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
				nextState = IDLE
		IDLE:
			if bossAnimFinished:
				bossAnimFinished = false
			nextState = IDLE
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
#				nextState = rollAttackWater()
#				if (nextState == FLIPWARN):
#					location = rollLocationFlip()
#				elif (nextState == SWEEP):
#					location = MIDRIGHT
#				else:
#					location = rollLocation()
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
#			if checkForRespawningPlayer():
#				nextState = MOVE
#			if bossAnimFinished:
#				bossAnimFinished = false
#				nextState = FLIP
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
			mainAnim.play("wait")
			modelAnim.play("idle")
			# handle model animations through boss animation player?
		INTRO:
			bossAnim.play("intro")
		IDLE:
			bossAnim.play("idle")
		ENTERWATER:
			bossAnim.play("enter_water")
		EXITWATER:
			bossAnim.play("exit_water")
		MOVE:
			bossAnim.play("under_water")
		BITE: 
			bossAnim.play("bite")
		JUMP: 
			bossAnim.play("jump")
		SWEEP: 
			bossAnim.play("sweep")
		FLIPWARN:
			bossAnim.play("flip_warn")
		FLIP:
			bossAnim.play("flip")
		DEAD:
			bossAnim.play("dead")
		UNLOAD:
			bossAnim.play("wait")
		_:
			bossAnim.play("wait")
	
	# sets code positions/rotation
	match state:
		IDLE:
			followingAnimSetpoint = [true, true, true, true]
			bossCodePosSetpoint = Vector3(0, -50, 0)
			bossCodeRotSetpoint = Vector3(0, 0, 0)
		INTRO:
			followingAnimSetpoint = [true, true, true, true]
		_:
			followingAnimSetpoint = [false, false, false, false]
			bossCodePosSetpoint = Vector3(0, -50, 0)
			bossCodeRotSetpoint = Vector3(0, 0, 0)
	# positioning via animations
	if followingAnimSetpoint[0]: #X pos
		boss.translation.x += POSkp * (bossAnimSetpoint.translation.x - boss.translation.x)
	else:
		boss.translation.x += POSkp * (bossCodePosSetpoint.x - boss.translation.x)
	if followingAnimSetpoint[1]: #Y pos
		boss.translation.y += POSkp * (bossAnimSetpoint.translation.y - boss.translation.y)
	else:
		boss.translation.y += POSkp* (bossCodePosSetpoint.y - boss.translation.y)
	if followingAnimSetpoint[2]: #Z pos
		boss.translation.z += POSkp * (bossAnimSetpoint.translation.z - boss.translation.z)
	else:
		boss.translation.z += POSkp * (bossCodePosSetpoint.z - boss.translation.z)
	if followingAnimSetpoint[3]: #rotation
		boss.rotation_degrees.x += ROTkp * (bossAnimSetpoint.rotation_degrees.x - boss.rotation_degrees.x)
		boss.rotation_degrees.y += ROTkp * (bossAnimSetpoint.rotation_degrees.y - boss.rotation_degrees.y)
		boss.rotation_degrees.z += ROTkp * (bossAnimSetpoint.rotation_degrees.z - boss.rotation_degrees.z)
	else:
		boss.rotation_degrees.x += ROTkp * (bossCodeRotSetpoint.x - boss.rotation_degrees.x)
		boss.rotation_degrees.y += ROTkp * (bossCodeRotSetpoint.y - boss.rotation_degrees.y)
		boss.rotation_degrees.z += ROTkp * (bossCodeRotSetpoint.z - boss.rotation_degrees.z)



	# test prints
	#print("L: " + str(padLCount) + "   M: " + str(padMCount) + "   R: " + str(padRCount))
	#print(str(state))

	# health bar
	$"info/lifeBar".value = hp #* float(hp/hpMax)
	
	# makes cam follow boss durring "cutscene" moments
	if isInState([INTRO]):
		cam.cutsceneTarget = translation + boss.translation + cameraOffsetIntro

	# handles death:
	if (hp <= 0) and (not defeated):
		soundManager.FadeOutSong(bossMusic)
		nextState = DEAD
		state = DEAD
		defeated = true
		cam.cutsceneTarget = translation + boss.translation + Vector3(0, 2, -2)

	#sets boss phase
	phase = findPhase()


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



func _on_mainAnimationPlayer_animation_finished(anim_name):
	pass # Replace with function body.


func _on_bossAnimationPlayer_animation_finished(anim_name):
	bossAnimFinished = true
