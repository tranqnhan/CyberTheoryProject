extends HBoxContainer

func _ready():
	var tree = get_tree()
	if tree.has_group("Player"):
		var player = tree.get_nodes_in_group("Player")[0]
		player.connect("player_take_dmg", self, "_on_health_change")
		$HealthBar.value = player.health

func _on_health_change(health, damage):
	$HealthBar.value = health
