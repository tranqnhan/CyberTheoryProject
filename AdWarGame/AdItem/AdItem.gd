extends Control

func _on_Button_button_down():
	var tree = get_tree()
	if tree.has_group("Player"):
		var player = tree.get_nodes_in_group("Player")[0]
		player.close_ad()
	queue_free()
