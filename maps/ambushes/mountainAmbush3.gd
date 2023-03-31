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
	nme.ambEnemy.new(nme.waspScene, nme.wasp, Vector3(-6, 8, -13), Vector3.ZERO, 90),
	nme.ambEnemy.new(nme.waspScene, nme.wasp, Vector3(6, 8, -13), Vector3.ZERO, 60),
	nme.ambEnemy.new(nme.waspScene, nme.wasp, Vector3(0, 8, -13), Vector3.ZERO, 120)
]

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass	
