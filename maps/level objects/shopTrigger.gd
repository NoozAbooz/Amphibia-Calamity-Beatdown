extends Spatial

onready var zone = get_node("zone")

export var destinationSceneName = "shopMoves"

func _ready():
	pass # Replace with function body.

func _on_Area_area_entered(area):
	# removes area detection for goal
	zone.queue_free()
	# removes ability to pause
	get_parent().get_node("pauseScreen").queue_free()
	# prevents player actions
	pg.dontMove = true
	# stops music
	soundManager.FadeOutSong(pg.levelMusic)
	# loads shop scene
	tran.loadLevel("res://scenes/menus/" + destinationSceneName + ".tscn")
