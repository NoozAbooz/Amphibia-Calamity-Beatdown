extends StaticBody


export(int, "None", "1", "2", "3", "4") var preset


# Called when the node enters the scene tree for the first time.
func _ready():
	# removes all uneeded decorations on the tree
	for i in range(1, 5):
		if (i != preset):
			get_node("preset" + str(i)).queue_free()

