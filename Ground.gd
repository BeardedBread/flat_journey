extends Node2D

var time = 0.0

export var n_lines = 5
export var x_offset_spd = 0.1
export var field_angle = 170.0
export var start_y = 0
export var growth = 0.1
export var alpha = 1.0

var end_y = ProjectSettings.get_setting("display/window/size/height")
var start_point
var start_x
var end_x
var draw_width
var x_increment
var y_dist
var x_offset = 0


func _ready():
	start_point = Vector2(ProjectSettings.get_setting("display/window/size/width")/2, start_y)
	y_dist = end_y - start_point.y
	
	var half_width = y_dist/tan(deg2rad((180-field_angle)/2))
	start_x = start_point.x - half_width
	end_x = start_point.x + half_width
	draw_width = 2*half_width
	x_increment = draw_width / (n_lines + 1)
	#set_physics_process(false)
	
func _physics_process(delta):
	x_offset += x_offset_spd * delta
	update()

func _draw():
	var draw_x = start_x + x_offset
	for i in range(n_lines+2):
		draw_line(start_point, Vector2(draw_x,end_y), Color(1,1,1,alpha), 1.0, true)
		draw_x += x_increment
		if draw_x > end_x:
			draw_x -= draw_width
		if draw_x < start_x:
			draw_x += draw_width
	
	var i = 0
	while true:
		var draw_dist = prespective_transform(i)
		if draw_dist > ProjectSettings.get_setting("display/window/size/height"):
			break
		draw_line(Vector2(0,draw_dist), Vector2(ProjectSettings.get_setting("display/window/size/width"),draw_dist), 
				  Color(1,1,1,alpha), 1.0, true)
		i+= 1
		
func prespective_transform(y):
	#return A*y*y + B*y + start_point.y
	return start_point.y + exp(y * growth)
