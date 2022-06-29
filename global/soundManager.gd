extends Node

onready var tweenMusic = get_node("Tween")
var oldDB = 0

var songList = []
var dBList = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# stores default volumes for music
	for song in get_node("music").get_children():
		songList.append(song.name)
		dBList.append(song.volume_db)
		#print(songList)
		#print(dbList)
		
func getDefaultVol(name):
	var index = songList.find(name)
	if index != -1:
		return dBList[index]
	else:
		return -6


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
	get_node("music/" + name).volume_db = getDefaultVol(name)
	#print("play: " + name)
	
func playMusicIfDiff(name):
	if (get_node("music/" + name).is_playing()):
		get_node("music/" + name).volume_db = getDefaultVol(name)
	else:
		stopMusic()
		get_node("music/" + name).volume_db = getDefaultVol(name)
		get_node("music/" + name).play()
	
func stopMusic():
	#get_tree().call_group("groupName", "stop")
	for song in $"music".get_children():
		song.stop()
		
# Used for pause screen
func pauseMusic():
	for song in get_node("music").get_children():
		song.set_stream_paused(true)
func resumeMusic():
	for song in get_node("music").get_children():
		song.set_stream_paused(false)
		
func FadeOutSong(name):
	var song = get_node("music/" + name)
	oldDB = song.volume_db
	tweenMusic.interpolate_property(song, "volume_db", oldDB, -40, 1.0)
	tweenMusic.start()

func _on_Tween_completed(object, _key):
	object.volume_db = oldDB
	object.stop()
	#print("reset")
	
