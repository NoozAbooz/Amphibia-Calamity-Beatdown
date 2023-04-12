extends Camera


onready var cart = get_parent().get_parent().get_node("minecart")
onready var pivot = get_parent_spatial()

export var defaultOffset = Vector3(14, 15, 48)
export var startingOffset = Vector3(20, 0, 0)
var cinematicOffset = Vector3.ZERO

enum {STILL, FOLLOW, READY}
var mode = READY

var des = Vector3(0, 0, 0)
var act = Vector3(0, 0, 0)
var positioningSpeed = 1



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(loc):
	act = loc + defaultOffset + startingOffset
	pivot.translation = loc + defaultOffset + startingOffset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match mode:
		STILL:
			des = cart.translation + cinematicOffset
		FOLLOW:
			des = cart.translation + cinematicOffset + defaultOffset
			act.x += 0.1 * (des.x - act.x) * positioningSpeed
			act.y += 0.05 * (des.y - act.y) * positioningSpeed
			act.z += 0.1 * (des.z - act.z) * positioningSpeed
			pivot.translation = act
		READY:
			des = pivot.translation
			act.x += 0.1 * (des.x - act.x) * positioningSpeed
			act.y += 0.05 * (des.y - act.y) * positioningSpeed
			act.z += 0.1 * (des.z - act.z) * positioningSpeed
			pivot.translation = act
			if (cart.translation.x >= pivot.translation.x - defaultOffset.x):
				mode = FOLLOW
			
