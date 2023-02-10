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

var numWaves = 1
var wave0 = [
	nme.ambEnemy.new(nme.spiderScene,        nme.spider,        Vector3(8, -5, 0),  Vector3(-10, 60, -10), 0),
	nme.ambEnemy.new(nme.spiderScene,        nme.spider,        Vector3(-8, -5, 0),  Vector3(10, 60, 0), 30),
	nme.ambEnemy.new(nme.spiderScene,        nme.spider,        Vector3(8, -5, 0),  Vector3(-10, 60, 10), 60),
	nme.ambEnemy.new(nme.greenMantisScene,   nme.greenMantis,   Vector3(6, -5, 0),  Vector3(10, 60, 0), 120),
	nme.ambEnemy.new(nme.greenMantisScene,   nme.greenMantis,   Vector3(-6, -5, 0),  Vector3(-10, 60, 0), 120),
	nme.ambEnemy.new(nme.waspScene,   nme.wasp,   Vector3(-2, 4, -9),  Vector3.ZERO, 240),
	nme.ambEnemy.new(nme.waspScene,   nme.wasp,   Vector3(-2, 4, -9),  Vector3.ZERO, 270),
	nme.ambEnemy.new(nme.waspScene,   nme.wasp,   Vector3(-2, 4, -9),  Vector3.ZERO, 300),
	nme.ambEnemy.new(nme.waspScene,   nme.wasp,   Vector3(-2, 4, -9),  Vector3.ZERO, 330),
	nme.ambEnemy.new(nme.waspScene,   nme.wasp,   Vector3(-2, 4, -9),  Vector3.ZERO, 360),
	nme.ambEnemy.new(nme.blackMantisScene,   nme.blackMantis,   Vector3(8, -5, -3),  Vector3(-10, 60, 0), 510),
	nme.ambEnemy.new(nme.blackMantisScene,   nme.blackMantis,   Vector3(6, -5, 3),  Vector3(10, 60, 0), 510),
	nme.ambEnemy.new(nme.blackMantisScene,   nme.blackMantis,   Vector3(-6, -5, 3),  Vector3(-10, 60, 0), 510),
	nme.ambEnemy.new(nme.waspScene,   nme.wasp,   Vector3(21, 6, -2),  Vector3.ZERO, 150),
	nme.ambEnemy.new(nme.waspScene,   nme.wasp,   Vector3(21, 6, 2),  Vector3.ZERO, 150),
	nme.ambEnemy.new(nme.waspScene,   nme.wasp,   Vector3(-21, 6, -2),  Vector3.ZERO, 150),
	nme.ambEnemy.new(nme.waspScene,   nme.wasp,   Vector3(-21, 6, 2),  Vector3.ZERO, 150),
]

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass	
