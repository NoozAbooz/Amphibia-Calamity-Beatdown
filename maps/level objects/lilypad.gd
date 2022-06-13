extends StaticBody

export var flower = false

func _ready():
	if flower:
		$flower.show()
	else:
		$flower.hide()
