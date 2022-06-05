extends Spatial

# sequential waves begin when all enemies from previous are defeated

# when defining the amuch enemy, the five parameters are:
#	enemy scene
#	enemy stats
#	starting location relative to the ambush zero point (orange sphere)
#	starting velocity (to have enemies jump out of bushes or nests)
#   time delay before spawning in frames (to have delayed spawns in a single wave) (max of 600 frames / ~10sec)
# Look at enemyInfo.gd in globals for context

var numWaves = 4
var wave0 = [
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(23, 1, 0),   Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(-23, 1, 0),  Vector3.ZERO, 0)
]
var wave1 = [
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(23, 1, 0),    Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(-23, 1, 0),   Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.spiderScene,      nme.spider,      Vector3(0, 0.5, -4),  Vector3(0, 30, 0), 120),
	nme.ambEnemy.new(nme.spiderScene,      nme.spider,      Vector3(-5, 0.5, -8), Vector3(0, 30, 0), 150),
	nme.ambEnemy.new(nme.spiderScene,      nme.spider,      Vector3(5, 0.5, -8),  Vector3(0, 30, 0), 150)
]
var wave2 = [
	nme.ambEnemy.new(nme.waspScene, nme.wasp, Vector3(23, 1, 0),   Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.waspScene, nme.wasp, Vector3(-23, 1, 0),  Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.waspScene, nme.wasp, Vector3(23, 1, 1),   Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.waspScene, nme.wasp, Vector3(-23, 1, 1),  Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.waspScene, nme.wasp, Vector3(23, 1, -1),   Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.waspScene, nme.wasp, Vector3(-23, 1, -1),  Vector3.ZERO, 0)
]
var wave3 = [
	nme.ambEnemy.new(nme.redMantisScene,   nme.redMantis,   Vector3(0, 20, -1),  Vector3.ZERO, 60),
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(-5, 20, -3), Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(5, 20, -3),  Vector3.ZERO,  0)
]

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass	
