extends Spatial

# this scripts calls into the scene:
#	Players
#	Camera
#   Overhead Light (for shadows
#	Pause Screen Scene
#	Game over screen/checker
#	Music


var cartScene  = preload("res://scenes/players/minecart.tscn")

var camScene = preload("res://scenes/camMinecart.tscn")
var pauseScene = preload("res://scenes/menus/pauseScreen.tscn")
var GOScene = preload("res://scenes/menus/gameOverScreen.tscn")
var lightScene = preload("res://scenes/downwardLight.tscn")

var player = cartScene.instance()
var offset = Vector3.ZERO
var spawnerLocation = Vector3.ZERO

var nextScene = camScene.instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	pg.karting = true


func _process(_delta):
	# determines character choice and sets player variable
	player = cartScene.instance()
	# Adds instance of player to tree
	get_parent().add_child(player)
	# initializes player
	player.initialize(translation)
		
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
	soundManager.playMusic("minecart")
	
	# sets player movement/cutscene flag so they can act
	pg.dontMove = false
	
	# sets level in discord thing
	discordRPC.updateLevel(pg.levelNameDisc)
	
	#removes spawner
	queue_free()
