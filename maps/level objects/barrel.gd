extends KinematicBody

onready var anim = get_node("AnimationPlayer")
var vfxScene = preload("res://scenes/vfx.tscn")
var coinScene = preload("res://scenes/pickups/coin.tscn")
var khaoScene = preload("res://scenes/pickups/khao.tscn")
var mushScene = preload("res://scenes/pickups/mush.tscn")
var debrisScene = preload("res://scenes/enemies/spawners/debris.tscn")
export var hp = 3
var randChoice = 0

var velocity = Vector3.ZERO
var force_grav = 125.0

export var randomContents = true
export var coppers = 0
export var silverCoins = 0
export var goldCoins = 0
export var foods = 0
export var bigFoods = 0
export var spiders = 0
export var wasps = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector3.ZERO
	anim.play("idle")
	if (randomContents):
		shuffleDrops(pg.luckUpgrades)
		
func _process(delta):
	velocity.x = 0
	velocity.z = 0
	if (!is_on_floor()):
		velocity.y -= force_grav * delta
		velocity = move_and_slide(velocity, Vector3.UP, true)
	
func shuffleDrops(luck):
	# zeros out options first
	coppers = 0
	silverCoins = 0
	goldCoins = 0
	foods = 0
	bigFoods = 0
	spiders = 0
	wasps = 0
	# picks contents randomly and boost based on player luck
	randChoice = rng.rand.randi_range(1, 15) + luck
	match randChoice:
		1:
			wasps = 2
		2:
			spiders = 2
		3:
			spiders = 1
			wasps = 1
		4:
			spiders = 1
			coppers = 3
		5:
			wasps = 1
			coppers = 3
		6:
			coppers = 1
		7:
			coppers = 1
		8:
			coppers = 3
		9:
			coppers = 3
		10:
			coppers = 3
		12:
			coppers = 3
			foods = 1
		13:
			coppers = 3
			foods = 1
		14:
			coppers = 5
			foods = 1
		15:
			foods = 2
			coppers = 5
		16:
			coppers = 35
		17:
			bigFoods = 1
		18:
			bigFoods = 1
			goldCoins = 1
		_:
			pass

func dead():
	# spawns coins
	for i in range(0, coppers):
		var coins = coinScene.instance()
		get_parent().add_child(coins)
		coins.initialize(translation + Vector3(0, 1, 0), 1)
	for i in range(0, silverCoins):
		var coins = coinScene.instance()
		get_parent().add_child(coins)
		coins.initialize(translation + Vector3(0, 1, 0), 5)
	for i in range(0, goldCoins):
		var coins = coinScene.instance()
		get_parent().add_child(coins)
		coins.initialize(translation + Vector3(0, 1, 0), 20)
	# spawns food
	for i in range(0, foods):
		var food = mushScene.instance()
		get_parent().add_child(food)
		food.initialize(translation + Vector3(0, 1, 0))
	for i in range(0, bigFoods):
		var food = khaoScene.instance()
		get_parent().add_child(food)
		food.initialize(translation + Vector3(0, 1, 0))
	# spawns wasps
	for i in range(0, wasps):
		var nextEnemy = nme.waspScene.instance()
		get_parent().add_child(nextEnemy)
		nextEnemy.initialize(nme.wasp, translation + Vector3(0, 1, 0), Vector3.ZERO, true, true, true)
	# spawns spiders
	for i in range(0, spiders):
		var nextEnemy = nme.spiderScene.instance()
		get_parent().add_child(nextEnemy)
		nextEnemy.initialize(nme.spider, translation + Vector3(0, 1, 0), Vector3(rng.rand.randf_range(-10, 10), 25, rng.rand.randf_range(-10, 10)), true, true, true)
		nextEnemy.hp = 0
	# spawns debris
	spawnMushrooms()
	soundManager.playSound("hit4")
	queue_free()

func spawnMushrooms():
	# spawns debris
	var debris = null
	# makes one each mushroom
	for i in range (6, 9):
		debris = debrisScene.instance()
		get_parent().add_child(debris)
		debris.initialize(translation + Vector3(0, -1, 0), i)
	# makes wood shards
	for i in range (0, 2):
		debris = debrisScene.instance()
		get_parent().add_child(debris)
		debris.initialize(translation + Vector3(0, -1, 0), 9)
	for i in range (0, 3):
		debris = debrisScene.instance()
		get_parent().add_child(debris)
		debris.initialize(translation + Vector3(0, -1, 0), 10)

func _on_hurtbox_area_entered(area):
	# defines attacker
	var attacker = area.get_parent().get_parent()
	# tells attacker that the hit occurred
	attacker.hitLanded = true
	# knockback
	if (attacker.hitType == attacker.KB_STRONG_RECOIL):
		attacker.recoilStart = true
	hp -= 1
	if (hp <= 0):
		dead()
		return
	#shakes barrel
	anim.play("shake")
	# Produces hit vfx and sfx
	var vfx = vfxScene.instance()
	get_parent().add_child(vfx)
	vfx.playEffect("hit", 0.5*(translation + attacker.translation))
	soundManager.playSound(attacker.hitSound)


func _on_bottomCheck_area_entered(area):
	dead()
