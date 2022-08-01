extends Area


# This script zeros out the ambush kills count (pg.kills)
# Place this just before ambushes with enemies that exist on the map (like
# in the first stage) so that killing one of these enemies BEFORE triggering
# the ambush will not cause a soft lock

func _on_killsReset_area_entered(area):
	pg.kills = 0
	queue_free()
