extends StaticBody2D

# class member variables go here, for example:
#var shift = 0
onready var tween_node = $Tween
onready var w = $Sprite.get_texture().get_size().x

signal moving(state)

func _ready():
	update()
	
func _draw():
	draw_rect(Rect2(0,0,Global.WALL_WIDTH, Global.GRID_SIZE), Color(1,1,1), true)

func shift_position(shift):
	emit_signal("moving",true)
	$move_sfx.play()
	tween_node.interpolate_property(self, "position:y", 
	position.y, position.y + shift, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_node.start()

func _on_Tween_tween_completed(object, key):
	$stop_sfx.play()
	$move_sfx.stop()
	emit_signal("moving",false)

