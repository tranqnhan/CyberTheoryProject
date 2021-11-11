extends Node

var boss = null

var SHOOT_TIME = 1
var DAMAGE = 10

const SHOTGUN_BULLET_SPR = PI / 24
const SHOTGUN_BULLET_NUM = 9

var phase_timer = null
var PHASE_TIME = 2

var phase_time_dict = {
	"shotgun" : 3,
	"laser" : 2 
}

var shoot_time_dict = {
	"shotgun" : .7,
	"laser" : .05
}

var damage_dict = {
	"shotgun" : 5,
	"laser" : 2
}

var phase_type = "shotgun"

func init(you):
	boss = you
	
	SHOOT_TIME = shoot_time_dict[phase_type]
	PHASE_TIME = phase_time_dict[phase_type]
	DAMAGE = damage_dict[phase_type]
	
	phase_timer =  Timer.new()
	phase_timer.connect("timeout",self,"_on_change_phase") 
	you.add_child(phase_timer)
	phase_timer.set_wait_time(PHASE_TIME)
	phase_timer.start()
	
func _on_change_phase():
	if (rand_range(0, 1) > 0.5):
		phase_type = "shotgun"
	else:
		phase_type = "laser"
	
	SHOOT_TIME = shoot_time_dict[phase_type]
	PHASE_TIME = phase_time_dict[phase_type]
	DAMAGE = damage_dict[phase_type]
	boss.set_weapon_time(SHOOT_TIME)
	phase_timer.start()
	
func fire(you, scene, bullet_type, your_position, their_position):
	if (phase_type == "shotgun"):
		boss_shotgun_pattern(you, scene, bullet_type, your_position, their_position)
	else:
		boss_laser_pattern(you, scene, bullet_type, your_position, their_position)

func rotate_around_point(origin : Vector2, point : Vector2, angle):
	var ox = origin.x
	var oy = origin.y
	var px = point.x
	var py = point.y
	var qx = ox + cos(angle) * (px - ox) - sin(angle) * (py - oy);
	var qy = oy + sin(angle) * (px - ox) + cos(angle) * (py - oy);
	return Vector2(qx, qy)

func boss_shotgun_pattern(you, scene, bullet_type, your_position, their_position):
	for i in range(SHOTGUN_BULLET_NUM):
		var shotspr = rand_range(SHOTGUN_BULLET_SPR - PI / 24, SHOTGUN_BULLET_SPR + PI / 24)
		var startRadians = (shotspr / 2) * (SHOTGUN_BULLET_NUM - 1);
		var startPoint = rotate_around_point(your_position, their_position, startRadians);
		var nextPoint = rotate_around_point(your_position, startPoint, -shotspr * i);
		var b = bullet_type.instance()
		b.init(DAMAGE, your_position, your_position, nextPoint)
		scene.add_child(b)

	var speech_player = AudioStreamPlayer.new()
	var audio_file = "res://Assets/sound_effects/EnemyShotgun.wav"
	if File.new().file_exists(audio_file):
		var sfx = load(audio_file) 
		speech_player.stream = sfx
		you.add_child(speech_player)
		speech_player.connect("finished", speech_player, "queue_free")
		speech_player.play()

func boss_laser_pattern(you, scene, bullet_type, your_position, their_position):
	var b = bullet_type.instance()
	b.init(DAMAGE, your_position, your_position, their_position)
	scene.add_child(b)
	
	var speech_player = AudioStreamPlayer.new()
	var audio_file = "res://Assets/sound_effects/UserSMG.wav"
	if File.new().file_exists(audio_file):
		var sfx = load(audio_file) 
		speech_player.stream = sfx
		you.add_child(speech_player)
		speech_player.connect("finished", speech_player, "queue_free")
		speech_player.play()
