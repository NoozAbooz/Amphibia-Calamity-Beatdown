extends KinematicBody

export(int, "green_mantis", "yellow_mantis", "black_mantis", "spider", "wasp", "robot") var skinInt
# no zapzaps because their weird outline thing

var vfxScene = preload("res://scenes/vfx.tscn")

onready var sprite = $zeroPoint/AnimatedSprite3D

var velocity = Vector3.ZERO
export var lookRight = false


var force_grav = 125.0
var snapVect  = Vector3.ZERO

var dead = false

export var forceBounce = false

export var forceRunOver = false

var skin = "green_mantis"

var attackerSpeed = 0

export var walk = Vector3.ZERO

export var flying = false

var aggro = false

# Called when the node enters the scene tree for the first time.
func _ready():
	match skinInt:
		0:
			skin = "green_mantis"
			sprite.offset.y = 32
		1:
			skin = "yellow_mantis"
			sprite.offset.y = 32
		2:
			skin = "black_mantis"
			sprite.offset.y = 32
		3:
			skin = "spider"
			sprite.offset.y = 12
		4:
			skin = "wasp"
			sprite.offset.y = 16
		5:
			skin = "robot"
			sprite.offset.y = 46
	if lookRight:
		sprite.flip_h = true
	if skin == "spider":
		sprite.flip_h = !sprite.flip_h
	velocity = Vector3.ZERO
	if (walk == Vector3.ZERO):
		sprite.play(skin + "_idle")
		$zeroPoint/aggro.queue_free()
	else:
		sprite.play(skin + "_walk")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if aggro:
		velocity.x = walk.x
		aggro = false
		$zeroPoint/aggro.queue_free()
	# Y movement
	if (not flying) or (flying and dead):
		velocity.y -= force_grav * delta
	# snapping setup 
	if dead:
		snapVect = Vector3.ZERO
	else:
		snapVect = Vector3(0, -5, 0)
	# move and slide
	velocity.y = move_and_slide_with_snap(velocity, snapVect, Vector3.UP, true).y

func runOver(area):
	# freezes for dramatic effect
	velocity.x = 0
	$stunTimer.start(0.1)
	# stores minecart X speed
	attackerSpeed = area.get_parent().get_parent().velocity.x
	# dead flag
	dead = true
	# Produces hit vfx and sfx
	soundManager.playSound("hit" + str(rng.rand.randi_range(1, 3)))
	var vfx = vfxScene.instance()
	get_parent().add_child(vfx)
	vfx.playEffect("hit", 0.5*(translation + area.get_parent().get_parent().translation) + Vector3(0, 0, 1))
	sprite.play(skin + "_dead")
	# signals to minecart
	area.get_parent().get_parent().hitEnemy()

func bounceOff(area):
	# stores minecart X speed
	attackerSpeed = area.get_parent().get_parent().velocity.x
	# dead flag
	dead = true
	# Produces hit vfx and sfx
	soundManager.playSound("hit4")
	var vfx = vfxScene.instance()
	get_parent().add_child(vfx)
	vfx.playEffect("hit", 0.5*(translation + area.get_parent().get_parent().translation) + Vector3(0, 0, 1))
	sprite.play(skin + "_dead")
	# signals to minecart
	area.get_parent().get_parent().bounce()
	# sends enemy flying
	_on_stunTimer_timeout()
	
func _on_hurtbox_area_entered(area):
	$despawnTimer.start(3)
	$zeroPoint/hurtbox/CollisionShape.disabled = true
	if forceRunOver:
		runOver(area)
	elif (area.get_parent().get_parent().isInState([4])) or (forceBounce):
		bounceOff(area)
	else:
		runOver(area)


func _on_stunTimer_timeout():
	$CollisionShapeGround.disabled = true
	velocity.y = rng.rand.randf_range(25, 60)
	velocity.x = attackerSpeed + rng.rand.randf_range(5, 15)
	velocity.z = rng.rand.randf_range(-40, 40)


func _on_despawnTimer_timeout():
	queue_free()


func _on_aggro_area_entered(area):
	aggro = true
