extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	soundManager.playMusicIfDiff("test")
	$startButton.grab_focus()
	_on_lockButton_toggled(false)
	$lockButton.pressed = false
	_on_hitboxButton_toggled(false)
	$hitboxButton.pressed = false
	
	# Discord integration
	update_activity()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_startButton_pressed():
	#get_tree().change_scene("res://scenes/menus/mapOpen.tscn")
	tran.loadLevel("res://scenes/menus/mapOpen.tscn")


func _on_lockButton_toggled(button_pressed):
	if (button_pressed):
		$lockButton/Label.text = "Disable All Upgrades"
		pg.healthUpgrades = 3 # 20 per upgrade, max 3
		pg.livesUpgrades  = 3 # 1 life per upgrade, max 3
		pg.damageUpgrades = 3 # 20% per upgrade, max 3
		pg.luckUpgrades   = 3 # increase coin drop by 1 and drop chances by 5%
		pg.hasSpin    = true
		pg.hasSlide   = true
		pg.hasSpike   = true
		pg.hasDJ      = true
		pg.hasCounter = true
		
	else:
		$lockButton/Label.text = "Enable All Upgrades"
		pg.healthUpgrades = 0 # 20 per upgrade, max 3
		pg.livesUpgrades  = 0 # 1 life per upgrade, max 3
		pg.damageUpgrades = 0 # 20% per upgrade, max 3
		pg.luckUpgrades   = 0 # increase coin drop by 1 and drop chances by 5%
		pg.hasSpin    = false
		pg.hasSlide   = false
		pg.hasSpike   = false
		pg.hasDJ      = false
		pg.hasCounter = false
		
	print("Unlocks changed!")

func _on_hitboxButton_toggled(button_pressed):
	if (button_pressed):
		$hitboxButton/Label.text = "Disable Hitboxes"
		get_tree().set_debug_collisions_hint(true)
		
	else:
		$hitboxButton/Label.text = "Enable Hitboxes"
		get_tree().set_debug_collisions_hint(false)
		
	print("hitboxes changed!")

func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_details("Currently on:")
	activity.set_state("Main Menu")

	var assets = activity.get_assets()
	assets.set_large_image("main")
	assets.set_large_text(":smug_anne:")
	assets.set_small_image("mantis_stand")
	assets.set_small_text("Angy mantis")
	
	var timestamps = activity.get_timestamps()
	timestamps.set_start(OS.get_unix_time())

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))
