extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var sweep = false
var sweep_speed = 1.5
var sweep_pos = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
		$WallOfDeath.position.x = 0

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if sweep:
		$WallOfDeath.position.x = sweep_pos * 640
		$blackout.material.set_shader_param("sweep_pos", sweep_pos)
		sweep_pos+= sweep_speed*delta
		

