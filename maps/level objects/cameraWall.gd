extends Area

export var visibleMesh = false

func _ready():
	if (visibleMesh == false):
		get_node("MeshInstance").queue_free()
		get_node("MeshInstance2").queue_free()

func _on_cameraWall_area_entered(area):
	var cam = area.get_parent()
	if (self.global_transform.origin.x >= cam.global_transform.origin.x):
		cam.onRightWall = true
	else:
		cam.onLeftWall = true

func _on_cameraWall_area_exited(area):
	var cam = area.get_parent()
	cam.onLeftWall = false
	cam.onRightWall = false
