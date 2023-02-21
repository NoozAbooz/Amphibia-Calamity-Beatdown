extends Spatial


var playersInZone = 0

var dummy = null

var displayHPMax = 100
var displayHP = displayHPMax

#onready var anim = get_node("AnimationPlayer")
onready var despawnTimer = get_node("Timer")
onready var bar = get_node("2D elements")

var countingDown = false
var active = false

var yDes = -200

# Called when the node enters the scene tree for the first time.
func _ready():
	dummy = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# checks if active
	if (playersInZone > 0):
		despawnTimer.stop()
		active = true
	# sets value for health
	if dummy.isInState([0]):
		displayHP = displayHPMax
	get_node("2D elements/lifeBar").value = displayHP + 0.5
	#print(bar.position.y)
	# control system
	if active:
		yDes = 0
	else:
		yDes = -200
	if abs(bar.position.y - yDes) < 1:
		bar.position.y = yDes
	else:
		bar.position.y += (yDes - bar.position.y) * delta * 8

func dealDamage(hurtDamage):
	displayHP -= hurtDamage
	if (displayHP <= 0):
		displayHP = 0

func _on_Area_area_entered(area):
	if (playersInZone < 4):
		playersInZone += 1


func _on_Area_area_exited(area):
	if (playersInZone > 0):
		playersInZone -= 1
	if (playersInZone <= 0):
		despawnTimer.start(2)

func _on_Timer_timeout():
	active = false

func _on_AnimationPlayer_animation_finished(anim_name):
	pass
#	match anim_name:
#		"move_in":
#			anim.play("still_in")
#		"move_out":
#			justActivated = false
#			anim.play("still_out")
#		"still_in":
#			pass
#		"still_out":
#			pass
