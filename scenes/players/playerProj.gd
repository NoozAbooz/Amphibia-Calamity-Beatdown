extends KinematicBody


var hitDamage = 0
var hitDamageMulti = 1.0
var hurtDamageMulti = 1.0
var hitType = 0
var hitDir = Vector3.ZERO
var hitSound = ""

var velocity = Vector3.ZERO
var velocityInit = Vector3.ZERO

var force_grav = 50.0
var force_grav_heavy = 100.0

var hitLanded = false

var active = true

var playerChar = "proj"

var playerNum = 5

enum {GRAV, NOGRAV, GRAVBOUNCE, GRAVHEAVY}

var physType = GRAV

var despawnOnHit = false

var bounceOffEnemy = false

var stickInPlace = false

var baseball = false

var explosive = false
var exploded = false

onready var sprite = get_node("zeroPoint/AnimatedSprite3D")

onready var hitboxCol = get_node("zeroPoint/hitbox/CollisionShape")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(pos, lookRight, damage, type, dir, sfx = "hit1", projType = 0, projVel = Vector3.ZERO, projAng = 0, projSource = 5):
	# determines type of physics
	physType = projType
	
	# stores who shot the projectile
	playerNum = projSource
	
	# default hitbox
	hitboxCol.shape.radius = 0.5
	hitboxCol.shape.height = 0.75
	
	match projType:
		0:
			sprite.offset = Vector2.ZERO
			despawnOnHit = false
			bounceOffEnemy = false
			sprite.play("rock")
			physType = GRAV
			# flips sprite if necessary and sets starting velocity
			if (lookRight == false):
				sprite.flip_h = true
				velocity = Vector3(-30, 10, 0)
			else:
				sprite.flip_h = false
				velocity = Vector3(30, 10, 0)
		1:
			sprite.offset = Vector2.ZERO
			despawnOnHit = true
			bounceOffEnemy = false
			stickInPlace = true
			physType = NOGRAV
			sprite.play("arrow")
			# flips sprite if necessary and sets starting velocity
			if (lookRight == false):
				sprite.flip_h = false
				projVel.x *= -1
				projAng = -1 * projAng
			else:
				sprite.flip_h = true
			sprite.rotation_degrees.z = -1 * projAng
			velocity = projVel.rotated(Vector3(0, 0, 1), deg2rad(projAng))
		2:
			sprite.offset = Vector2(-6, 4)
			despawnOnHit = true
			bounceOffEnemy = true
			physType = NOGRAV
			sprite.play("ball")
			baseball = true
			# flips sprite if necessary and sets starting velocity
			if (lookRight == false):
				sprite.flip_h = false
				projVel.x *= -1
				projAng = -1 * projAng
				sprite.rotation_degrees.z = (-1 * projAng) + 20
			else:
				sprite.flip_h = true
				sprite.rotation_degrees.z = (-1 * projAng) - 20
			velocity = projVel.rotated(Vector3(0, 0, 1), deg2rad(projAng))
		3:
			despawnOnHit = true
			bounceOffEnemy = false
			physType = GRAVHEAVY
			sprite.play("potion")
			baseball = false
			explosive = true
			#hitboxCol.disabled = true
			# flips sprite if necessary and sets starting velocity
			if (lookRight == false):
				sprite.flip_h = false
				projVel.x *= -1
				projAng = -1 * projAng
				sprite.rotation_degrees.z = (-1 * projAng) + 20
			else:
				sprite.flip_h = true
				sprite.rotation_degrees.z = (-1 * projAng) - 20
			velocity = projVel.rotated(Vector3(0, 0, 1), deg2rad(projAng))
		_:
			sprite.play("rock")
			physType = GRAV
			# flips sprite if necessary and sets starting velocity
			if (lookRight == false):
				sprite.flip_h = true
				velocity = Vector3(-30, 10, 0)
			else:
				sprite.flip_h = false
				velocity = Vector3(30, 10, 0)
	# sets projective values
	hitDamage = damage
	hitType = type
	hitDir = dir
	hitSound = sfx
	translation = pos
	# stores initial velocity for bouncing
	velocityInit = velocity
		
func _physics_process(delta):
	if not active and not stickInPlace:
		velocity.y -= force_grav * delta
		sprite.rotation_degrees.z += delta * 600
		if is_on_floor() or is_on_wall():
			queue_free()
	# exerts gravity
	if (physType == GRAV):
		velocity.y -= force_grav * delta
	if (physType == GRAVHEAVY):
		velocity.y -= force_grav_heavy * delta
	# contact with things
	if is_on_wall():
		if stickInPlace:
			stick()
		elif explosive:
			explode()
		else:
			ricochet()
	if is_on_floor():
		if stickInPlace:
			stick()
		elif explosive:
			explode()
		else:
			bounce()
	if (hitLanded and despawnOnHit and active):
		if explosive:
			explode()
		elif not bounceOffEnemy:
			queue_free()
		else:
			ricochet()
	# moves the object based on velocity vector
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
func ricochet():
	if (get_node_or_null("zeroPoint/hitbox") != null):
		get_node_or_null("zeroPoint/hitbox").queue_free()
	active = false
	velocity.x = -0.3 * velocityInit.x
	velocity.y = 13
	force_grav = 75
	if (baseball):
		sprite.play("ball2")
		sprite.offset = Vector2.ZERO
	
func bounce():
	if (get_node_or_null("zeroPoint/hitbox") != null):
		get_node_or_null("zeroPoint/hitbox").queue_free()
	active = false
	velocity.x *= 0.6
	velocity.y = 13
	force_grav = 75
	if (baseball):
		sprite.play("ball2")
		sprite.offset = Vector2.ZERO
		
func explode():
	if (exploded == true):
		return
	exploded = true
	if (get_node_or_null("shadowMaker") != null):
		get_node_or_null("shadowMaker").queue_free()
	if (get_node_or_null("zeroPoint/AnimatedSprite3D") != null):
		get_node("zeroPoint/AnimatedSprite3D").queue_free()
	get_node("despawnTimer").start(0.5)
	hitboxCol.disabled = false
	hitboxCol.shape.radius = 2.5
	hitboxCol.shape.height = 4
	velocity.x = 0
	velocity.y = 0
	velocity.z = 0
	force_grav_heavy = 0
	$AnimationPlayer.play("splode")
	soundManager.pitchSound("bomb1", rng.rand.randf_range(0.95, 1.3))
	soundManager.playSound("bomb1")
#	if (get_node("explosionMesh") != null):
#		get_node("explosionMesh").visible = true
	
		
func stick():
	if (get_node_or_null("zeroPoint/hitbox") != null):
		get_node_or_null("zeroPoint/hitbox").queue_free()
	#get_node("despawnTimer").start(1.25)
	active = false
	velocity.x = 0
	velocity.y = 0
	velocity.z = 0
	force_grav = 0

func _on_despawnTimer_timeout():
	queue_free()

func _on_proj_area_entered(area):
	queue_free()
