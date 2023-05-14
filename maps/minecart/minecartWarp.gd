extends Area


var loading = false
export var destinationLevel = "test"

# NOTE: MINECART ENTRANCE/EXIT/WARP MUST BE AN IMEDIATE CHILD OF THE MAP NODE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func storePlayerInfo():
	# updates global player values from minecart node
	if has_node("../minecart"):
		pg.playerLives = get_node("../minecart").playerLives
		pg.playerCoins = get_node("../minecart").playerCoins
		pg.playerHealth = get_node("../minecart").playerHealth
		return
	# updates global player values from player nodes
	for i in range(0, 4):
		if has_node("../Player" + str(i)):
			pg.playerLives[i] = get_node("../Player" + str(i)).lives
			pg.playerCoins[i] = get_node("../Player" + str(i)).coins
			pg.playerHealth[i] = get_node("../Player" + str(i)).hp
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_minecartWarp_area_entered(area):
	storePlayerInfo()
	if (loading == false):
		loading = true
		pg.karting = true
		tran.loadLevel("res://maps/" + destinationLevel + ".tscn")
