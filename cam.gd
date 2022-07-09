extends Camera2D

func _physics_process(delta):
	# Go back to 0 offset
	set_offset(get_offset()/2)
