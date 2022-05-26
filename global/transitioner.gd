extends Node2D


var blocking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func loadLevel(scenePath, type = null):
	$AnimationPlayer.play("slideIn")
	yield(get_node("AnimationPlayer"), "animation_finished")
	$AnimationPlayer.play("block")
	get_tree().change_scene(scenePath)
	yield(get_tree(), "idle_frame")
	$AnimationPlayer.play("slideOut")
	yield(get_node("AnimationPlayer"), "animation_finished")
	$AnimationPlayer.play("hide")

func endLevel():
	$AnimationPlayer.play("fadeWhite")
	yield(get_node("AnimationPlayer"), "animation_finished")
	get_tree().change_scene("res://scenes/menus/tally.tscn")
	yield(get_tree(), "idle_frame")
	$AnimationPlayer.play("hide")

func _on_AnimationPlayer_animation_finished(_anim_name):
	pass # Replace with function body.
