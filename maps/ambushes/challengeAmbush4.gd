extends Spatial

# sequential waves begin when all enemies from previous are defeated

# when defining the amuch enemy, the five parameters are:
#	enemy scene
#	enemy stats
#	starting location relative to the ambush zero point (orange sphere)
#	starting velocity (to have enemies jump out of bushes or nests)
#   time delay before spawning in frames (to have delayed spawns in a single wave) (max of 600 frames / ~10sec)
# Look at enemyInfo.gd in globals for context

# Setting the first wave to a number means no enemies will spawn
# and the player must kill that many existing enemies to complete the wave

var numWaves = 3
var wave0 = [
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(24, 0, 4),  Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(24, 0, 4),  Vector3.ZERO, 60),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(24, 0, 4),  Vector3.ZERO, 120),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(24, 0, 4),  Vector3.ZERO, 180),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(24, 0, 4),  Vector3.ZERO, 240),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(24, 0, 4),  Vector3.ZERO, 300),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(24, 0, 4),  Vector3.ZERO, 360),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(24, 0, 4),  Vector3.ZERO, 420),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(24, 0, 4),  Vector3.ZERO, 480),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(-20, 0, 0),  Vector3.ZERO, 30),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(-20, 0, 0),  Vector3.ZERO, 90),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(-20, 0, 0),  Vector3.ZERO, 150),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(-20, 0, 0),  Vector3.ZERO, 210),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(-20, 0, 0),  Vector3.ZERO, 270),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(-20, 0, 0),  Vector3.ZERO, 330),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(-20, 0, 0),  Vector3.ZERO, 390),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(-20, 0, 0),  Vector3.ZERO, 450),
	nme.ambEnemy.new(nme.spiderScene,   nme.spider,   Vector3(-20, 0, 0),  Vector3.ZERO, 510),
	nme.ambEnemy.new(nme.waspScene,     nme.wasp,     Vector3(9, 0, -3),  Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.waspScene,     nme.wasp,     Vector3(9, 0, -3),  Vector3.ZERO, 60),
	nme.ambEnemy.new(nme.waspScene,     nme.wasp,     Vector3(9, 0, -3),  Vector3.ZERO, 120),
	nme.ambEnemy.new(nme.waspScene,     nme.wasp,     Vector3(9, 0, -3),  Vector3.ZERO, 180),
	nme.ambEnemy.new(nme.waspScene,     nme.wasp,     Vector3(9, 0, -3),  Vector3.ZERO, 240),
	nme.ambEnemy.new(nme.waspScene,     nme.wasp,     Vector3(9, 0, -3),  Vector3.ZERO, 300),
]
var wave1 = [
	nme.ambEnemy.new(nme.robotScene,   nme.robot,    Vector3(-21.5, 0, 0),  Vector3.ZERO, 30),
	nme.ambEnemy.new(nme.robotScene,   nme.robot,    Vector3(-21.5, 0, 0),  Vector3.ZERO, 90),
	nme.ambEnemy.new(nme.robotScene,   nme.robot,    Vector3(9, 0, -3),   Vector3.ZERO, 300)
]
var wave2 = [
	nme.ambEnemy.new(nme.greenMantisScene,   nme.greenMantis,   Vector3(0, 20, 0),  Vector3.ZERO, 30),
	nme.ambEnemy.new(nme.yellowMantisScene,   nme.yellowMantis,   Vector3(4, 20, 0),  Vector3.ZERO, 30),
	nme.ambEnemy.new(nme.blackMantisScene,   nme.blackMantis,   Vector3(-4, 20, 0),  Vector3.ZERO, 30),
	nme.ambEnemy.new(nme.redMantisScene,   nme.redMantis,   Vector3(0, 20, 0),  Vector3.ZERO, 120),
]

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass	
