extends Spatial

var target = null
var timer = 0
var targetFound = false

enum {WAITING, AIMING, SHOOTING, ENDLAG}
var state = WAITING
var nextState = WAITING

var projScene = preload("res://scenes/Arrow.tscn")

export var damage = 10
export var speed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	match state:
		WAITING:
			get_node("aggro/CollisionShape").disabled = false
			if (targetFound):
				targetFound = false
				nextState = AIMING
				timer = 60
		AIMING:
			get_node("aggro/CollisionShape").disabled = true
			if (timer <= 0):
				nextState = SHOOTING
		SHOOTING:
			spawnArrow(target)
			timer = 120
			nextState = ENDLAG
		ENDLAG:
			if (timer <= 0):
				targetFound = false
				target = null
				nextState = WAITING
	state = nextState
	
	
	if (timer > 0):
		timer -= 1
	
	#$Label.text = str(target) + "\n" + str(state)

func spawnArrow(arrowTarget):
	var proj = projScene.instance()
	get_parent().add_child(proj)
	proj.initialize((arrowTarget.translation + Vector3(0, 0.75, 0)), damage, speed, translation)

func _on_aggro_area_entered(area):
	target = area.get_parent().get_parent()
	targetFound = true
