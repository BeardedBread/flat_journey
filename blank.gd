extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():	
	if Global.return_to_menu:
		$Tween.interpolate_property(self, "modulate", 
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		Global.return_to_menu = false
	else:
		modulate = Color(1, 1, 1, 0)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
