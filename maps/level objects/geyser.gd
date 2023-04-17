extends StaticBody

enum {KB_WEAK, KB_STRONG, KB_ANGLED, KB_AIR, KB_STRONG_RECOIL, KB_AIR_UP, KB_WEAK_PIERCE, KB_STRONG_PIERCE, KB_ANGLED_PIERCE}

export var hitDamage = 20
var hitType = KB_ANGLED_PIERCE
var hitDir = Vector3(3, 50, 0)

#prevents enemies from trying to "target" the geyser and other crashes
var playerChar = "hazard"
var hitLanded = false
var hitSound = "hit4"

var maxDelay = 5
var minDelay = 2.5

# set to negative to pick random initial delay (default behavior)
export var skipFirstDelay = false

export var initialDelay = -1.0

export var constSpray = false

export var enemiesImmune = false

var active = false

onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if constSpray:
		anim.play("steamConst")
	if enemiesImmune:
		get_node("hitboxes/hitbox").set_collision_layer_bit(3, false)


func _on_AnimationPlayer_animation_finished(anim_name):
	anim.play("idle")
	var delay = rng.rand.randi_range(minDelay, maxDelay)
	$Timer.start(delay)


func _on_VisibilityNotifier_camera_entered(camera):
	active = true
	var delay = 0
	if (initialDelay < 0):
		delay = rng.rand.randi_range(0.25, 1)
	else:
		delay = initialDelay
	if not constSpray:
		$Timer.start(delay)
	if skipFirstDelay:
		anim.play("warn")


func _on_VisibilityNotifier_camera_exited(camera):
	active = false
	if not constSpray:
		anim.play("idle")
	$Timer.stop()

func _on_Timer_timeout():
	if active:
		anim.play("steam")
	if skipFirstDelay:
		anim.seek(0.9833)
