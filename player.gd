extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var GRAV = Vector2(0,25);
var JUMP_SPEED = Vector2(0,425);
var vel = Vector2(0,0);
var max_drop = 10;
var dead = false
var leeway = 32
var score = 0
var short_hop = false
onready var default_pos = position.x

signal gameover()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	#print(default_pos)
	pass

func _physics_process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	if not dead:
		vel += GRAV
		#move_and_collide(vel)
		#var col = move_and_collide(vel)
		if Input.is_action_just_pressed("ui_accept"):
			#if vel.y>0:
				vel = -JUMP_SPEED
				short_hop = true
				$Jumptimer.start()
		if Input.is_action_just_released("ui_accept"):
			if short_hop:
				vel /= 4
				short_hop = false
				$Jumptimer.stop()
			#print(vel)
		
		vel = move_and_slide(vel)
		
		position.x = lerp(position.x,default_pos,0.005)
	
	#var col = move_and_collide(vel)
	#print(col)
	
	if position.x< -$Sprite.get_texture().get_size().x-leeway/4 or \
	position.y> get_viewport().get_visible_rect().size.y + $Sprite.get_texture().get_size().y+ leeway:
		emit_signal("gameover")
		

func _on_AnimatedSprite_animation_finished():
	emit_signal("gameover")


func _on_Timer_timeout():
	if not dead:
		score += 1
		$scorelabel.set_text(str(score))


func _on_Jumptimer_timeout():
	short_hop = false
