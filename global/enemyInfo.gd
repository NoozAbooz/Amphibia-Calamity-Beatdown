extends Node

onready var greenMantisScene = preload("res://scenes/enemies/greenMantis.tscn")
onready var yellowMantisScene = preload("res://scenes/enemies/yellowMantis.tscn")
onready var blackMantisScene = preload("res://scenes/enemies/blackMantis.tscn")
onready var redMantisScene = preload("res://scenes/enemies/bossMantis.tscn")
onready var spiderScene = preload("res://scenes/enemies/spider.tscn")
onready var waspScene = preload("res://scenes/enemies/wasp.tscn")

# stores common enemy stats
class stats:
	var spd = 8
	var dam = 10
	var hlth = 100
	var wgt = 0
	var maxC = 5 #5
	var minC = 2 #2
	var oddsD = 0.1 #0.1
	var oddsK = 0.2 #0.2
	var weakA = false
	var attackWaitTime = 70 # represents the number of frames waited after an attack before acting. Unused on flying enemies.
	var color = 0
	
# Ambush Enemies
class ambEnemy:
	var scene
	var type
	var loc
	var vel
	var spawnTime
	func _init(scene, type, loc, vel, spawnTime):
		self.scene = scene
		self.type = type
		self.loc = loc
		self.vel = vel
		self.spawnTime = spawnTime
	
var greenMantis
var yellowMantis
var blackMantis
var redMantis
var spider
var wasp


# Called when the node enters the scene tree for the first time.
func _ready():
	# Green Mantis Enemy Stats
	greenMantis = stats.new()
	greenMantis.spd   = 9
	greenMantis.dam   = 10
	greenMantis.hlth  = 100
	greenMantis.wgt   = 0
	greenMantis.maxC  = 6
	greenMantis.minC  = 2
	greenMantis.oddsD = 0.1
	greenMantis.oddsK = 0.2
	greenMantis.weakA = false
	greenMantis.attackWaitTime = 60
	greenMantis.color = 0
	
	# yellow Mantis Enemy Stats
	yellowMantis = stats.new()
	yellowMantis.spd   = 7
	yellowMantis.dam   = 15
	yellowMantis.hlth  = 125
	yellowMantis.wgt   = 0
	yellowMantis.maxC  = 8
	yellowMantis.minC  = 3
	yellowMantis.oddsD = 0.1
	yellowMantis.oddsK = 0.2
	yellowMantis.weakA = false
	yellowMantis.attackWaitTime = 60
	yellowMantis.color = 1
	
	# black Mantis Enemy Stats
	blackMantis = stats.new()
	blackMantis.spd   = 12
	blackMantis.dam   = 12
	blackMantis.hlth  = 85
	blackMantis.wgt   = 0
	blackMantis.maxC  = 8
	blackMantis.minC  = 3
	blackMantis.oddsD = 0.1
	blackMantis.oddsK = 0.2
	blackMantis.weakA = false
	blackMantis.attackWaitTime = 30
	blackMantis.color = 2
	
	# Red Mantis Enemy Stats
	redMantis = stats.new()
	redMantis.spd = 7
	redMantis.dam = 18
	redMantis.hlth = 180
	redMantis.wgt = 2
	redMantis.maxC = 12
	redMantis.minC = 8
	redMantis.oddsD = 0.25
	redMantis.oddsK = 0.2
	redMantis.weakA = false
	redMantis.attackWaitTime = 45
	redMantis.color = 3

	# Spider Enemy Stats
	spider = stats.new()
	spider.spd = 12
	spider.dam = 1
	spider.hlth = 0
	spider.wgt = 0
	spider.maxC = 2
	spider.minC = 1
	spider.oddsD = 0.05
	spider.oddsK = 0.2
	spider.weakA = true
	spider.attackWaitTime = 70
	spider.color = 0
	
	# wasp Enemy Stats
	wasp = stats.new()
	wasp.spd = 5
	wasp.dam = 5
	wasp.hlth = 30
	wasp.wgt = 0
	wasp.maxC = 2
	wasp.minC = 1
	wasp.oddsD = 0.05
	wasp.oddsK = 0.2
	wasp.weakA = false
	wasp.attackWaitTime = 70
	wasp.color = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
