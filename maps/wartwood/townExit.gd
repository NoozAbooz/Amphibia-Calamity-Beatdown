extends Area

export var visibleMesh = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if (visibleMesh == false):
		get_node("MeshInstance").queue_free()

func _on_exit_area_entered(area):
	queue_free()
	pg.backToMapLose()
