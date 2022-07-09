extends AnimatedSprite

# class member variables go here, for example:
# var a = 2
var n_lasers = 0
signal shoot(obj)
onready var spawn_sound = $spawn_sfx

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$Line2D.set_default_color(Color(1.0,1.0,0.0, 0))
	$Timer.set_wait_time(Global.LASER_TIMER)
	$Timer.start()
	
func place_obj(p1,p2,t):
	$Tween.interpolate_property(self, "position:x", 
	p1, p2, t, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_Timer_timeout():
	set_frame(frame +1)
	var frac = float(frame)/4;
	$Line2D.set_default_color(Color(frac,frac,frac*0.6))
	$Line2D.set_width(frac * Global.GRID_SIZE)
	$Line2D.update()

func _on_Laser_frame_changed():
	if frame == 4:
		emit_signal("shoot",self,n_lasers)
		get_tree().queue_delete(self)
