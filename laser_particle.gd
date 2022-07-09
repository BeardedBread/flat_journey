extends Particles2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var laser_sound = $laser_sfx

func _ready():
	emitting = true
	one_shot = true

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Timer_timeout():
	get_tree().queue_delete(self)
