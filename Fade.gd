extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var alpha = 1
var fade_speed = 1

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	$fadeRect.material.set_shader_param("alpha",alpha)
	alpha -= fade_speed * delta
	if alpha < 0:
		set_process(false)
