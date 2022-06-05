extends StaticBody

var vfxScene = preload("res://scenes/vfx.tscn")
var coinScene = preload("res://scenes/pickups/coin.tscn")
var khaoScene = preload("res://scenes/pickups/khao.tscn")
var mushScene = preload("res://scenes/pickups/mush.tscn")

onready var animDamage = $AnimationPlayerDamage
onready var animSpawn = $AnimationPlayerSpawn

var active = false
var counterSpawn = false # a flag that checks if the nest has been hit. Nests will spawn at the next opportunuty if this is true.
var invincible = false
var dead = false
export var decoration = false
var hp = 150
export var oddsSpawn = 0.2

export var maxCoins = 20
export var minCoins = 15
export var oddsDrop = 1.0 
export var oddsKhao = 0.20 

func spawn():
	var num = rng.rand.randi_range(1, 3)
	for i in range(0, rng.rand.randi_range(1, 3)):
		var nextEnemy = nme.spiderScene.instance()
		get_parent().add_child(nextEnemy)
		nextEnemy.initialize(nme.spider, translation + Vector3(rng.rand.randf_range(-2, 2), 3, rng.rand.randf_range(-2, 2)), Vector3(0, 25, 0), true, true, true)

func spawnMore():
	for i in range(0, 5):
		var nextEnemy = nme.spiderScene.instance()
		get_parent().add_child(nextEnemy)
		nextEnemy.initialize(nme.spider, translation + Vector3(rng.rand.randf_range(-2, 2), 3, rng.rand.randf_range(-2, 2)), Vector3(0, 40, 0), false, true, false)
	
func despawn():
	# update drop counts/odds
	minCoins += (pg.luckUpgrades * pg.coinBoost)
	maxCoins += (pg.luckUpgrades * pg.coinBoost)
	oddsDrop += (pg.luckUpgrades * pg.dropBoost)
	#print(oddsDrop)
	queue_free()
	# spawns items/money
	var coinsLeft = rng.rand.randi_range(minCoins, maxCoins)
	while (coinsLeft > 0):
		if (coinsLeft >= 20):
			var coins = coinScene.instance()
			get_parent().add_child(coins)
			coins.initialize(translation + Vector3(0, 3, 0), 20)
			coinsLeft -= 20
		elif (coinsLeft >= 5):
			var coins = coinScene.instance()
			get_parent().add_child(coins)
			coins.initialize(translation + Vector3(0, 3, 0), 5)
			coinsLeft -= 5
		else:
			var coins = coinScene.instance()
			get_parent().add_child(coins)
			coins.initialize(translation + Vector3(0, 3, 0), 1)
			coinsLeft -= 1
	var food = null
	if (rng.rand.randf() <= oddsDrop):
		food = mushScene.instance()
		if (rng.rand.randf() <= oddsKhao):
			food = khaoScene.instance()
		get_parent().add_child(food)
		food.initialize(translation + Vector3(0, 3, 0))
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_hurtbox_area_entered(area):
	if invincible or dead or decoration:
		return
	# identifies attacker
	var attacker = area.get_parent().get_parent()
	# stores damage/knockback variables
	hp -= attacker.hitDamage
	# tells attacker that the hit occurred
	attacker.hitLanded = true
	# signals attacker to recoil if necessary
	if (attacker.hitType == attacker.KB_STRONG_RECOIL):
		attacker.recoilStart = true
	# plays animation
	if (hp > 0):
		animDamage.play("hurt")
	else:
		animDamage.play("dead")
	# plays sfx
	soundManager.playSound(attacker.hitSound)
	# makes enemy unhittable until it leaves a hitbox
	invincible = true
	# Produces hit vfx
	var vfx = vfxScene.instance()
	get_parent().add_child(vfx)
	vfx.playEffect("hit", 0.5*(translation + attacker.translation))
	# prepares a counterattack
	counterSpawn = true


func _on_hurtbox_area_exited(_area):
	invincible = false


func _on_AnimationPlayerDamage_animation_finished(anim_name):
	match anim_name:
		"hurt":
			animDamage.play("idle")
		"dead":
			spawnMore()
			despawn()


func _on_spawnDelay_timeout():
	if active:
		spawn()


func _on_aggro_area_entered(area):
	active = true
	$aggro.queue_free()


func _on_AnimationPlayerSpawn_animation_finished(anim_name):
	match anim_name:
		"idle":
			if (rng.rand.randf() < oddsSpawn) or counterSpawn:
				$spawnTimer.start()
				animSpawn.play("spawn")
			else:
				animSpawn.play("idle")
		"spawn":
			counterSpawn = false
			animSpawn.play("idle")
