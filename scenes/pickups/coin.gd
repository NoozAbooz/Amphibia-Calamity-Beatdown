extends KinematicBody


var force_grav = 125.0
var velocity = Vector3.ZERO
var bounceForce = 0
var bounceCount = 0
var settled = false
var magActivated = false
export var value = 1
export var gravOff = false # makes coins float in place instead of fall. Used for coins placed in the world.


var deathFloorHeight = -30

var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$magnet/CollisionShape3.disabled = true
	match value:
		1:
			get_node("AnimatedSprite3D").play("copper")
		5:
			get_node("AnimatedSprite3D").play("silver")
		20:
			get_node("AnimatedSprite3D").play("gold")
		_:
			get_node("AnimatedSprite3D").play("copper")

func initialize(spawnLocation, val = 1):
	value = val
	translation = spawnLocation
	velocity.y = rng.rand.randf_range(20, 30)
	bounceForce = velocity.y * 0.75
	velocity.x = rng.rand.randf_range(1, 6)
	velocity = velocity.rotated(Vector3.UP, rng.rand.randf_range(0, 6.28))
	get_node("AnimatedSprite3D").play()
	value = val
	match value:
		1:
			get_node("AnimatedSprite3D").play("copper")
		5:
			get_node("AnimatedSprite3D").play("silver")
		20:
			get_node("AnimatedSprite3D").play("gold")
		_:
			get_node("AnimatedSprite3D").play("copper")
	# sets random spin direction for coins
	if self.is_in_group("coins"):
		if (rng.rand.randf() > 0.5):
			self.get_node("AnimatedSprite3D").flip_h = true
		else:
			self.get_node("AnimatedSprite3D").flip_h = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# makes coins fal and bounce is gravity isn't turned off and is hasn't been pulled in yet
	if (gravOff == false):
		velocity.y -= force_grav * delta
		if (is_on_floor()) and (settled == false):
			if (rng.rand.randf() <= 0.25):
				settled = true
			else:
				velocity.x *= 0.5
				velocity.y = bounceForce
				velocity.z *= 0.5
				bounceForce *= 0.75
				bounceCount += 1
				if (bounceCount < 5):
					soundManager.pitchSound("coin1", (2.2 -  ((0.3/10.0) * bounceForce)), -10)
					soundManager.playSound("coin1")
		if (settled):
			velocity.x = 0
			velocity.y = 0
			velocity.z = 0
	# moves to player if activated
	if (target != null) and settled:
		velocity = 25 * (target.translation - translation).normalized()
	# moves the coin based on velocity vector
	velocity = move_and_slide(velocity, Vector3.UP, true)
	# fall off world
	if (translation.y <= deathFloorHeight):
		queue_free()
	# activates magnet if coin is settled
	if settled and !magActivated:
		$magnet/CollisionShape3.disabled = false
		magActivated = true


func _on_magnet_area_entered(area):
	target = area.get_parent().get_parent()
	$magnet.queue_free()
