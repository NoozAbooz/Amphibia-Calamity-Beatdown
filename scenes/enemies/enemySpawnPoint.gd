extends Spatial

export(int, "Green Mantis", "Red Mantis", "Spider", "Wasp") var enemyNum

func _ready():
	pass

func _on_VisibilityNotifier_camera_entered(camera):
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
		_:
			var nextEnemy = nme.greenMantisScene.instance()
			get_parent().add_child(nextEnemy)
			nextEnemy.initialize(nme.greenMantis, translation, Vector3.ZERO, false, false, false)
	queue_free()
