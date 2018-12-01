extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal wall_spawned(gap_pos,gap_size,shift_pos);
signal laser_spawned(pos)

var prev_pos = 0
var prev_gap_size = 0
var active = true

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$spawntimer.set_wait_time(1)
	$spawntimer.connect("timeout",self, "spawn_wall")
	$spawntimer.start()
	$lasertimer.set_wait_time(1)
	$lasertimer.connect("timeout",self, "spawn_laser")
	$lasertimer.start()
	
		
func toggle_spawner(wall,laser):
	if wall:
		$spawntimer.start()
	else:
		$spawntimer.stop()
	if laser:
		$lasertimer.start()
	else:
		$lasertimer.stop()
			
	
func activate_spawner():
	$spawntimer.start()
	
func spawn_wall():	
	var gap_size = math.randint(0,5)
	var shifting = false
	if gap_size >1:
		shifting = math.randint(1,gap_size)>1
	
	var gap_grid_pos
	if not prev_pos:
		gap_grid_pos = math.randint(5,20)
	else:
		#gap_grid_pos = prev_pos + pow(-1,math.randint(0,1)) * math.randint(5,15)
		if randf() > int(prev_pos/24):
			gap_grid_pos = prev_pos + math.randint(7,12)
		else:
			gap_grid_pos = prev_pos - math.randint(7,15)
		gap_grid_pos = math.bound_val(gap_grid_pos,3,24)
	
	var shift_pos
	if shifting:
		#print('shift set')		
		
		if randf() > int(gap_grid_pos/24):
			shift_pos = gap_grid_pos + math.randint(5,8)
		else:
			shift_pos = gap_grid_pos - math.randint(5,8)
			
		shift_pos = math.bound_val(shift_pos,5,24)
	else:
		shift_pos = gap_grid_pos
	
	prev_pos = shift_pos
	prev_gap_size = gap_size
	emit_signal("wall_spawned",Vector2(position.x, gap_grid_pos),gap_size,shift_pos)
	#emit_signal("wall_spawned",Vector2(position.x, gap_grid_pos),gap_size,shift_pos)
	
func spawn_laser():
	var n_lasers;
	if $spawntimer.is_stopped():
		n_lasers = min(math.randint(1,4) + Global.diff_level - 3,8)
	else:
		n_lasers = math.randint(1,3)
		
	for i in range(n_lasers):
		var grid_pos = math.randint(2,29)
		if prev_gap_size<1 and grid_pos == prev_pos:
			grid_pos += pow(-1,math.randint(0,1))
		emit_signal("laser_spawned",grid_pos)
	