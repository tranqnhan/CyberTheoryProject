extends KinematicBody2D

export(int) var SPEED: int = 200
export var enemy_bullet = preload("res://Bullet/EnemyBullet.tscn")
export(String, "shotgun", "rifle", "smg", "boss_weapon", "mini_boss_weapon" ) onready var weapon_file

export var health = 100
var space_state = null

var velocity: Vector2 = Vector2.ZERO

var path: Array = []	# Contains destination positions
var levelNavigation: Navigation2D = null
var player = null

var idle_wander_timer = null
var seek_timer = null
var weapon_timer = null

export var WANDER_DIST = 64
const SEEK_TIME = 1
const SHOOT_DISTANCE = 500
const IDLE_WANDER_TIME = 2

enum STATE {IDLE, WANDER, SEEK, SHOOT}

var current_state = STATE.IDLE

var weapon_dict = {
	"shotgun" : preload("res://Weapons/Shotgun.gd"),
	"rifle" : preload("res://Weapons/Rifle.gd"),
	"smg" : preload("res://Weapons/SMG.gd"),
	"boss_weapon" : preload("res://Weapons/BossWeapon.gd"),
	"mini_boss_weapon" : preload("res://Weapons/MiniBossWeapon.gd")
}

var weapon = null
var track_player = false
var isIdle = false

func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	
	space_state = get_world_2d().direct_space_state
	
	weapon = weapon_dict[weapon_file].new()
	weapon.init(self)
	
	seek_timer =  Timer.new()
	seek_timer.connect("timeout",self,"_on_seek") 
	add_child(seek_timer)
	seek_timer.set_wait_time(SEEK_TIME)
	
	idle_wander_timer = Timer.new()
	idle_wander_timer.connect("timeout",self,"_on_idle_wander") 
	add_child(idle_wander_timer)
	idle_wander_timer.set_wait_time(IDLE_WANDER_TIME)
	
	weapon_timer =  Timer.new()
	weapon_timer.connect("timeout",self,"_on_shoot") 
	add_child(weapon_timer)
	weapon_timer.set_wait_time(weapon.SHOOT_TIME)
	
	idle_wander_timer.start()

func set_weapon_time(time):
	weapon_timer.set_wait_time(time)

func _on_idle_wander():
	if (!isIdle):
		switch_state(STATE.WANDER)
		generate_wander_path()
		isIdle = true
	else:
		switch_state(STATE.IDLE)
		isIdle = false
	idle_wander_timer.start()

func _on_seek():
	generate_path_to_player()
	seek_timer.start()

func _on_shoot():
	#draw_l()
	if (global_position.distance_to(player.global_position) < SHOOT_DISTANCE):
		var spr = 20
		
		var line1 = to_local(player.global_position)
		var line2 = (player.global_position - global_position).normalized()
		
		var ppoint1 = Vector2(line2.y, -line2.x).normalized() * spr
		var epoint1 = Vector2(line1.y, -line1.x).normalized() * spr
		var epoint2 = Vector2(-line1.y, line1.x).normalized() * spr
		var ppoint2 = Vector2(-line2.y, line2.x).normalized() * spr
		
		var result1 = space_state.intersect_ray(global_position + epoint1, player.global_position + ppoint1, [self])
		var result2 = space_state.intersect_ray(global_position + epoint2, player.global_position + ppoint2, [self])
		
		if(result1["collider"] == player and result2["collider"] == player):
			shoot()
		else:
			switch_state(STATE.SEEK)
	else:
		switch_state(STATE.SEEK)

func draw_l():
	if (player != null):
		
		var spr = 10
		
		var line1 = to_local(player.global_position)
		var line2 = (player.global_position - global_position).normalized()
		
		var ppoint1 = Vector2(line2.y, -line2.x).normalized() * spr
		var epoint1 = Vector2(line1.y, -line1.x).normalized() * spr
		var epoint2 = Vector2(-line1.y, line1.x).normalized() * spr
		var ppoint2 = Vector2(-line2.y, line2.x).normalized() * spr
		
		#$Line2D.clear_points()
		#$Line2D2.clear_points()
		
		#$Line2D.add_point(epoint1)
		#$Line2D.add_point(to_local(player.global_position + ppoint1))
		#$Line2D2.add_point(epoint2)
		#$Line2D2.add_point(to_local(player.global_position + ppoint2))

func _physics_process(delta):

	if (track_player):
		var result = space_state.intersect_ray(global_position, player.global_position, [self])
		if(result["collider"] == player):
			player_spotted()
			track_player = false
			
	match(current_state):
		STATE.IDLE:
			pass
		STATE.WANDER:
			if(navigate()):
				move()
		STATE.SEEK:
			#draw_l()
			var spr = 20
		
			var line1 = to_local(player.global_position)
			var line2 = (player.global_position - global_position).normalized()
			
			var ppoint1 = Vector2(line2.y, -line2.x).normalized() * spr
			var epoint1 = Vector2(line1.y, -line1.x).normalized() * spr
			var epoint2 = Vector2(-line1.y, line1.x).normalized() * spr
			var ppoint2 = Vector2(-line2.y, line2.x).normalized() * spr
			
			var result1 = space_state.intersect_ray(global_position + epoint1, player.global_position + ppoint1, [self])
			var result2 = space_state.intersect_ray(global_position + epoint2, player.global_position + ppoint2, [self])
			
			if (global_position.distance_to(player.global_position) < SHOOT_DISTANCE
				and result1["collider"] == player and result2["collider"] == player):
				switch_state(STATE.SHOOT)
			else:
				if(navigate()):
					move()
		STATE.SHOOT:
			var direction = (player.global_position - global_position).normalized()
			global_rotation = direction.angle() + PI / 2.0

func shoot():
	weapon.fire(self, get_tree().get_root(), enemy_bullet, global_position, player.global_position)

func player_spotted():
	switch_state(STATE.SEEK)

func rotate_around_point(origin : Vector2, point : Vector2, angle):
	var ox = origin.x
	var oy = origin.y
	var px = point.x
	var py = point.y
	var qx = ox + cos(angle) * (px - ox) - sin(angle) * (py - oy);
	var qy = oy + sin(angle) * (px - ox) + cos(angle) * (py - oy);
	return Vector2(qx, qy)

func track_player():
	if (current_state == STATE.IDLE or current_state == STATE.WANDER):
		track_player = true

func switch_state(new_state : int):
	match (new_state):
		STATE.WANDER:
			idle_wander_timer.start()
		STATE.IDLE:
			idle_wander_timer.start()
		STATE.SEEK:
			generate_path_to_player()
			seek_timer.start()
		STATE.SHOOT:
			#shoot()
			weapon_timer.start()
	
	match (current_state):
		STATE.WANDER:
			idle_wander_timer.stop()
		STATE.IDLE:
			idle_wander_timer.stop()
		STATE.SEEK:
			seek_timer.stop()
		STATE.SHOOT:
			weapon_timer.stop()
			
	current_state = new_state

func navigate():	# Define the next position to go to
	if path.size() > 1:
		velocity = global_position.direction_to(path[1]) * SPEED
		
		if (velocity.distance_to(Vector2.ZERO) > 0.5):
			var direction = (velocity).normalized()
			global_rotation = direction.angle() + PI / 2.0
			
		# If reached the destination, remove this point from path array
		if global_position.distance_to(path[1]) < 5:
			path.pop_front()
		return true
	elif(path.size() == 1):
		path.pop_front()
		return false

func generate_wander_path():
	if levelNavigation != null:
		if (WANDER_DIST > 0):
			var target = Vector2(rand_range(-WANDER_DIST, WANDER_DIST), rand_range(-WANDER_DIST, WANDER_DIST))
			var postar = levelNavigation.get_closest_point(target + position)
			
			path = levelNavigation.get_simple_path(global_position, postar, false)

func generate_path_to_player(): # It's obvious
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)

func move():
	velocity = move_and_slide(velocity)

func take_damage(damage):
	health = max(health - damage, 0)
	if (current_state != STATE.SEEK and current_state != STATE.SHOOT):
		switch_state(STATE.SEEK)
		
	if(health == 0):
		queue_free()
	else:
		var speech_player = AudioStreamPlayer.new()
		var audio_file = "res://Assets/sound_effects/EnemyHit.wav"
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
