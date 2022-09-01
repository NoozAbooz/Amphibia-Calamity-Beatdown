extends Spatial

export(int, "Green Mantis", "Red Mantis", "Spider", "Wasp", "Yellow Mantis", "Black Mantis", "Zapapede", "Robo") var enemyNum

func _ready():
	pass

func _on_VisibilityNotifier_camera_entered(_camera):
	match enemyNum:
		0:
			var nextEnemy = nme.greenMantisScene.instance()
			get_parent().add_child(nextEnemy)
			nextEnemy.initialize(nme.greenMantis, translation, Vector3.ZERO, false, false, false)
		1:
			var nextEnemy = nme.redMantisScene.instance()
			get_parent().add_child(nextEnemy)
			nextEnemy.initialize(nme.redMantis, translation, Vector3.ZERO, false, false, false)
		2:
			var nextEnemy = nme.spiderScene.instance()
			get_parent().add_child(nextEnemy)
			nextEnemy.initialize(nme.spider, translation, Vector3.ZERO, false, false, false)
		3:
			var nextEnemy = nme.waspScene.instance()
			get_parent().add_child(nextEnemy)
			nextEnemy.initialize(nme.wasp, translation, Vector3.ZERO, false, false, false)
		4:
			var nextEnemy = nme.yellowMantisScene.instance()
			get_parent().add_child(nextEnemy)
			nextEnemy.initialize(nme.yellowMantis, translation, Vector3.ZERO, false, false, false)
		5:
			var nextEnemy = nme.blackMantisScene.instance()
			get_parent().add_child(nextEnemy)
			nextEnemy.initialize(nme.blackMantis, translation, Vector3.ZERO, false, false, false)
		_:
			var nextEnemy = nme.greenMantisScene.instance()
			get_parent().add_child(nextEnemy)
			nextEnemy.initialize(nme.greenMantis, translation, Vector3.ZERO, false, false, false)
	queue_free()
