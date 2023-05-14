extends Area

export var visibleMesh = false
export var lockZ = false
export var unlockZ = false

func _ready():
	if (visibleMesh == false):
		get_node("MeshInstance").queue_free()
		get_node("MeshInstance2").queue_free()

func _on_cameraWall_area_entered(area):		
	var cam = area.get_parent()
	if lockZ:
		cam.lockedHeight = true
	elif unlockZ:
		cam.lockedHeight = false
	elif (self.global_transform.origin.x >= cam.global_transform.origin.x):
		cam.onRightWall = true
	else:
		cam.onLeftWall = true

func _on_cameraWall_area_exited(area):
	var cam = area.get_parent()
	if lockZ or unlockZ:
		pass
	cam.onLeftWall = false
	cam.onRightWall = false
