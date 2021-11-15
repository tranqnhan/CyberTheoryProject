extends Node



var is_level_ended = false
var pathWin = "res://Screens/Next2_Level_Screen/Next_Level.tscn"
func _process(delta):
	if (!is_level_ended):
		var enemies = get_tree().get_nodes_in_group("Enemy")
		if (enemies.size() == 0):
			is_level_ended = true
			get_tree().change_scene(pathWin)
