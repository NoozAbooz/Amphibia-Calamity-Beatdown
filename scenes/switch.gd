extends Spatial

onready var anim = get_node("AnimationPlayer")
var vfxScene = preload("res://scenes/vfx.tscn")
var activated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("idle")
	$Label.text = str(activated)

func _on_hurtbox_area_entered(area):
	if (activated == false):
		var vfx = vfxScene.instance()
		get_parent().add_child(vfx)
		vfx.playEffect("hit", 0.5*(translation + area.get_parent().get_parent().translation))
		anim.play("flip")
		activated = true
		soundManager.playSound("switch")
	$Label.text = str(activated)


func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "flip"):
		anim.play("hit")
