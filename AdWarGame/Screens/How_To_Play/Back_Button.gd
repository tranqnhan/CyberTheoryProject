extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var current_font = load("AsGodot-Fontpack/fonts/poco/poco.ttf")
#var unused_font = load("AsGodot-Fontpack/fonts/poco/poco.ttf")

# Called when the node enters the scene tree for the first time.
func _ready():
	#var button = Button.new()
	
	#button.text = "Back To Menu"
	#utton.Font = 
	#button.rect_min_size.x = 243
	#button.rect_min_size.y = 43
	connect("pressed", self, "_button_pressed")


func _button_pressed():
	print("Back To Menu Button Pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
