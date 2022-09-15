extends Spatial

export var switchedObjectName = "bridge"
onready var anim = get_node("AnimationPlayer")
onready var animBridge = get_node(switchedObjectName + "/AnimationPlayer")
var vfxScene = preload("res://scenes/vfx.tscn")
var activated = false

var cam = null
export var moveCamera = false
export var camLocation = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("idle")
	animBridge.play("idle")

func _on_hurtbox_area_entered(area):
	if (activated == false):
		# vfx
		var vfx = vfxScene.instance()
		get_parent().add_child(vfx)
		vfx.playEffect("hit", 0.5*(translation + area.get_parent().get_parent().translation))
		# switch/bridge animation
		anim.play("flip")
		animBridge.play("move")
		# activation flag
		activated = true
		# sfx
		soundManager.playSound("switch")
		# camera
		if (moveCamera):
			cam = get_node("/root/" + pg.levelName + "/camera_pivot/Camera")
			#cam.inAmbush = true
			cam.cutsceneTarget = camLocation
			#cam.ambushTarget   = camLocation
			cam.ambushSpawnPoint = translation + Vector3(0, 5, 0)

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "flip"):
		anim.play("hit")
		
		
func startCutscene():
	cam.startCutscene()
func endCutscene():
	cam.inAmbush = false
	cam.endCutscene()
