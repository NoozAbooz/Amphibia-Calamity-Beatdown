extends KinematicBody


var force_grav = 125.0
var velocity = Vector3.ZERO
var bounceForce = 0
var settled = false
export var value = 1
export var gravOff = false

var deathFloorHeight = -30

#var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#rng.randomize()
	#initialize()

func initialize(spawnLocation, val = 1):
	value = val
	translation = spawnLocation
	velocity.y = rng.rand.randf_range(20, 40)
	bounceForce = velocity.y * 0.75
	velocity.x = rng.rand.randf_range(5, 10)
	velocity = velocity.rotated(Vector3.UP, rng.rand.randf_range(0, 6.28))
	get_node("AnimatedSprite3D").play()
	value = val
	# sets random spin direction for coins
	if self.is_in_group("coins"):
		if (rng.rand.randf() > 0.5):
			self.get_node("AnimatedSprite3D").flip_h = true
		else:
			self.get_node("AnimatedSprite3D").flip_h = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gravOff:
		return
	velocity.y -= force_grav * delta
	if (is_on_floor()) and (settled == false):
		if (rng.rand.randf() <= 0.25):
			settled = true
		else:
			velocity.x *= 0.5
			velocity.y = bounceForce
			velocity.z *= 0.5
			bounceForce *= 0.75
			if self.is_in_group("coins"):
				soundManager.pitchSound("coin1", (2.2 -  ((0.3/10.0) * bounceForce)), -10) #rng.rand.randf_range(1.9, 2.2))
				soundManager.playSound("coin1")
	if (settled):
		velocity.x = 0
		velocity.y = 0
		velocity.z = 0
	velocity = move_and_slide(velocity, Vector3.UP, true)
	# fall off world
	if (translation.y <= deathFloorHeight):
		queue_free()
