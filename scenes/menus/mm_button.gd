extends TextureButton

export(int, "start", "controls", "credits", "exit") var type

onready var buttonText = get_node("button/text")
onready var buttonColor = get_node("button")
onready var buttonIcon = get_node("button/icon")
onready var mask = get_node("button/mask")

# Called when the node enters the scene tree for the first time.
func _ready():
	match type:
		0:
			buttonText.text = "START"
			buttonColor.play("blue")
			buttonIcon.play("sword")
			mask.range_item_cull_mask = 32
			buttonIcon.light_mask = 32
		1:
			buttonText.text = "CONTROLS"
			buttonColor.play("blue")
			buttonIcon.play("remote")
			mask.range_item_cull_mask = 64
			buttonIcon.light_mask = 64
		2:
			buttonText.text = "CREDITS"
			buttonColor.play("blue")
			buttonIcon.play("remote")
			mask.range_item_cull_mask = 128
			buttonIcon.light_mask = 128
		3:
			buttonText.text = "EXIT"
			buttonColor.play("blue")
			buttonIcon.play("sword")
			mask.range_item_cull_mask = 256
			buttonIcon.light_mask = 256
		_:
			buttonText.text = "ERROR"
			buttonColor.play("blue")
			buttonIcon.play("remote")


func _process(delta):
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "focus_start"):
		$AnimationPlayer.play("focus_loop")
		

func _on_mm_button_focus_entered():
	$AnimationPlayer.play("focus_start")
	

func _on_mm_button_focus_exited():
	$AnimationPlayer.play("idle")
