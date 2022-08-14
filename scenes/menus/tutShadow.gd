extends Sprite

export var targetName = ""
var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_parent().get_node(targetName)


func _process(delta):
	position.x = target.position.x
