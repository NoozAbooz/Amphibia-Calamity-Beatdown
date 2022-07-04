extends Spatial

onready var anim = $"anim"
onready var anim2 = $"anim2"
onready var zone = $"zone"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("idle")
	anim2.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_zone_area_entered(area):
	anim2.play("fly")
	# removes area detection for goal
	zone.queue_free()
	# removes ability to pause
	get_parent().get_node("pauseScreen").queue_free()
	# updates global player values from player nodes
	pg.playerLives = [0, 0, 0, 0]
	pg.playerCoins = [0, 0, 0, 0]
	for i in range(0, 4):
		if has_node("../Player" + str(i)):
			pg.playerLives[i] = get_node("../Player" + str(i)).lives
			pg.playerCoins[i] = get_node("../Player" + str(i)).coins
	# runs end level function in playerGlobals
	pg.endLevel()
