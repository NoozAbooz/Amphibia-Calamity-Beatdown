extends Spatial

# this scripts calls into the scene:
#	Players
#	Camera
#   Overhead Light (for shadows
#	Pause Screen Scene
#	Game over screen/checker
#	Music


var AnneScene = preload("res://scenes/players/Anne.tscn")
var SashaScene = preload("res://scenes/players/Sasha.tscn")
var MarcyScene = preload("res://scenes/players/Marcy.tscn")


var camScene = preload("res://scenes/cam.tscn")
var pauseScene = preload("res://scenes/menus/pauseScreen.tscn")
var GOScene = preload("res://scenes/menus/gameOverScreen.tscn")
var lightScene = preload("res://scenes/downwardLight.tscn")

var player = AnneScene.instance()
var offset = Vector3.ZERO

var nextScene = camScene.instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	
	for i in range(0, 4):
		# skips player spawning if there is none
		if (pg.playerActive[i] == false):
			pg.playerAlive[i] = false
			continue
		# determines character choice and sets player variable
		match pg.playerCharacter[i]:
			"Anne":
				player = AnneScene.instance()
			"Marcy":
				player = MarcyScene.instance()
			"Sasha":
				player = SashaScene.instance()
			"Maggie":
				player = AnneScene.instance()
			_:
				player = AnneScene.instance()
		# Adds instance of player to tree
		get_parent().add_child(player)
		# Determines player position
		match i:
			0:
				offset = Vector3(-3, 0, -3)
			1:
				offset = Vector3(3, 0, -3)
			2:
				offset = Vector3(-3, 0, 3)
			3:
				offset = Vector3(3, 0, 3)
			_:
				offset = Vector3.ZERO
		# initializes player
		player.initialize(i, (translation + offset))
		# marks player as alive in global
		pg.playerAlive[i] = true
		
	# adds camera scene
	nextScene = camScene.instance()
	get_parent().add_child(nextScene)
	nextScene.get_node("Camera").initialize(translation)
	
	# adds pause scene
	nextScene = pauseScene.instance()
	get_parent().add_child(nextScene)
	nextScene.hide()
	
	# adds game over scene
	nextScene = GOScene.instance()
	get_parent().add_child(nextScene)
	nextScene.hide()
	
	# adds main light scene
	nextScene = lightScene.instance()
	get_parent().add_child(nextScene)
	
	# plays music
	soundManager.playMusic(pg.levelMusic)
	
	# sets player movement/cutscene flag so they can act
	pg.dontMove = false
	
	#removes spawner
	queue_free()
