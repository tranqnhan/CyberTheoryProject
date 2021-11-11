extends Node2D

var is_level_ended = false

func _process(delta):
	if (!is_level_ended):
		var enemies = get_tree().get_nodes_in_group("Enemy")
		if (enemies.size() == 0):
			is_level_ended = true
			print("Level Ended")
