extends Node2D

signal wall_spawned(gap_pos,gap_size,shift_pos)
signal laser_spawned(pos, n_lasers)
signal bomb_spawned(pos, n_spores)
signal query_player(callback)
signal wall_queue_empty

# Wall spawning properties
var topgap_max_offset = deg2rad(20)
var bottomgap_max_offset = deg2rad(40)
var wall_min_offset = deg2rad(5)
var wall_spawntime = 1
var last_wall_speed = 0
var wall_close_range = Global.WALL_WIDTH * 1.25
export var wall_density = 1.0
export var wall_dens_variance = 0.2
export var shift_probability = 0.5
# Wall density determines the timer for spawning the walls

# Laser spawning properties
const gap_proximity = 1
export var laser_density = 1.0
export var laser_dens_variance = 0.2
var laser_spawntime = 1
export var ordered_lasers = true
# Laser density determines the timer for spawning a laser
# Or determines the number of lasers spawned at a time for ordered_lasers

var spawning_walls = false
var spawning_lasers = false

var wall_queue = Array()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	calc_wall_spawntime()
	$spawntimer.connect("timeout",self, "spawn_wall")
	$spawntimer.start()
	$lasertimer.set_wait_time(1)
	$lasertimer.connect("timeout",self, "prepare_spawn_laser")
	$lasertimer.start()
	$bombtimer.set_wait_time(1)
	$bombtimer.connect("timeout",self, "spawn_bomb")
	$bombtimer.start()

func set_wall_spawntimer(timer=1):
	$spawntimer.set_wait_time(timer)
	wall_spawntime = timer
	
func set_laser_spawntimer(timer=1):
	$lasertimer.set_wait_time(timer)
	laser_spawntime = timer
	
func set_bomb_spawntimer(timer=1):
	$bombtimer.set_wait_time(timer)
	
func set_ordered_laser(state):
	ordered_lasers = state
		
func toggle_spawner(wall,laser,bomb):
	if wall:
		$spawntimer.start()
	else:
		$spawntimer.stop()
	if laser:
		$lasertimer.start()
	else:
		$lasertimer.stop()
	if bomb:
		$bombtimer.start()
	else:
		$bombtimer.stop()
		
	spawning_walls = wall
	spawning_lasers = laser
			
func activate_spawner():
	$spawntimer.start()
	
func set_wall_density(mean, variance):
	wall_density = mean
	wall_dens_variance = variance
	calc_wall_spawntime()

func set_shift_prob(val):
	shift_probability = val
	
func set_laser_density(mean, variance):
	laser_density = mean
	laser_dens_variance = variance
	calc_laser_spawntime()

func calc_wall_spawntime():
	var current_speed = math.calc_wall_speed(wall_density)
	set_wall_spawntimer(max(Global.WALL_WIDTH/current_speed/60 * 0.75, 
	math.negexp(2, wall_density*0.8 - rand_range(-wall_dens_variance,wall_dens_variance)*0.5)))
	
func calc_laser_spawntime():
	if ordered_lasers:
		set_laser_spawntimer(Global.LASER_FRAMES * Global.LASER_TIMER)
	else:
		set_laser_spawntimer(math.negexp(1, laser_density*0.6+rand_range(-laser_dens_variance,laser_dens_variance)*0.3))
		

func spawn_wall():
	"""Procedure to spawn the walls is here"""
	var min_shift
	var max_shift
	var top_max_shift
	var bottom_max_shift
	var gap_size
	
	var wall_speed = math.calc_wall_speed(wall_density)
	var dist_elapsed = wall_spawntime * last_wall_speed * 60
		
	# Set the limits of the shift and define gap size
	if dist_elapsed > wall_close_range:
		dist_elapsed /= Global.GRID_SIZE
		if $lasertimer.is_stopped():
			min_shift = 2
			top_max_shift = dist_elapsed * tan(topgap_max_offset) / max(1,wall_density)
			bottom_max_shift = dist_elapsed * tan(bottomgap_max_offset) / max(1,wall_density)
			gap_size = rand_range(1,max(5,15-Global.wall_difficulty))
		else:
			min_shift = 1
			top_max_shift = dist_elapsed * tan(topgap_max_offset*0.8) / max(1,wall_density)
			bottom_max_shift = top_max_shift
			gap_size = rand_range(2,max(2,max(5,15-Global.wall_difficulty)))
	else:
		min_shift = 0
		gap_size = rand_range(1,max(5,15-Global.wall_difficulty))
		if wall_queue:
			top_max_shift = max(0,abs(wall_queue.back().gap_size + gap_size)/2-1)
			bottom_max_shift = top_max_shift
		else:
			top_max_shift = Global.HIGHEST_GRID
			bottom_max_shift = top_max_shift
			
	# Generate the gap position
	var final_gap_pos
	if not wall_queue:
		final_gap_pos = Global.HIGHEST_GRID/2 + rand_range(-1,1) * Global.HIGHEST_GRID/4
	else:		
		var last_pos = wall_queue.back().true_pos
		if randf() > last_pos/Global.HIGHEST_GRID:
			final_gap_pos = last_pos + rand_range(min_shift,top_max_shift)
		else:
			final_gap_pos = last_pos  - rand_range(min_shift,bottom_max_shift)
	final_gap_pos = max(min(final_gap_pos,Global.HIGHEST_GRID),Global.LOWEST_GRID)
	
	# Generate the fake position
	var fake_pos = final_gap_pos
	if gap_size >1:
		if math.rng_check(shift_probability):
			fake_pos = rand_range(0, 30)
	
	last_wall_speed = wall_speed
	emit_signal("wall_spawned",Vector2(position.x, fake_pos),gap_size,final_gap_pos)
	calc_wall_spawntime()

func prepare_spawn_laser():
	emit_signal("query_player", funcref(self, "spawn_laser"))
		
func spawn_laser(player):
	var n_lasers;
	if $spawntimer.is_stopped():
		if ordered_lasers:
			n_lasers = math.inv_negexp(10, laser_density * 0.6 + (randf()*2 - 1) * laser_dens_variance)
		else:
			if Global.laser_difficulty > 5:
				n_lasers = math.randint(1,2)
			else:
				n_lasers = math.randint(1,3)
				
		
		for i in range(n_lasers):
			var grid_pos = rand_range(Global.LOWEST_GRID,Global.HIGHEST_GRID)
		
			emit_signal("laser_spawned",grid_pos,n_lasers)
	else:
		# Spawn only 3 lasers when walls are present
		# And it is always ordered
		n_lasers = math.randint(1,2)
	
		# Given the laser timing t
		if wall_queue:
			var laser_time = Global.LASER_FRAMES * Global.LASER_TIMER
			# First predict the player position after t time
			# Assume player is perfect and crosses as many wall as possible	
			var frames = laser_time * 60; # Assume 60fps
			var rpn = pow(1-player.POS_RECOVERY,frames)
			var predicted_player_pos = ceil(player.position.x * rpn +\
			player.default_pos * (1-rpn))
			predicted_player_pos = max(predicted_player_pos, player.position.x)
			# Using the predicted player position
			# Find out which walls are of concern
			var closest_wall_ind = search_woc(player.position.x)
			var max_wall_ind = search_woc(predicted_player_pos, frames)
			# Assuming all wall is of the same speed
			# The wall relative distance to each other is constant
			# Therefore, a binary search is possible on the queue
			# Where-ever the search terminates, take the wall before it
			var overlaps = Array()
			for i in range(max_wall_ind-closest_wall_ind+1):
				overlaps.append(0)
			
			for i in range(n_lasers):
				var grid_pos = rand_range(Global.LOWEST_GRID,Global.HIGHEST_GRID)
			
				var discard = false
				var ind = 0
				for j in range(closest_wall_ind, max_wall_ind+1):
					# When spawning a laser, check if the position is on the gap
					var top = wall_queue[j].true_pos - wall_queue[j].gap_size/2
					var bottom = wall_queue[j].true_pos + wall_queue[j].gap_size/2
					# Keep track of how many lasers has spawned on the gap
					if(grid_pos > top - gap_proximity&& grid_pos < bottom+gap_proximity):
						# Number of laser on gap < gap_size//2
						if overlaps[ind] > wall_queue[j].gap_size/2-1:
							# Reroll position if above condition is violated
							discard = true
							break
						overlaps[ind] += 1
					ind += 1
				
				if not discard:
					emit_signal("laser_spawned",grid_pos,n_lasers)
					
	calc_laser_spawntime()
	
func search_woc(pos, elapsed_time=0):
	# Binary search the wall of concern, return index
	# Need to account for the moving walls using elapsed time, 0 for static check
	var lo = 0
	var hi = wall_queue.size() - 1
	while(lo <= hi):
		var mid = (lo+hi)/2
		var new_position = wall_queue[mid].position.x + wall_queue[mid].hspeed.x * elapsed_time
		if (pos == new_position):
			return mid
		if(pos < new_position):
			hi = mid - 1
		if(pos > new_position):
			lo = mid + 1

	return math.bound_val(lo, 0, wall_queue.size() - 1)
		
func spawn_bomb():
	var n_bombs = math.randint(1,3)
		
	for i in range(n_bombs):
		var grid_pos = math.randint(2,29)
		var n_spores = math.randint(3,8)
		emit_signal("bomb_spawned",grid_pos,n_spores)
		
func dequeue_wall(dummy):
	wall_queue.pop_front()
	if wall_queue.size() == 1:
		emit_signal("wall_queue_empty")
	
func queue_wall(wall_ent):
	wall_queue.append(wall_ent)
	
	
