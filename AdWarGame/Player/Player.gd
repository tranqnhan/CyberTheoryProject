extends KinematicBody2D

signal player_take_dmg(health, damage)

export var player_bullet = preload("res://Bullet/PlayerBullet.tscn")
export var speed = 300

var health = 100
const MAX_HEALTH = 100
var space_state = null

var weapon_timer = null
var weapon_file = preload("res://Weapons/SMG.gd")
var weapon = weapon_file.new()
var weapon_ready : bool = false

func _ready():
	$Camera2D.current = true
	space_state = get_world_2d().direct_space_state

	weapon_ready = true
	weapon_timer = Timer.new()
	weapon_timer.connect("timeout",self,"_on_shoot") 
	add_child(weapon_timer)
	weapon_timer.set_wait_time(weapon.SHOOT_TIME)
	weapon_timer.start()
	
func _process(delta):
	if (Input.get_action_strength("click") && weapon_ready):
		shoot(get_global_mouse_position())

func _on_shoot():
	weapon_ready = true
	weapon_timer.start()

func shoot(mouse_pos):
	weapon.fire(get_tree().get_root(), player_bullet, global_position, mouse_pos)
	weapon_ready = false

func _physics_process(delta):
	# Get player input
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Apply movement
	var movement = speed * direction
	movement = move_and_slide(movement)

	$Sprite.look_at(get_global_mouse_position())

func take_damage(damage):
	health = max(health - damage, 0)
	emit_signal("player_take_dmg", health, damage)
	# if health == 0: goto scene death
	
func _on_Area2D_body_entered(body):
	body.track_player()
