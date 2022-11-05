extends StaticBody

export var bounceHeight = 65

onready var anim = $"AnimationPlayer"

export(int, "Green Mantis", "Red Mantis", "Spider", "Wasp", "Yellow Mantis", "Black Mantis", "Zapapede", "Robo") var mushColor


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func bounce():
	anim.play("bounce")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(_anim_name):
	anim.play("idle")
