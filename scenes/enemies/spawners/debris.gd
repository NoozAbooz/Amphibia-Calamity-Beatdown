extends Spatial

var force_grav = 100.0
var velocity = Vector3.ZERO

var object = 0 # a number that represents what model of debris to use. Set by game object that spawns the debris.
enum {WEB1, WEB2, EGGL, EGGM, EGGS, EGGS2}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func initialize(location, objectNumber):
	# starting position
	translation = location
	# starting velocity
	velocity.y = rng.rand.randf_range(30, 38)
	velocity.x = rng.rand.randf_range(10, 18)
	velocity = velocity.rotated(Vector3.UP, rng.rand.randf_range(0, 2*PI))
	# makes appropriate model of debris visible
	match objectNumber:
		WEB1:
			$model/web_debris_1.visible = true
		WEB2:
			$model/web_debris_2.visible = true
		EGGL:
			$model/egg_debris_large.visible = true
		EGGM:
			$model/egg_debris_medium.visible = true
		EGGS:
			$model/egg_debris_small.visible = true
		EGGS2:
			$model/egg_debris_small_2.visible = true
		_: 
			$model/egg_debris_large.visible = true
	
	
func _process(delta):
	# exerts gravity
	velocity.y -= force_grav * delta
	# moves the object based on velocity vector
	translation += velocity * delta
	# spins
	$model.rotate_z(2*PI*delta)


func _on_Timer_timeout():
	# unloads object after a set time (1.5 sec)
	queue_free()
