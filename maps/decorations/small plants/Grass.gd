extends Spatial

export(int, "Rectangular", "Circular", "Gauss") var distributionType
export var xRange = 10
export var zRange = 10
export var radius = 5

onready var smallGrassMulti  = $MultiMeshGrassSmall
onready var bigGrassMulti    = $MultiMeshGrassBig
onready var flowerRedMulti   = $MultiMeshFlowerRed
onready var flowerBlueMulti  = $MultiMeshFlowerBlue
onready var flowerGreenMulti = $MultiMeshFlowerGreen
onready var lilyMulti        = $MultiMeshLily

export var numSmallGrass = 30
export var numBigGrass = 5
export var numFlowerRed = 3
export var numFlowerBlue = 4
export var numFlowerGreen = 2
export var numLily = 5

onready var multiMeshSurface = null

func set_spawn_point(scaleFactor = 1.0):
	var x = xRange / float(scaleFactor)
	var z = zRange / float(scaleFactor)
	var scaledRad = radius / float(scaleFactor)
	match distributionType:
		0:
			return Vector3((randf() * x) - (0.5 * x), 0, (randf() * z) - (0.5 * z))
		1:
			x = rng.rand.randf_range((-1 * scaledRad), scaledRad)
			var zMax = sqrt((scaledRad * scaledRad) - (x*x))
			z = rng.rand.randf_range((-1 * zMax), zMax)
			return Vector3(x, 0, z)
			
		2:
			var r = 2 * scaledRad
			while (r >= scaledRad):
				r = abs(scaledRad * rng.rand.randfn(0, 1.0))
			var vect = Vector3(r, 0, 0)
			vect = vect.rotated(Vector3(0, 1, 0), randf() * 2 * PI)
			return vect
		_:
			return

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	$defaultSurface.hide()
	
	# sets instance counts
	smallGrassMulti.multimesh.instance_count = numSmallGrass
	bigGrassMulti.multimesh.instance_count = numBigGrass
	flowerRedMulti.multimesh.instance_count = numFlowerRed
	flowerBlueMulti.multimesh.instance_count = numFlowerBlue
	flowerGreenMulti.multimesh.instance_count = numFlowerGreen
	lilyMulti.multimesh.instance_count = numLily
	
	# sets positions and rotations
	for i in range(smallGrassMulti.multimesh.instance_count):
		var position = Transform()
		position = position.rotated(Vector3(0, 0, 1), (PI * -0.5))
		if (randf() >= 0.5):
			position = position.rotated(Vector3(0, 1, 0), (PI * -0.5))
		else:
			position = position.rotated(Vector3(0, 1, 0), (PI * 0.5))
		position.origin = set_spawn_point(smallGrassMulti.scale.x)
		smallGrassMulti.multimesh.set_instance_transform(i, position)
	for i in range(bigGrassMulti.multimesh.instance_count):
		var position = Transform()
		position = position.rotated(Vector3(0, 1, 0), (randf() - 0.5) * (PI * 2))
		position.origin = set_spawn_point(bigGrassMulti.scale.x)
		bigGrassMulti.multimesh.set_instance_transform(i, position)
	for i in range(flowerRedMulti.multimesh.instance_count):
		var position = Transform()
		position = position.rotated(Vector3(0, 1, 0), (randf() - 0.5) * (PI * 0.5))
		position.origin = set_spawn_point(flowerRedMulti.scale.x)
		flowerRedMulti.multimesh.set_instance_transform(i, position)
	for i in range(flowerBlueMulti.multimesh.instance_count):
		var position = Transform()
		position = position.rotated(Vector3(0, 1, 0), (randf() - 0.5) * (PI * 0.5))
		position.origin = set_spawn_point(flowerBlueMulti.scale.x)
		flowerBlueMulti.multimesh.set_instance_transform(i, position)
	for i in range(flowerGreenMulti.multimesh.instance_count):
		var position = Transform()
		position = position.rotated(Vector3(0, 1, 0), (randf() - 0.5) * (PI * 0.5))
		position.origin = set_spawn_point(flowerGreenMulti.scale.x)
		flowerGreenMulti.multimesh.set_instance_transform(i, position)
	for i in range(lilyMulti.multimesh.instance_count):
		var position = Transform()
		position = position.rotated(Vector3(0, 1, 0), (randf() - 0.5) * (PI * 2))
		position.origin = set_spawn_point(lilyMulti.scale.x)
		position.origin.y -= randf() * 0.1
		lilyMulti.multimesh.set_instance_transform(i, position)


