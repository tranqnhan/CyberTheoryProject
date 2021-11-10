extends KinematicBody2D

export(int) var SPEED: int = 100
export var bullet = preload("res://Bullet/Bullet.tscn")

var space_state = null

var velocity: Vector2 = Vector2.ZERO

var path: Array = []	# Contains destination positions
var levelNavigation: Navigation2D = null
var player = null
var player_spotted: bool = false

var idle_wander_timer = null
var seek_timer = null
var weapon_timer = null

const WANDER_DIST = 64
const SEEK_TIME = 1
const SHOOT_DISTANCE = 500
const IDLE_WANDER_TIME = 2

enum STATE {IDLE, WANDER, SEEK, SHOOT}

const RIFLE_SHOOT_TIME = .5
const SHOTGUN_SHOOT_TIME = 1
const SMG_SHOOT_TIME = .2
enum WEAPON_TYPE {SHOTGUN, RIFLE, SMG}

var SHOTGUN_BULLET_SPR = PI / 24
const SHOTGUN_BULLET_NUM = 4

var current_state = STATE.IDLE
var current_weapon = WEAPON_TYPE.SHOTGUN
var current_weapon_time = SHOTGUN_SHOOT_TIME

var isIdle = false

func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	
	space_state = get_world_2d().direct_space_state
	
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
	weapon_timer.set_wait_time(current_weapon_time)
	
	idle_wander_timer.start()

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
	if (global_position.distance_to(player.global_position) < SHOOT_DISTANCE):
		var result = space_state.intersect_ray(global_position, player.global_position, [self])
		if(result["collider"] == player):
			shoot()
		else:
			switch_state(STATE.SEEK)
	else:
		switch_state(STATE.SEEK)

func _physics_process(delta):
	match(current_state):
		STATE.IDLE:
			pass
		STATE.WANDER:
			if(navigate()):
				move()
		STATE.SEEK:
			var result = space_state.intersect_ray(global_position, player.global_position, [self])
			if (global_position.distance_to(player.global_position) < SHOOT_DISTANCE
				and result["collider"] == player):
				switch_state(STATE.SHOOT)
			else:
				if(navigate()):
					move()
		STATE.SHOOT:
			pass

func shoot():
	var direction = (player.global_position - global_position).normalized()
	global_rotation = direction.angle() + PI / 2.0
	match (current_weapon):
		WEAPON_TYPE.RIFLE:
			var b = bullet.instance()
			b.init(10, global_position, global_position, player.global_position)
			get_tree().get_root().add_child(b)
			
		WEAPON_TYPE.SMG:
			var b = bullet.instance()
			b.init(5, global_position, global_position, player.global_position)
			get_tree().get_root().add_child(b)

		WEAPON_TYPE.SHOTGUN:
			for i in range(SHOTGUN_BULLET_NUM):
				var shotspr = rand_range(SHOTGUN_BULLET_SPR - PI / 24, SHOTGUN_BULLET_SPR + PI / 24)
				var startRadians = (shotspr / 2) * (SHOTGUN_BULLET_NUM - 1);
				var startPoint = rotate_around_point(global_position, player.global_position, startRadians);
				var nextPoint = rotate_around_point(global_position, startPoint, -shotspr * i);
				var b = bullet.instance()
				b.init(10, global_position, global_position, nextPoint)
				get_tree().get_root().add_child(b)

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
			shoot()
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
		var target = Vector2(rand_range(-WANDER_DIST, WANDER_DIST), rand_range(-WANDER_DIST, WANDER_DIST))
		var postar = levelNavigation.get_closest_point(target + position)
		
		path = levelNavigation.get_simple_path(global_position, postar, false)

func generate_path_to_player(): # It's obvious
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)

func move():
	velocity = move_and_slide(velocity)
