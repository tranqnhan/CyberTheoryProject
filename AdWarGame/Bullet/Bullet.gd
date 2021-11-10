extends Area2D

var direction : Vector2 = Vector2.ZERO # default direction
var speed : float = 200 #put your rocket speed
var damage = 0;

func init(gun_damage, currentPos : Vector2, fromPos : Vector2, toPos : Vector2):
	damage = gun_damage
	global_position = currentPos
	direction = (toPos - fromPos).normalized()
	global_rotation = direction.angle() + PI / 2.0
	
func _process(delta):
	translate(direction*speed*delta)


func _on_Bullet_body_entered(body):
	var tree = get_tree()
	if tree.has_group("Player"):
		var player = tree.get_nodes_in_group("Player")[0]
		if (body == player):
			player.take_damage(damage)
	queue_free()
