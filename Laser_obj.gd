extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var tween_node = $Tween
var active = true
var active_frames = 6;
signal kill_zone(body)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$activetimer.set_wait_time(active_frames/60)

func _on_Tween_tween_completed(object, key):
	get_tree().queue_delete(self)


func _on_Laser_obj_body_entered(body):
	if active:
		print(body)
		emit_signal("kill_zone", body)


func _on_activetimer_timeout():
	active = false
	tween_node.interpolate_property(self, "scale:y", 
	1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_node.interpolate_property(self, "modulate", 
	Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_node.start()
