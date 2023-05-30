extends StaticBody

enum {KB_WEAK, KB_STRONG, KB_ANGLED, KB_AIR, KB_STRONG_RECOIL, KB_AIR_UP, KB_WEAK_PIERCE, KB_STRONG_PIERCE, KB_ANGLED_PIERCE}

export var hitDamage = 20
var hitType = KB_ANGLED_PIERCE
var hitDir = Vector3(3, 50, 0)

#prevents enemies from trying to "target" the geyser and other crashes
var playerChar = "hazard"
var hitLanded = false
var hitSound = "hit4"

var maxDelay = 6
var minDelay = 3

var active = false

onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	anim.play("idle")
	var delay = rng.rand.randi_range(minDelay, maxDelay)
	$Timer.start(delay)


func activate(turnOn):
	active = turnOn
	if active:
		var delay = rng.rand.randi_range(minDelay, maxDelay)
		$Timer.start(delay)


func _on_Timer_timeout():
	if active:
		anim.play("steam")
