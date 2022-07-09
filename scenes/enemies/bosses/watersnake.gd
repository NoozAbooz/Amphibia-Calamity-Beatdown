extends Spatial

var cam = null
var cameraOffset = Vector3(0, 0, 15)
var cameraOffsetIntro = Vector3(0, 3, 0)
var vfxScene = preload("res://scenes/vfx.tscn")
var countDown = 180
var aggro = false
var defeated = false
var lookRight = false

export var bossMusic = "boss1"

var hitDamage = 0
var hitType = 0
var hitDir = Vector3.ZERO
export var hpMax = 300
var hp = 0
var invincible = false

enum {WAIT, INTROPREP, INTRO, IDLE, ENTERWATER, EXITWATER, MOVE, BITE, FLIPWARN, FLIP, DEAD, UNLOAD}
enum {KB_WEAK, KB_STRONG, KB_ANGLED, KB_AIR, KB_STRONG_RECOIL, KB_AIR_UP}
enum {LEFT, MIDLEFT, MIDRIGHT, RIGHT, PADLEFT, PADMID, PADRIGHT}

var state = WAIT
var nextState = WAIT
var arenaAnimFinished = false
var bossAnimFinished = false
var location = MIDLEFT

var padLCount = 0
var padMCount = 0
var padRCount = 0

onready var arenaAnim = $"ArenaAnimationPlayer"
onready var bossAnim  = $"BossAnimationPlayer"
onready var boss = $"boss"
onready var sprite = $"boss/sprite"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func setHitBox(attackDamage, type, dir):
	hitDamage = attackDamage
	hitType = type
	hitDir = dir # for direction, +x and +y means away and up. ~10 for magnitude
	if (lookRight == false):
		hitDir.x *= -1
		
func rollBite():
	if inRange() and (rng.rand.randf() <= 0.666):
		return BITE
	else:
		return ENTERWATER

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

func rollFlip():
	if (float(hp)/float(hpMax)) >= 0.8:
		if ((rng.rand.randf() <= 0.25)):
			return FLIPWARN
		else:
			return EXITWATER
	elif (float(hp)/float(hpMax)) >= 0.333:
		if ((rng.rand.randf() <= 0.35)):
			return FLIPWARN
		else:
			return EXITWATER
	else:
		if ((rng.rand.randf() <= 0.5)):
			return FLIPWARN
		else:
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

# animation controlled functions
func startCutscene():
	cam.startCutscene()
func endCutscene():
	cam.endCutscene()
func playAndShake():
	cam.shake(1)
	soundManager.playMusic(bossMusic)
	soundManager.playSound("roar")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# FSM
	match state:
		WAIT:
			location = MIDLEFT
			if aggro:
				nextState = INTRO
			else:
				nextState = WAIT
		INTRO:
			location = MIDLEFT
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLE
		IDLE:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = rollBite()
		ENTERWATER:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = MOVE
		EXITWATER:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLE
		MOVE:
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = rollFlip()
				if (nextState == FLIPWARN):
					location = rollLocationFlip()
				else:
					location = rollLocation()
		BITE: 
			setHitBox(10, KB_STRONG, Vector3(10, 20, 0))
			if bossAnimFinished:
				bossAnimFinished = false
				nextState = IDLE
		FLIPWARN:
			setHitBox(20, KB_ANGLED, Vector3(20, 50, 0))
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
		INTRO:
			bossAnim.play("intro")
			arenaAnim.play("intro")
		IDLE:
			bossAnim.play("idle")
		ENTERWATER:
			bossAnim.play("enter_water")
		EXITWATER:
			bossAnim.play("exit_water")
		MOVE:
			arenaAnim.play("idle")
			bossAnim.play("under_water")
		BITE: 
			bossAnim.play("bite")
		FLIPWARN:
			bossAnim.play("flip_warn")
			if (location == PADLEFT):
				arenaAnim.play("shakeL")
			elif (location == PADRIGHT):
				arenaAnim.play("shakeR")
			elif (location == PADMID):
				arenaAnim.play("shakeM")
		FLIP:
			bossAnim.play("flip")
			if (location == PADLEFT):
				arenaAnim.play("flipL")
			elif (location == PADRIGHT):
				arenaAnim.play("flipR")
			elif (location == PADMID):
				arenaAnim.play("flipM")
		DEAD:
			bossAnim.play("dead")
			arenaAnim.play("exit")
		UNLOAD:
			bossAnim.play("wait")
		_:
			bossAnim.play("wait")
			arenaAnim.play("wait")
			
			
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
			lookRight = true
		PADMID:
			boss.translation = Vector3(0, 0, 11)
			lookRight = true
		PADRIGHT:
			boss.translation = Vector3(11, 0, 0)
			lookRight = false
			
	# mirrors boss if necessary
	if (lookRight == false):
		sprite.set_rotation_degrees(Vector3(15, 0, 0))
		boss.set_rotation_degrees(Vector3(0, 180, 0))
	else:
		sprite.set_rotation_degrees(Vector3(-15, 0, 0))
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


func _on_playerCheckM_area_exited(area):
	padMCount -= 1


func _on_playerCheckL_area_entered(area):
	padLCount += 1


func _on_playerCheckL_area_exited(area):
	padLCount -= 1


func _on_playerCheckR_area_entered(area):
	padRCount += 1


func _on_playerCheckR_area_exited(area):
	padRCount -= 1
