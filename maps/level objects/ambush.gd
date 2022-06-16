extends Spatial

# tells the object which "ambush" to play
export var ambushName = "playgroundAmbush1"

var enemyList = null
var cam = null
var vfxScene = preload("res://scenes/vfx.tscn")

var startingKills = 0
var killsNeeded = 0
var waveNumber = 0
var totalWaves = 0
var wave

var timer = 0

enum {INACTIVE, WAIT, WAIT2, PREP, SPAWN, FIGHT}
var state = INACTIVE
var nextState = INACTIVE


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match state:
		INACTIVE:
			pass
		WAIT:
			if (waveNumber >= totalWaves):
				nextState = WAIT
				exitAmbush()
			else:
				nextState = WAIT2
				timer = 0
		WAIT2:
			if (timer >= 60):
				nextState = PREP
			else:
				nextState = WAIT2
		PREP:
			startingKills = pg.kills
			wave = enemyList.get("wave" + str(waveNumber))
			if typeof(wave) == TYPE_INT:
				killsNeeded = wave
			else:
				killsNeeded = len(wave)
			timer = 0
			nextState = FIGHT
		FIGHT:
			if typeof(wave) != TYPE_INT:
				for enemy in wave:
					if (timer > enemy.spawnTime):
						spawn(enemy)
						enemy.spawnTime = 99999 # prevents repeated spawns of the same enemy
			if ((pg.kills - startingKills) >= killsNeeded):
				nextState = WAIT
				waveNumber += 1
			else:
				nextState = FIGHT
		_:
			pass
	state = nextState
	if (timer < 600):
		timer += 1


func exitAmbush():
	# frees camera
	cam.inAmbush = false
	# makes visual effect
	var vfx = vfxScene.instance()
	get_parent().add_child(vfx)
	vfx.playEffect("go_arrow")
	# deletes ambush node
	queue_free()

func _on_cameraTrigger_area_entered(area):
	# loads the chosen wave/enemy list (a .gd file)
	enemyList = load("res://maps/ambushes/" + ambushName + ".gd").new()
	#enemyList = load("res://maps/ambushes/" + str(ambushName) + ".gd")
	# Sets the state machine in motion
	nextState = WAIT
	# loads variables from enemyList
	totalWaves = enemyList.get("numWaves")
	waveNumber = 0
	# Camera positioning
	cam = area.get_parent()
	cam.inAmbush = true
	cam.ambushTarget = translation + Vector3(0, 0, 10)
	cam.ambushSpawnPoint = translation + Vector3(0, 5, 0)
	get_node("cameraTrigger").queue_free()
	
func spawn(enemy):
	var nextEnemy = enemy.scene.instance()
	get_parent().add_child(nextEnemy)
	nextEnemy.initialize(enemy.type, (enemy.loc + translation), enemy.vel, false, true)
	nextEnemy.ambushEnemy = true
	
	
#	nextEnemy = nme.greenMantisScene.instance()
#	get_parent().add_child(nextEnemy)
#	nextEnemy.initialize(nme.greenMantis, translation, Vector3(0, 20, 0), true, true)
#	nextEnemy = nme.greenMantisScene.instance()
#	get_parent().add_child(nextEnemy)
#	nextEnemy.initialize(nme.greenMantis, translation + Vector3(1, 0, -1), Vector3(10, 20, -10), true, true)
#	nextEnemy = nme.greenMantisScene.instance()
#	get_parent().add_child(nextEnemy)
#	nextEnemy.initialize(nme.greenMantis, translation + Vector3(-1, 0, -1), Vector3(-10, 20, -10), true, true)
