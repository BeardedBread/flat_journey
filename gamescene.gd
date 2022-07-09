extends Node2D

onready var wall_res = preload("res://Wall_Obstacle.tscn")
onready var laser_e_res = preload("res://Laser_enemy.tscn")
onready var laser_res = preload("res://Laser_obj.tscn")
onready var laser_p_res = preload("res://laser_particle.tscn")
onready var spore_res = preload("res://Spore.tscn")
onready var screenSize = get_viewport().get_visible_rect().size
onready var diffInfo = get_node("DifficultyInfo")

# class member variables go here, for example:
var wall_move = false
var current_mode = 0
export var starting_wall_diff = 1
export var starting_laser_diff = 1
export var input_map_seed = -1

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	Global.diff_level = Global.start_level
	Global.wall_difficulty = starting_wall_diff
	Global.laser_difficulty = starting_laser_diff
	display_difficulty()
	randomize()
	if input_map_seed < 0:
		var map_seed = randi()
		seed(map_seed)
		print("Seed: ", map_seed)
	else:
		seed(input_map_seed)
		print("Seed: ", input_map_seed)
		
	$Wall_Spawner.toggle_spawner(true,false, false)

func _process(delta):
	# ScreenShake
	if wall_move:
		screenshake(16,0.2)

	# Scrolling background
	var bg_rect = $bg.get_region_rect()
	bg_rect.position.x += 5 * delta
	if bg_rect.position.x > 900:
		bg_rect.position.x = -900
	$bg.set_region_rect(bg_rect)
	
	$Effects/WallOfDeath/sfx.set_volume_db(min(3.0,
	10 * log(60/max(1,$Player.position.x - $Effects/WallOfDeath.position.x))))

func despawn_ent(ent):
	# Dequeue a given entity/object
	#get_node(".").remove_child(ent)
	#get_tree().queue_delete(ent)
	pass
	
func shoot_laser(laser_en, n_lasers):
	# Spawn the laser itself
	var l = laser_res.instance()
	get_node(".").add_child(l)
	l.position = Vector2(0,laser_en.position.y)
	l.connect("kill_zone",self,"check_laser_target")
	#despawn_ent(laser_en)
	screenshake(32,0.4)
	
	# Spawn the laser particles (which has the sound lol)
	# Maybe consider grouping the lasers???????
	var l_p = laser_p_res.instance()
	get_node(".").add_child(l_p)
	l_p.position = Vector2(550,laser_en.position.y)
	l_p.laser_sound.set_volume_db(10*log(min(0.7,0.3 + 0.1*n_lasers)/n_lasers))
	
func check_laser_target(body):
	# Kill player
	OS.delay_msec(30)
	$Player.on_dead()

func _on_Player_dead_player():
	$Effects.sweep = true
			
func _on_Player_gameover():
	# Reset the game variable
	if $Player.score>Global.high_score:
		Global.high_score = $Player.score
	Global.return_to_menu = true
	Global.playable = false
	# Return to Main Menu
	get_tree().change_scene("res://mainmenu.tscn")

func _on_Wall_Spawner_wall_spawned(gap_pos, gap_size, true_pos):
	# Spawn the wall obstacle
	var wall_obs = wall_res.instance()
	wall_obs.gap_pos = gap_pos
	wall_obs.gap_size = gap_size
	wall_obs.true_pos = true_pos
	wall_obs.hspeed.x = -math.calc_wall_speed($Wall_Spawner.wall_density)
	wall_obs.tracking_player = weakref($Player)
	get_node(".").add_child(wall_obs)
	#wall_obs.connect("out_of_bound", self, "despawn_ent")
	wall_obs.connect("moving", self, "toggle_screenshake")
	wall_obs.connect("out_of_bound", $Wall_Spawner, "dequeue_wall")
	$Wall_Spawner.queue_wall(wall_obs)
	

func _on_Wall_Spawner_query_player(callback):
	callback.call_func($Player)

func _on_Wall_Spawner_laser_spawned(pos,n_lasers):
	# Spawn the laser enemy
	var l_enemy = laser_e_res.instance()
	get_node(".").add_child(l_enemy)
	l_enemy.connect("shoot",self,"shoot_laser")	
	l_enemy.position = Vector2(screenSize.x-32, pos*Global.GRID_SIZE)	
	l_enemy.place_obj(screenSize.x,screenSize.x-32,0.2)
	l_enemy.n_lasers = n_lasers
	l_enemy.spawn_sound.set_volume_db(10*log(min(0.7,0.3 + 0.1*n_lasers)/n_lasers))

func toggle_screenshake(state):
	wall_move = state
	
func screenshake(off,mag):
	$cam.set_offset(Vector2( \
		rand_range(-off,off) * mag, \
		rand_range(-off,off) * mag ))
	
func _on_leveltimer_timeout():
	# If wall is spawning, let the wall finish moving then toggle difficulty via signal
	# Otherwise immediately increase difficulty
	if not $Wall_Spawner.spawning_walls:
		increase_difficulty()
	else:
		$Wall_Spawner.toggle_spawner(false,false,false)
	
func increase_difficulty():
	# Up the difficulty
	# Three factor that can be amp up:
	# Laser density, wall density, which one to toggle
	# Laser can be ordered or contiguous
	 
	Global.diff_level = min(Global.diff_level+1,10)
	if Global.diff_level == 2:
		$Wall_Spawner.set_ordered_laser(false)
		$Wall_Spawner.toggle_spawner(false,true,false)
		current_mode = 1
	elif Global.diff_level == 3:
		$Wall_Spawner.wall_density /= 2
		$Wall_Spawner.set_ordered_laser(true)
		$Wall_Spawner.toggle_spawner(true,true,false)
		current_mode = 2
	else:
		$leveltimer.set_wait_time(math.randint(5,8))
		var mode = (current_mode + math.randint(1,2))%3
		var mean
		if mode==0:
			Global.wall_difficulty = min(Global.wall_difficulty+0.5,10)
			Global.laser_difficulty = min(Global.wall_difficulty+0.5,10)
			mean = 0.8 + Global.wall_difficulty *0.25 + rand_range(-1, 1)
			$Wall_Spawner.shift_probability = 1 - exp(-Global.wall_difficulty/8)
			if math.rng_check(0.1):
				$Wall_Spawner.set_wall_density(mean*1.5,0.1)
			else:
				$Wall_Spawner.set_wall_density(mean*rand_range(0.7, 0.9),0.1)
			$Wall_Spawner.set_ordered_laser(true)
			$Wall_Spawner.toggle_spawner(true,true,false)
		elif mode==1:
			Global.wall_difficulty = min(Global.wall_difficulty+1,10)
			mean = 1 + Global.wall_difficulty * 0.1
			$Wall_Spawner.shift_probability = 1 - exp(-Global.wall_difficulty/5)
			
			if math.rng_check(0.15):
				$Wall_Spawner.set_wall_density(mean*2,0.1)
			else:
				$Wall_Spawner.set_wall_density(mean*rand_range(0.8, 0.9),rand_range(0.1,0.3))
			$Wall_Spawner.toggle_spawner(true,false,false)
		else:
			Global.laser_difficulty = min(Global.laser_difficulty+0.5,10)
			mean = 0.5 + Global.laser_difficulty *0.2 + rand_range(-0.5,0.5)
			$Wall_Spawner.set_laser_density(mean, math.inv_negexp(1, randf()*0.2 + 0.1))
			$Wall_Spawner.set_ordered_laser(math.flip_coin())
			$Wall_Spawner.toggle_spawner(false,true,false)
		current_mode = mode
	
	display_difficulty()
	$leveltimer.start()

func display_difficulty():
	diffInfo.get_node("Wall_diff_label").set_text("Wall Difficulty: " + str(Global.wall_difficulty) + "\nDensity: " + str($Wall_Spawner.wall_density))
	diffInfo.get_node("Laser_diff_label").set_text("Laser Difficulty: " + str(Global.laser_difficulty) + "\nDensity: " + str($Wall_Spawner.laser_density))
