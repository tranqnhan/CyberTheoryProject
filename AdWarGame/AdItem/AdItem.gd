extends Control

var ad1 = "res://Assets/characters/day2images/enemyad.png"
var ad2 = "res://Assets/characters/day3/ad2.png"
var ad3 = "res://Assets/characters/day3/ad3.png"

func _ready():
	var r = rand_range(0,3)
	if(r < 1):
		$TextureRect.texture = load(ad1)
	elif r < 2:
		$TextureRect.texture = load(ad2)
	else:
		$TextureRect.texture = load(ad3)

func _on_Button_button_down():
	var tree = get_tree()
	if tree.has_group("Player"):
		var player = tree.get_nodes_in_group("Player")[0]
		player.close_ad()
	queue_free()
