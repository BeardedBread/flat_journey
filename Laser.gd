extends AnimatedSprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal shoot(obj)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func place_obj(p1,p2,t):
	$Tween.interpolate_property(self, "position:x", 
	p1, p2, t, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_Timer_timeout():
	set_frame(frame +1)

func _on_Laser_frame_changed():
	if frame == 4:
		emit_signal("shoot",self)
