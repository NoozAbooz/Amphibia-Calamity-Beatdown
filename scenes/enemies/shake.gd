extends AnimationPlayer


onready var enemyNode = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	if (enemyNode.justHurt):
		play("shake")
		seek(0)

func _on_shake_animation_finished(anim_name):
	play("normal")
