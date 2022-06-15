extends Node

onready var tweenMusic = get_node("Tween")
var oldDB = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func playSound(name):
	if (name == "none"):
		return
	elif (name == "hit5") and (get_node("sfx/" + name).is_playing()): 
		# sounds in this group will not play over themselves
		return
	else:
		get_node("sfx/" + name).play()
	
func pitchSound(name, pitch, volume = 0):
	get_node("sfx/" + name).pitch_scale = pitch
	get_node("sfx/" + name).volume_db = volume
	
func playMusic(name):
	stopMusic()
	get_node("music/" + name).play()
	
func playMusicIfDiff(name):
	if (get_node("music/" + name).is_playing()):
		return
	else:
		stopMusic()
		get_node("music/" + name).play()
	
func stopMusic():
	#get_tree().call_group("groupName", "stop")
	for song in $"music".get_children():
		song.stop()
		
func FadeOutSong(name):
	var song = get_node("music/" + name)
	oldDB = song.volume_db
	tweenMusic.interpolate_property(song, "volume_db", oldDB, -80, 2.0)
	tweenMusic.start()

func _on_Tween_completed(object, key):
	object.stop()
	object.volume_db = oldDB
