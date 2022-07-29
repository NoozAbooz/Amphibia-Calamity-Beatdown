extends Area

enum {IDLE, WALK, RUN, JUMP, DJUMP, RISING, FALLING, BOUNCE, LAND, LANDC, A_L1, A_L2, A_L3, A_H1, A_H2, A_H3, A_AL1, A_AL2, A_AL3, A_AH1, A_AH2, A_AH3_LAUNCH, A_AH3_RISE, A_AH3_HIT, A_AH3_LAND, A_SL, A_SH, BLOCK, COUNTER, BLOCKHIT, HURT, HURTLAUNCH, HURTRISING, HURTFALLING, HURTFLOOR, KO}
enum {KB_WEAK, KB_STRONG, KB_ANGLED, KB_AIR, KB_STRONG_RECOIL, KB_AIR_UP, KB_WEAK_PIERCE, KB_STRONG_PIERCE, KB_ANGLED_PIERCE}

onready var player = get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
# sets up hitbox stats. Done here instead of in main player script so each player can have different hitboxes
	match player.state:
		
		A_L1:
			player.setHitBox(5, KB_WEAK, Vector3(1, 0, 0))
		A_L2:
			player.setHitBox(10, KB_WEAK, Vector3(1, 0, 0), "hit2")
		A_L3:
			player.setHitBox(10, KB_WEAK, Vector3(1, 0, 0))
			
		A_H1:
			player.setHitBox(12, KB_STRONG, Vector3(30, 25, 0), "hit3")
		A_H2:
			player.setHitBox(20, KB_STRONG, Vector3(7, 50, 0), "hit3")
		A_H3:
			if (player.comboReady):
				player.setHitBox(15, KB_ANGLED, Vector3(15, 35, 0), "none")
			else:
				player.setHitBox(2, KB_WEAK, Vector3(1, 0, 0), "hit5")
		
		A_AL1:
			player.setHitBox(8, KB_AIR, Vector3(1, 0, 0))
		A_AL2:
			player.setHitBox(8, KB_AIR, Vector3(1, 0, 0), "hit2")
		A_AL3:
			player.setHitBox(12, KB_AIR_UP, Vector3(1, 30, 0))
			
		A_AH1:
			player.setHitBox(20, KB_ANGLED, Vector3(40, 10, 0), "hit3")
		A_AH2:
			player.setHitBox(35, KB_STRONG_RECOIL, Vector3(30, -70, 0), "hit4")
		A_AH3_HIT:
			player.setHitBox(1, KB_STRONG, Vector3(0, -50, 0), "hit3")
		A_AH3_LAND:
			player.setHitBox(35, KB_ANGLED, Vector3(5, 50, 0), "hit3")
		
		A_SL:
			player.setHitBox(15, KB_STRONG, Vector3(-7, 40, 0), "hit2")
		A_SH:
			player.setHitBox(20, KB_STRONG_RECOIL, Vector3(30, 25, 0), "hit3")
			
		COUNTER:
			player.setHitBox(35, KB_ANGLED, Vector3(5, 40, 0), "hit4")
			
		HURTFLOOR:
			player.setHitBox(1, KB_ANGLED, Vector3(5, 15, 0))
			
		_:
			player.setHitBox(1, KB_ANGLED, Vector3(5, 15, 0))
	
