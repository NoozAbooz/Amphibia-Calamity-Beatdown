extends Area

func _ready():
	pass # Replace with function body.

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
