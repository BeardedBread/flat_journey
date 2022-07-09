extends Node2D
# This is to encapsulate information about the gap obstacles and position

var shift_proximity

onready var topwall = $Top
onready var bottomwall = $Bottom
var gap_size
var gap_pos
var true_pos
var hspeed = Vector2(0,0)
var tracking_player
var shift_set = false

signal out_of_bound(wall)
signal moving(state)


func _ready():
	self.position.x = gap_pos.x;
	topwall.position = Vector2(0,(gap_pos.y - gap_size/2)*Global.GRID_SIZE)
	topwall.set_scale(Vector2(1, -30))
	bottomwall.position = Vector2(0, (gap_pos.y+gap_size/2)*Global.GRID_SIZE)
	bottomwall.set_scale(Vector2(1, 30))
	bottomwall.connect("moving", self, "_emit_moving")
	
	shift_set = int(true_pos-gap_pos.y) != 0
	shift_proximity = abs(hspeed.x) * 40

func _physics_process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	position += hspeed
	
	if shift_set and abs(position.x -tracking_player.get_ref().position.x) < shift_proximity:
		shift_set = false
		topwall.shift_position((true_pos-gap_pos.y)*Global.GRID_SIZE)
		bottomwall.shift_position((true_pos-gap_pos.y)*Global.GRID_SIZE)
	
	if position.x< - topwall.w:
		emit_signal("out_of_bound", self)
		get_tree().queue_delete(self)

func _emit_moving(state):
	emit_signal("moving", state)

