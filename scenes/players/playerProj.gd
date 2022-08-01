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

onready var sprite = get_node("zeroPoint/AnimatedSprite3D")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(pos, lookRight, damage, type, dir, sfx = "hit1", projType = 0):
	# flips sprite if necessary and sets starting velocity
	if (lookRight == false):
		sprite.flip_h = true
		velocity = Vector3(-30, 10, 0)
	else:
		sprite.flip_h = false
		velocity = Vector3(30, 10, 0)
	match projType:
		0:
			sprite.play("rock")
		1:
			sprite.play("arrow")
		_:
			sprite.play("rock")
	# sets projective values
	hitDamage = damage
	hitType = type
	hitDir = dir
	hitSound = sfx
	translation = pos
		
func _physics_process(delta):
	# exerts gravity
	velocity.y -= force_grav * delta
	# moves the object based on velocity vector
	translation += velocity * delta


func _on_despawnTimer_timeout():
	queue_free()

func _on_proj_area_entered(area):
	queue_free()
