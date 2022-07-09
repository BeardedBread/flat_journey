extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var lift = 10
export var sides = 10
var y_pos

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	y_pos = self.texture.get_height()/2-lift
	update()

func _draw():
	draw_line(Vector2(-self.texture.get_width()/2+sides, y_pos), 
	Vector2(self.texture.get_width()/2-sides, y_pos), 
	Color(0,0,0), 1.0, false)
