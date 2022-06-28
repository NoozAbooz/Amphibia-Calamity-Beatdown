extends Control


onready var main = get_node("main")
onready var conf = get_node("confirm")
onready var dia = get_node("dialogue")

onready var spriteL = get_node("dialogue/leftChar")
onready var spriteR = get_node("dialogue/rightChar")
onready var animL = get_node("dialogue/leftCharAnim")
onready var animR = get_node("dialogue/rightCharAnim")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
