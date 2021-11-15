extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var level1 = "res://Screens/Level1/Level1.tscn"
var level2 = "res://Screens/Level2/Level2.tscn"
var level3 = "res://Screens/Level3/Level3.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", self, "_button_pressed")


func _button_pressed():
	Global.currentLevel += 1
	if(Global.currentLevel == 1):
		get_tree().change_scene(level1)
	elif Global.currentLevel == 2 :
		get_tree().change_scene(level2)
	elif Global.currentLevel == 3 :
		get_tree().change_scene(level3)
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
