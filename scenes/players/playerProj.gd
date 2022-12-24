extends Area


var hitDamage = 0
var hitDamageMulti = 1.0
var hurtDamageMulti = 1.0
var hitType = 0
var hitDir = Vector3.ZERO
var hitSound = ""

var velocity = Vector3.ZERO

var force_grav = 50.0

var hitLanded = false

var playerChar = "proj"

enum {GRAV, NOGRAV}
var physType = GRAV

var despawnOnHit = false

onready var sprite = get_node("zeroPoint/AnimatedSprite3D")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(pos, lookRight, damage, type, dir, sfx = "hit1", projType = 0, projVel = Vector3.ZERO, projAng = 0):
	# determines type of physics
	physType = projType
	
	match projType:
		0:
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
			despawnOnHit = true
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
		
func _physics_process(delta):
	# exerts gravity
	if (physType == GRAV):
		velocity.y -= force_grav * delta
	# moves the object based on velocity vector
	translation += velocity * delta
	# despawns after hit
	if hitLanded and (despawnOnHit):
		queue_free()

func _on_despawnTimer_timeout():
	queue_free()

func _on_proj_area_entered(area):
	queue_free()
