extends Node2D

var blocking = false

var loader
var wait_frames
var time_max = 100 # msec
var current_scene

func _ready():
	pass # Replace with function body.

func loadLevel(scenePath, type = null):
	$AnimationPlayer.play("slideIn")
	yield(get_node("AnimationPlayer"), "animation_finished")
	#$AnimationPlayer.play("block")
	#get_tree().change_scene(scenePath)
	goto_scene(scenePath)
	#yield(get_tree(), "idle_frame")
	#$AnimationPlayer.play("slideOut")
	#yield(get_node("AnimationPlayer"), "animation_finished")
	#$AnimationPlayer.play("hide")

func endLevel():
	$AnimationPlayer.play("fadeWhite")
	yield(get_node("AnimationPlayer"), "animation_finished")
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	current_scene.queue_free()
	get_tree().change_scene("res://scenes/menus/tally.tscn")
	yield(get_tree(), "idle_frame")
	$AnimationPlayer.play("hide")
	
func goto_scene(path): # Game requests to switch to this scene.
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # Check for errors.
		return
	set_process(true)

	current_scene.queue_free() # Get rid of the old scene.

	# Start your "loading..." animation.
	get_node("AnimationPlayer").play("block")

	#wait_frames = 1

func _process(time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return

	# Wait for frames to let the "loading" animation show up.
#	if wait_frames > 0:
#		wait_frames -= 1
#		return

	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + time_max:
		# Poll your loader.
		var err = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			pass
			#update_progress()
		else: # Error during loading.
			#show_error()
			loader = null
			break

func set_new_scene(scene_resource):
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
	$AnimationPlayer.play("slideOut")



func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "slideOut"):
		get_node("AnimationPlayer").play("hide")
