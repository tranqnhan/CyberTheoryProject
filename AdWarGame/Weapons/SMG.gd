extends Node

const SHOOT_TIME = .2
const DAMAGE = 5

func fire(scene, bullet_type, your_position, their_position):
	var b = bullet_type.instance()
	b.init(DAMAGE, your_position, your_position, their_position)
	scene.add_child(b)
