extends Spatial

onready var anim = $"AnimationPlayer"
	
func playEffect(effect, effect_position = Vector3.ZERO):
	#var cameraPos = get_viewport().get_camera().get_global_transform().origin
	#print("playing vfx")
	if (effect == "hit") or (effect == "coin") or (effect == "health"):
		translation = effect_position + Vector3(0, 1.6, 0)
		anim.play(effect)
	elif (effect == "go_arrow"):
		anim.play(effect)
	else:
		pass

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
