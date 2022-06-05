extends Node

onready var greenMantisScene = preload("res://scenes/enemies/greenMantis.tscn")
onready var redMantisScene = preload("res://scenes/enemies/redMantis.tscn")
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
	
var redMantis
var greenMantis
var spider
var wasp


# Called when the node enters the scene tree for the first time.
func _ready():
	# Green Mantis Enemy Stats
	greenMantis = stats.new()
	greenMantis.spd   = 10
	greenMantis.dam   = 10
	greenMantis.hlth  = 100
	greenMantis.wgt   = 0
	greenMantis.maxC  = 8
	greenMantis.minC  = 4
	greenMantis.oddsD = 0.1
	greenMantis.oddsK = 0.2
	greenMantis.weakA = false
	
	# Red Mantis Enemy Stats
	redMantis = stats.new()
	redMantis.spd = 4
	redMantis.dam = 15
	redMantis.hlth = 180
	redMantis.wgt = 2
	redMantis.maxC = 12
	redMantis.minC = 8
	redMantis.oddsD = 0.25
	redMantis.oddsK = 0.2
	redMantis.weakA = false

	# Spider Enemy Stats
	spider = stats.new()
	spider.spd = 12
	spider.dam = 1
	spider.hlth = 0
	spider.wgt = 0
	spider.maxC = 3
	spider.minC = 1
	spider.oddsD = 0.05
	spider.oddsK = 0.2
	spider.weakA = true
	
	# wasp Enemy Stats
	wasp = stats.new()
	wasp.spd = 5
	wasp.dam = 5
	wasp.hlth = 30
	wasp.wgt = 0
	wasp.maxC = 3
	wasp.minC = 1
	wasp.oddsD = 0.05
	wasp.oddsK = 0.2
	wasp.weakA = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
