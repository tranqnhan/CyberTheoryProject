extends KinematicBody2D

# Player movement speed
export var speed = 500

var health = 100
const MAX_HEALTH = 100
const enemies = []
var space_state = null
	
func _ready():
	$Camera2D.current = true
	space_state = get_world_2d().direct_space_state
	$GUI/HealthBar.value = health
	
func _physics_process(delta):
	# Get player input
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Apply movement
	var movement = speed * direction * delta
	move_and_collide(movement)

	if (enemies.size() > 0):
		for i in range(enemies.size()):
			var enemy : KinematicBody2D = enemies[i];
			var result = space_state.intersect_ray(global_position, enemy.global_position, [self])
			if(result["collider"] == enemy):
				enemy.player_spotted()
				enemies.erase(enemy)
				

	$Sprite.look_at(get_global_mouse_position())

func take_damage(damage):
	health = max(health - damage, 0)
	$GUI/HealthBar.value = health
	
	# if health == 0: goto scene death
	
func _on_Area2D_body_entered(body):
	enemies.append(body)

func _on_Area2D_body_exited(body):
	enemies.erase(body)
