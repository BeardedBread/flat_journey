extends KinematicBody2D

# class member variables go here, for example:

const GRAV = Vector2(0,25);
const JUMP_SPEED = Vector2(0,450);
const LEEWAY = 32
const KB_RECOVERY = 0.1
const POS_RECOVERY = 0.01

var vel = Vector2(0,0);

var dead = false
var score = 0

var short_hop = false
var short_hop_factor = 5

var knockback = 0

onready var default_pos = position.x

export var invuln = false
export var float_enable = false

signal gameover()
signal dead_player()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	vel = -JUMP_SPEED
	short_hop = true
	$Jumptimer.start()
	$jump_sfx.play()

func _physics_process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	if not dead:
		
		if not float_enable:
			vel += GRAV
		#move_and_collide(vel)
		#var col = move_and_collide(vel)
		if Input.is_action_just_pressed("ui_accept"):
			#if vel.y>0:
				vel = -JUMP_SPEED
				short_hop = true
				$Jumptimer.start()
				$jump_sfx.play()
		if Input.is_action_just_released("ui_accept"):
			if short_hop:
				vel /= short_hop_factor
				short_hop = false
				$Jumptimer.stop()
		
		vel = move_and_slide(vel)
		
		# Slowly move back to default position
		position.x = ceil(lerp(position.x,default_pos,POS_RECOVERY) - knockback)
		knockback = lerp(knockback,0,KB_RECOVERY)
	
	if not invuln:
		if position.x< -$Sprite.get_texture().get_size().x-LEEWAY/4 or \
		position.y> get_viewport().get_visible_rect().size.y + $Sprite.get_texture().get_size().y+ LEEWAY:
			if not dead:
				on_dead()
			
		
func _on_AnimatedSprite_animation_finished():
	pass

func _on_Timer_timeout():
	if not dead:
		score += 1
		$scorelabel.set_text(str(score))

func _on_Jumptimer_timeout():
	short_hop = false
	
func on_dead():
	$AnimatedSprite.play()
	$dead_sfx.play()
	get_tree().queue_delete($scorelabel)
	dead = true
	emit_signal("dead_player")
	

func _on_dead_sfx_finished():
	emit_signal("gameover")
