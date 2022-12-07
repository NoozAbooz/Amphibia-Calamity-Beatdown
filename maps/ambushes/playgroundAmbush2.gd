extends Spatial

# sequential waves begin when all enemies from previous are defeated

# when defining the amuch enemy, the five parameters are:
#	enemy scene
#	enemy stats
#	starting location relative to the ambush zero point (orange sphere)
#	starting velocity (to have enemies jump out of bushes or nests)
#   time delay before spawning in frames (to have delayed spawns in a single wave) (max of 600 frames / ~10sec)
# Look at enemyInfo.gd in globals for context

var numWaves = 1
var wave0 = [
	nme.ambEnemy.new(nme.robotScene, nme.robot, Vector3(23, 1, 2),   Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.robotScene, nme.robot, Vector3(-23, 1, 0),  Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.blackMantisScene, nme.blackMantis, Vector3(-25, 1, 0),    Vector3.ZERO, 0),
	nme.ambEnemy.new(nme.robotScene, nme.robot, Vector3(23, 1, -2),   Vector3.ZERO, 0),
]
