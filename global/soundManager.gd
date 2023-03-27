extends Node

onready var tweenMusic = get_node("Tween")
var oldDB = 0

var songList = []
var dBList = []

var masterBusIndex

var masterVolume = 0

var follow2DCam = false
var tempPos = Vector2.ZERO
var tempScale = Vector2(1,1)

var alreadyStopped = false # a flag to insure that ending a tween and starting a new song both don't stop()

var inCave = false
var caveReverb = AudioEffectReverb.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# stores default volumes for music
	for song in get_node("music").get_children():
		songList.append(song.name)
		dBList.append(song.volume_db)
		#print(songList)
		#print(dbList)
	masterBusIndex = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(masterBusIndex, masterVolume)
	# preps cave reverb
	caveReverb.wet = 1
	caveReverb.dry = 0.2
	caveReverb.room_size = 0.2
	caveReverb.hipass = 0.3

func _process(_delta):
	# checks for keyboard presses for options
	if(Input.is_action_just_pressed("fullscreen") == true):
		OS.set_window_fullscreen(!OS.window_fullscreen)
	if(Input.is_action_just_pressed("mute") == true):
		AudioServer.set_bus_mute(masterBusIndex, !AudioServer.is_bus_mute(masterBusIndex))
		displayVolume()
	if(Input.is_action_just_pressed("vol+") == true):
		updateVolume(2)
		displayVolume()
	if(Input.is_action_just_pressed("vol-") == true):
		updateVolume(-2)
		displayVolume()
	# positions volume meter
	if follow2DCam:
		pass
		#self.scale = tempScale
		#self.position = tempPos - Vector2((self.scale.x * 1280 * 0.5), (self.scale.y * 720 * 0.5))
	else:
		self.scale = Vector2(1,1)
		self.position = Vector2.ZERO

		
func displayVolume():
	if (AudioServer.is_bus_mute(masterBusIndex)):
		$volumeLabel.text = "V O L U M E \n( M U T E )"
	else:
		$volumeLabel.text = "V O L U M E \n" + getVolumeString()
	$animVol.play("display")
	$animVol.seek(0)

func getVolumeString():
	var returnString = "|"
	for i in range(-20, 10, 2):
		if (i < masterVolume):
			returnString += "|"
		else:
			returnString += "-"
	return returnString

func updateVolume(amount):
	masterVolume += amount
	if masterVolume >= 10:
		masterVolume = 10
	if masterVolume <= -20:
		masterVolume = -20
	AudioServer.set_bus_volume_db(masterBusIndex, masterVolume)
	#print(masterVolume)

func addEffect(type = "none"):
	masterBusIndex = AudioServer.get_bus_index("Master")
	match type:
		"cave":
			clearEffects()
			AudioServer.add_bus_effect(masterBusIndex, caveReverb)
		"none":
			clearEffects()
		_:
			clearEffects()
			
func clearEffects():
	var numEffects = AudioServer.get_bus_effect_count(masterBusIndex)
	for i in range(0, numEffects):
		AudioServer.remove_bus_effect(masterBusIndex, 0)
	
func getDefaultVol(name):
	var index = songList.find(name)
	if index != -1:
		return dBList[index]
	else:
		return -6


func playSound(name):
	if (name == "none"):
		return
	elif ((name == "hit5") or (name == "talk")) and (get_node("sfx/" + name).is_playing()): 
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
		tweenMusic.stop_all()
		get_node("music/" + name).volume_db = getDefaultVol(name)
	else:
		stopMusic()
		get_node("music/" + name).volume_db = getDefaultVol(name)
		get_node("music/" + name).play()
	
func stopMusic(songName = null):
	#print("Stop")
	alreadyStopped = true
	if (songName != null):
		get_node("music/" + songName).stop()
		return
	for song in $"music".get_children():
		song.stop()
	return
		
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
	tweenMusic.interpolate_property(song, "volume_db", oldDB, (oldDB - 40), 2.0)
	tweenMusic.start()
	alreadyStopped = false
	#print("tweenStart")

func _on_Tween_completed(object, _key):
	#print("tweenEnd")
	if not alreadyStopped:
		object.stop()
	
