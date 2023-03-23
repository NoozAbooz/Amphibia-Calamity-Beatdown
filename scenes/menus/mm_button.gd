extends Button

export(int, "start", "controls", "credits", "exit") var type

onready var buttonText = get_node("button/text")
onready var buttonColor = get_node("button")
onready var buttonIcon = get_node("button/icon")
onready var mask = get_node("button/mask")

export var defaultButton = false

# Called when the node enters the scene tree for the first time.
func _ready():
	match type:
		0:
			buttonText.text = "KEY_MM_START"
			buttonColor.play("blue")
			buttonIcon.play("sword")
			mask.range_item_cull_mask = 32
			buttonIcon.light_mask = 32
		1:
			buttonText.text = "KEY_MM_CONTROLS"
			buttonColor.play("green")
			buttonIcon.play("remote")
			mask.range_item_cull_mask = 64
			buttonIcon.light_mask = 64
		2:
			buttonText.text = "KEY_MM_CREDITS"
			buttonColor.play("gray")
			buttonIcon.play("book")
			mask.range_item_cull_mask = 128
			buttonIcon.light_mask = 128
		3:
			buttonText.text = "KEY_MM_EXIT"
			buttonColor.play("pink")
			buttonIcon.play("fwagon")
			mask.range_item_cull_mask = 256
			buttonIcon.light_mask = 256
		_:
			buttonText.text = "ERROR"
			buttonColor.play("blue")
			buttonIcon.play("remote")


func _process(delta):
	if defaultButton and waitingOnTitleIntro():
			$AnimationPlayer.play("focus_loop")

func waitingOnTitleIntro():
	return get_parent().get_parent().waitingOnIntro
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "focus_start"):
		$AnimationPlayer.play("focus_loop")
		

func _on_mm_button_focus_entered():
	if waitingOnTitleIntro():
		if defaultButton:
			$AnimationPlayer.play("focus_loop")
		else:
			$AnimationPlayer.play("idle")
		return
	if is_hovered():
		$AnimationPlayer.play("focus_loop")
	else:
		$AnimationPlayer.play("focus_start")
	

func _on_mm_button_focus_exited():
	if waitingOnTitleIntro():
		if defaultButton:
			$AnimationPlayer.play("focus_loop")
		else:
			$AnimationPlayer.play("idle")
		return
	if is_hovered():
		$AnimationPlayer.play("focus_loop")
	else:
		$AnimationPlayer.play("idle")


func _on_mm_button_mouse_entered():
	if waitingOnTitleIntro():
		if defaultButton:
			$AnimationPlayer.play("focus_loop")
		else:
			$AnimationPlayer.play("idle")
		return
	if has_focus():
		$AnimationPlayer.play("focus_loop")
	else:
		$AnimationPlayer.play("focus_start")


func _on_mm_button_mouse_exited():
	if waitingOnTitleIntro():
		if defaultButton:
			$AnimationPlayer.play("focus_loop")
		else:
			$AnimationPlayer.play("idle")
		return
	if has_focus():
		$AnimationPlayer.play("focus_loop")
	else:
		$AnimationPlayer.play("idle")
