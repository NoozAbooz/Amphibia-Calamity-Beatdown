extends Control

#var character = "Anne"
var coppers = 0
#var lives = 0
onready var faces = get_node("faces")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimationPlayer").play("idle")

func initialize(character, lives, coins, alive, playerNumber):
	# sets up labels and faces
	faces.play(character)
	coppers = coins
	get_node("labelLives").text = "Lives: " + str(lives)
	get_node("labelCoins").text = "Coppers: " + str(coppers)
	# Corrections if player was defeated
	if not alive:
		faces.play(character + "D")
		coppers = 0
		get_node("labelLives").text = "Lives: 0"
		get_node("labelCoins").text = "Coppers: " + str(coppers)
	# corrections if using cheats
	if lives >= 10:
		get_node("labelLives").text = "Lives: X"
	# positions tally panel
	self.anchor_left = playerNumber * 0.25
	# slides panel up
	get_node("AnimationPlayer").play("slide" + str(playerNumber))
	
func _process(_delta):
	get_node("labelCoins").text = "Coppers: " + str(coppers)
