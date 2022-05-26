extends Spatial


var nmeScene = preload("res://scenes/enemies/spider.tscn")
var enemy = null
var counter = 45

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	#counter -= 1
	if counter <= 0:
		counter = 45
		enemy = nmeScene.instance()
		get_parent().add_child(enemy)
		enemy.initialize(nme.spider, Vector3(0, 0, 0), Vector3(0, 0, 15), true, true, true)
		

