extends TextureRect

export var sweep_speed = 50
var sweep_pos = 0
var sweep = false


func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	if sweep:
		self.material.set_shader_param("x_line", sweep_pos)
		sweep_pos += sweep_speed * delta
