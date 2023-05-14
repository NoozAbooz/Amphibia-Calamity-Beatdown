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

var numWaves = 2

var wave0 = [
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(30, 0, -4), Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(-30, 0, -4), Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(35, 0, -4), Vector3.ZERO, 0),
	
	nme.ambEnemy.new(nme.spiderScene, nme.spider, Vector3(22, -5, -19), Vector3(-12, 50, 8), 60),
	nme.ambEnemy.new(nme.spiderScene, nme.spider, Vector3(21, -5, -20), Vector3(-12, 50, 8), 90),
	nme.ambEnemy.new(nme.spiderScene, nme.spider, Vector3(23, -5, -18), Vector3(-12, 50, 8), 120),
	
	nme.ambEnemy.new(nme.spiderScene, nme.spider, Vector3(-19,   -5, -23), Vector3(12, 50, 4), 60),
	nme.ambEnemy.new(nme.spiderScene, nme.spider, Vector3(-19.5, -5, -23.5), Vector3(12, 50, 4), 90),
	nme.ambEnemy.new(nme.spiderScene, nme.spider, Vector3(-18.5, -5, -22.5), Vector3(12, 50, 4), 120)
]

var wave1 = [
	nme.ambEnemy.new(nme.zapapedeScene, nme.zapapede, Vector3(30, 0, -4), Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.zapapedeScene, nme.zapapede, Vector3(-30, 0, -4), Vector3.ZERO, 0),
	
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(22, -5, -19), Vector3(-12, 50, 8), 0),
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(21, -5, -20), Vector3(-12, 50, 8), 90),
	
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(-19,   -5, -23), Vector3(12, 50, 4), 0),
	nme.ambEnemy.new(nme.greenMantisScene, nme.greenMantis, Vector3(-19.5, -5, -23.5), Vector3(12, 50, 4), 90),
]

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass	
