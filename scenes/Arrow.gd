extends Spatial

export var hitDamage = 10
var hitType = 0
var hitDir = Vector3(10, 25, 0)
export var speed = 5
export var dir = Vector3(0.1, 0, 0)
enum {FLY, FALL}
var state = FLY
onready var anim = $"AnimationPlayer"
var timer = 180
#enum {KB_WEAK, KB_STRONG, KB_ANGLED, KB_AIR, KB_STRONG_RECOIL, KB_AIR_UP}

# Called when the node enters the scene tree for the first time.
func _ready():
	state = FLY
	timer = 90
	$"sprite pivot".look_at(translation + dir, Vector3.UP)

func initialize(targetVect, damage, spd, startingPoint):
	speed = spd
	hitDamage = damage
	translation = startingPoint
	dir = targetVect - translation	
	$"sprite pivot".look_at(translation + dir, Vector3.UP)

func _process(_delta):
	if (state == FLY):
		anim.play("fly")
		translation += speed * dir.normalized() * 0.05
	elif (state == FALL):
		anim.play("fall")
		translation += speed * dir.normalized() * -0.025
#	if (dir.x >= 0):
#		get_node("sprite pivot/Sprite3D").flip_h = false
#	else:
#		get_node("sprite pivot/Sprite3D").flip_h = true
	timer -= 1
	if (timer <= 0):
		queue_free()

func _on_hurtbox_area_entered(_area):
	state = FALL
	timer = 45
	#print("test")
