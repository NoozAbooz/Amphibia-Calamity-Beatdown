extends Area

export(int, "Turn Off Music", "Turn On Music") var function

export var track = "default"

var resetBox = null
onready var col = get_node("CollisionShape")

func _ready():
	resetBox = get_node_or_null("reset")
	if (resetBox != null):
		resetBox.connect("area_entered", self, "_on_reset_area_entered")

func _on_musicTrigger_area_entered(area):
	# disables the trigger is a reset box exists
	if (resetBox != null):
		col.disabled = true
	if (track == "default"):
		track = pg.levelMusic
	match function:
		0:
			soundManager.FadeOutSong(track)
		1:
			soundManager.playMusicIfDiff(track)
			
func _on_reset_area_entered(_area):
	col.disabled = false
