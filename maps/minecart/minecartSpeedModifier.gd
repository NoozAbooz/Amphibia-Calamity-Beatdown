extends Area


export(int, "Default Speed", "Change Speed") var action

export var newTopSpeedMultiplier = 1.0

export var accel = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("MeshInstance").queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_cameraModifier_area_entered(area):
	var cart = get_parent().get_parent().get_node("minecart")
	#print("change speed")
	match action:
		0: #DEFAULT
			cart.desMaxSpeed = cart.defaultMaxSpeed
			cart.speedFactor = accel
		1: #SET
			cart.desMaxSpeed = cart.defaultMaxSpeed * newTopSpeedMultiplier
			cart.speedFactor = accel


