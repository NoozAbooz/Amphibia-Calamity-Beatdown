extends KinematicBody

var vfxScene = preload("res://scenes/vfx.tscn")
var coinScene = preload("res://scenes/pickups/coin.tscn")
var khaoScene = preload("res://scenes/pickups/khao.tscn")
var mushScene = preload("res://scenes/pickups/mush.tscn")
var liveScene = preload("res://scenes/pickups/1up.tscn")
var debrisScene = preload("res://scenes/enemies/spawners/debris.tscn")
var randChoice = 0

var velocity = Vector3.ZERO
var force_grav = 125.0
var spinSpeed = 360

var foods = 0
var spiders = 0
var wasps = 0
var papers = 0
var zaps = 0

enum {KB_WEAK, KB_STRONG, KB_ANGLED, KB_AIR, KB_STRONG_RECOIL, KB_AIR_UP, KB_WEAK_PIERCE, KB_STRONG_PIERCE, KB_ANGLED_PIERCE}
var hitDamage = 15
var hitType = KB_ANGLED
var hitDir = Vector3(10, -1, 0)

#prevents enemies from trying to "target" the geyser and other crashes
var playerChar = "hazard"
var hitLanded = false
var hitSound = "hit4"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		
func initialize(location, vel, rotY, numSpiders=0, numPapers=0, numWasps=0, numZaps=0, numFoods=0):
	transform.origin = location
	velocity = vel
	rotation_degrees.y = rotY
	spiders = numSpiders
	papers = numPapers
	wasps = numWasps
	zaps = numZaps
	foods = numFoods

		
func _process(delta):
	velocity.y -= force_grav * delta
	velocity = move_and_slide(velocity, Vector3.UP, true)
	$zeroPoint.rotation_degrees.x -= delta * spinSpeed
	if is_on_floor() or is_on_wall():
		dead()

func dead():
	$zeroPoint/barrel.hide()
	rotation = Vector3.ZERO
	# spawns food
	for i in range(0, foods):
		var food = mushScene.instance()
		get_parent().add_child(food)
		food.initialize(global_transform.origin + Vector3(0, 1, 0))
	# spawns wasps
	for i in range(0, wasps):
		var nextEnemy = nme.waspScene.instance()
		get_parent().add_child(nextEnemy)
		nextEnemy.initialize(nme.wasp, global_transform.origin + Vector3(0, 1, 0), Vector3.ZERO, true, true, true)
	# spawns paper wasps
	for i in range(0, papers):
		var nextEnemy = nme.paperWaspScene.instance()
		get_parent().add_child(nextEnemy)
		nextEnemy.initialize(nme.paperWasp, global_transform.origin + Vector3(0, 1, 0), Vector3.ZERO, true, true, true)
	# spawns spiders
	for i in range(0, spiders):
		var nextEnemy = nme.spiderScene.instance()
		get_parent().add_child(nextEnemy)
		nextEnemy.initialize(nme.spider, global_transform.origin + Vector3(0, 1, 0), Vector3(rng.rand.randf_range(-10, 10), 25, rng.rand.randf_range(-10, 10)), true, true, true)
		nextEnemy.hp = 0
	# spawns zapapedes
	for i in range(0, zaps):
		var nextEnemy = nme.zapapedeScene.instance()
		get_parent().add_child(nextEnemy)
		nextEnemy.initialize(nme.zapapede, global_transform.origin + Vector3(0, 1, 0), Vector3(rng.rand.randf_range(-10, 10), 25, rng.rand.randf_range(-10, 10)), true, true, true)
		nextEnemy.hp = 25
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
		debris.initialize(global_transform.origin + Vector3(0, -1, 0), i)
	# makes wood shards
	for i in range (0, 2):
		debris = debrisScene.instance()
		get_parent().add_child(debris)
		debris.initialize(global_transform.origin + Vector3(0, -1, 0), 9)
	for i in range (0, 3):
		debris = debrisScene.instance()
		get_parent().add_child(debris)
		debris.initialize(global_transform.origin + Vector3(0, -1, 0), 10)
