extends Control


var triggered = false
var buttonsReady = false
var loading = false


# Called when the node enters the scene tree for the first time.
func _ready():
	triggered = false
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (triggered == false) and (pg.playerAlive == [false, false, false, false]):
		self.show()
		triggered = true
		get_parent().get_node("pauseScreen").queue_free()
		showGameOver()
	if (buttonsReady == false):
		$buttonRestart.grab_focus()
		
func showGameOver():
	soundManager.playMusic("go")
	$AnimationPlayer.play("fadeIn")
	yield(get_node("AnimationPlayer"), "animation_finished")
	buttonsReady = true
	$buttonRestart.grab_focus()


func _on_AnimationPlayer_animation_finished(_anim_name):
	pass # Replace with function body.


func _on_buttonMap_pressed():
	if loading:
		return
	if (buttonsReady):
		loading = true
		pg.backToMapLose()


func _on_buttonRestart_pressed():
	if loading:
		return
	if (buttonsReady):
		loading = true
		tran.loadLevel("res://maps/" + pg.levelName + ".tscn")
