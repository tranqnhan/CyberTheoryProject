extends Node

const SHOOT_TIME = 1
const DAMAGE = 10

const SHOTGUN_BULLET_SPR = PI / 24
const SHOTGUN_BULLET_NUM = 4

func init(you):
	pass

func fire(you, scene, bullet_type, your_position, their_position):
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

func rotate_around_point(origin : Vector2, point : Vector2, angle):
	var ox = origin.x
	var oy = origin.y
	var px = point.x
	var py = point.y
	var qx = ox + cos(angle) * (px - ox) - sin(angle) * (py - oy);
	var qy = oy + sin(angle) * (px - ox) + cos(angle) * (py - oy);
	return Vector2(qx, qy)
