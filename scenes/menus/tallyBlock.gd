extends Control

#var character = "Anne"
var coppers = 0
#var lives = 0
onready var faces = get_node("faces")

var colorAnne = Color8(55, 150, 223)
var colorSasha = Color8(215, 40, 119)
var colorMarcy = Color8(152, 186, 62)
var colorSprig = Color8(76, 102, 255)
var colorMaggie = Color8(217, 76, 255)
var colorGrime = Color8(255, 158, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimationPlayer").play("idle")

func initialize(character, lives, coins, alive, playerNumber):
	# sets up labels and faces
	faces.play(character)
	coppers = coins
	get_node("labelLives").text = "Lives: " + str(lives)
	get_node("labelCoins").text = "Coppers: " + str(coppers)
	# sets panel color
	match character:
		"Anne":
			get_node("bg/colorBG").color = colorAnne
		"Sasha":
			get_node("bg/colorBG").color = colorSasha
		"Marcy":
			get_node("bg/colorBG").color = colorMarcy
		"Sprig":
			get_node("bg/colorBG").color = colorSprig
		"Maggie":
			get_node("bg/colorBG").color = colorMaggie
		"Grime":
			get_node("bg/colorBG").color = colorGrime
		_:
			get_node("bg/colorBG").color = Color8(10, 10, 10)
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
