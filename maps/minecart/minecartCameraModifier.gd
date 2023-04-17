extends Area


export(int, "Stop Camera", "Free Camera", "Change Camera Offset", "Reset Position", "Free Camera Locks", "Lock Camera Height") var action

export var newOffset = Vector3.ZERO

export var cameraSpeed = 1.0

enum {STILL, FOLLOW, READY, FOLLOW_X_ONLY}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("MeshInstance").queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_cameraModifier_area_entered(area):
	#print("move cam")
	var cam = get_parent().get_parent().get_node("camera_pivot/Camera")
	match action:
		0: #STOP
			cam.mode = STILL
		1: #FREE
			cam.mode = FOLLOW
			cam.positioningSpeed = 1
		2: #CHANGE OFFSET
			cam.cinematicOffset = newOffset
			cam.positioningSpeed = cameraSpeed
		3: #RESET
			cam.cinematicOffset = Vector3.ZERO
			cam.positioningSpeed = cameraSpeed
			cam.mode = FOLLOW
		4: #FREE
			cam.mode = FOLLOW
		5: #LOCK_Y
			cam.mode = FOLLOW_X_ONLY
			
