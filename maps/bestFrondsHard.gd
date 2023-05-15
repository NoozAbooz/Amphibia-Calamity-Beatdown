extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pg.hasCounter = true
	pg.hasSpin = true
	pg.hasSlide   = true
	pg.hasAirSpin = true
	pg.hasDJ      = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
