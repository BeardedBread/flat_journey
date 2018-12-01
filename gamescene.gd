extends Node2D

onready var wall_res = preload("res://Wall.tscn")
onready var laser_e_res = preload("res://Laser_enemy.tscn")
onready var laser_res = preload("res://Laser_obj.tscn")

onready var screenSize = get_viewport().get_visible_rect().size
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var wall_move = false
var shift_time = 0.5

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	print(screenSize)
	$Wall_Spawner.toggle_spawner(true,false)
	#$Wall_Spawner.deactivate_spawner()
	pass

func _process(delta):
	if wall_move:
		screenshake(16,0.2)
	pass


func _on_Wall_Spawner_wall_spawned(gap_pos, gap_size, shift_pos):
	var topwall = wall_res.instance()
	get_node(".").add_child(topwall)
	topwall.connect("out_of_bound", self, "despawn_wall")
	var bottomwall = wall_res.instance()
	get_node(".").add_child(bottomwall)
	bottomwall.connect("moving", self, "toggle_screenshake")
	bottomwall.connect("out_of_bound", self, "despawn_wall")

	topwall.position = Vector2(gap_pos.x,(gap_pos.y -29-gap_size)*Global.GRID_SIZE)
	topwall.set_scale(Vector2(1, 15))
	bottomwall.position = Vector2(gap_pos.x, screenSize.y - (27-gap_pos.y-gap_size)*Global.GRID_SIZE)#
	bottomwall.set_scale(Vector2(1, 15))
	
	
	if shift_pos-gap_pos.y != 0:
		topwall.set_shift(shift_time,(shift_pos-gap_pos.y)*Global.GRID_SIZE)
		bottomwall.set_shift(shift_time,(shift_pos-gap_pos.y)*Global.GRID_SIZE)
	#screenSize.y/Global.GRID_SIZE 

func despawn_wall(wall):
	get_node(".").remove_child(wall)
	get_tree().queue_delete(wall)
	
func shoot_laser(laser_en):
	var l = laser_res.instance()
	get_node(".").add_child(l)
	l.position = Vector2(0,laser_en.position.y)
	l.connect("kill_zone",self,"check_laser_target")
	despawn_wall(laser_en)
	screenshake(32,0.4)
	#l.tween_node.connect("tween_completed",self, "despawn_wall",l)
func check_laser_target(body):
	#for b in body:
	if body == $Player:		
	
		OS.delay_msec(10)
		$Player/AnimatedSprite.play()
		$Player.dead = true
	
func _on_Player_gameover():
	Global.diff_level = 1
	if $Player.score>Global.high_score:
		Global.high_score = $Player.score
	Global.return_to_menu = true
	Global.playable = false
	get_tree().change_scene("res://mainmenu.tscn")


func _on_Wall_Spawner_laser_spawned(pos):
	var l_enemy = laser_e_res.instance()
	get_node(".").add_child(l_enemy)
	l_enemy.connect("shoot",self,"shoot_laser")
	
	l_enemy.position = Vector2(screenSize.x-32, pos*Global.GRID_SIZE)
	
	l_enemy.place_obj(screenSize.x,screenSize.x-32,0.2)

func toggle_screenshake(state):
	wall_move = state
	
func screenshake(off,mag):	
	$cam.set_offset(Vector2( \
        rand_range(-off,off) * mag, \
        rand_range(-off,off) * mag ))
	
func _on_leveltimer_timeout():
	Global.diff_level = min(Global.diff_level+1,10)
	if Global.diff_level == 2:
		$Wall_Spawner.toggle_spawner(false,true)
	elif Global.diff_level == 3:
		$Wall_Spawner.toggle_spawner(true,true)
	else:
		if math.randint(0,1):
			$Wall_Spawner.toggle_spawner(true,math.randint(0,1))
		else:
			$Wall_Spawner.toggle_spawner(false,true)
	$Wall_Spawner/spawntimer.set_wait_time(max(1.5-0.15*Global.diff_level,0.7))
	shift_time = max(1-0.1*Global.diff_level,0.3)
			
