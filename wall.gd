extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var shift = 0
#var moving = false
var hspeed = Vector2(-4,0)
onready var tween_node = $Tween
onready var h = $Sprite.get_texture().get_size().y
signal out_of_bound(wall)
signal moving(state);

func _ready():
	hspeed.x -= min(Global.diff_level*0.5,4)

func _physics_process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
	position += hspeed
	#move_and_slide(hspeed)
	if position.x< - $Sprite.get_texture().get_size().x:
		emit_signal("out_of_bound",self)

func set_shift(duration, shift):
	$Timer.set_wait_time(duration)
	self.shift = shift
	$Timer.start()
	
func _on_Timer_timeout():
	#position.y += shift
	emit_signal("moving",true)
	tween_node.interpolate_property(self, "position:y", 
	position.y, position.y + shift, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_node.start()


func _on_Tween_tween_completed(object, key):
	emit_signal("moving",false)

