extends KinematicBody2D

signal player_take_dmg(health, damage)

var ad = preload("res://AdItem/AdItem.tscn")

export var player_bullet = preload("res://Bullet/PlayerBullet.tscn")
export var speed = 300

export var health = 100
const MAX_HEALTH = 100
var space_state = null

var weapon_timer = null
var weapon_file = preload("res://Weapons/SMG.gd")
var weapon = weapon_file.new()
var weapon_ready : bool = false

var is_ad_open = false

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
	if (!is_ad_open && Input.get_action_strength("click") && weapon_ready):
		shoot(get_global_mouse_position())

func _on_shoot():
	weapon_ready = true
	weapon_timer.start()

func shoot(mouse_pos):
	weapon.fire(self, get_tree().get_root(), player_bullet, global_position, mouse_pos)
	weapon_ready = false

func _physics_process(delta):
	if (!is_ad_open):
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
	if (health > 0):
		var speech_player = AudioStreamPlayer.new()
		var audio_file = "res://Assets/sound_effects/UserHit.wav"
		if File.new().file_exists(audio_file):
			var sfx = load(audio_file) 
			speech_player.stream = sfx
			add_child(speech_player)
			speech_player.connect("finished", speech_player, "queue_free")
			speech_player.play()
		$Tween.interpolate_property($Sprite, "modulate", 
			Color(1,.5,.5,.8), Color(1, 1, 1, 1) , .5, 
			Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	
	if (!is_ad_open and rand_range(0, 1) < 0.15):
		open_ad()
	
	if health == 0: 
		get_tree().change_scene("res://Screens/Defeat_Screen/Defeat.tscn")
		
func open_ad():
	is_ad_open = true
	get_parent().get_node("CanvasLayer").add_child(ad.instance())

func close_ad():
	is_ad_open = false

func _on_Area2D_body_entered(body):
	body.track_player()
