extends Node

const SHOOT_TIME = .05
const DAMAGE = 5

func init(you):
	pass

func fire(you, scene, bullet_type, your_position, their_position):
	var b = bullet_type.instance()
	b.init(DAMAGE, your_position, your_position, their_position)
	scene.add_child(b)
	
	var speech_player = AudioStreamPlayer.new()
	var audio_file = "res://Assets/sound_effects/EnemySMG.wav"
	if File.new().file_exists(audio_file):
		var sfx = load(audio_file) 
		speech_player.stream = sfx
		you.add_child(speech_player)
		speech_player.connect("finished", speech_player, "queue_free")
		speech_player.play()
