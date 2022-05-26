extends KinematicBody


onready var anim = get_node("AnimationPlayer")
var vfxScene = preload("res://scenes/vfx.tscn")
var activated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("idle")


func _process(_delta):
	if (activated == false) and (get_parent().activated == true):
		activated = true
		anim.play("move")
	


func _on_AnimationPlayer_animation_finished(_anim_name):
	anim.play("done")
