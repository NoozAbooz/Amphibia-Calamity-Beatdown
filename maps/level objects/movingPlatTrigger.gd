extends VisibilityNotifier


onready var anim = get_parent().get_node("AnimationPlayer")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisibilityNotifier_camera_entered(camera):
	anim.play("move")
