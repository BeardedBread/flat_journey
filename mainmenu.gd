extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var rot = 0;
func _ready():
	randomize()
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$Spiny/highscore.set_text(str(Global.high_score))
	pass

func _physics_process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	rot += delta
	if rot > 2*PI:
		rot -= 2*PI
		
	if Global.playable and Input.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://gamescene.tscn")
	
	$Spiny.set_rotation(rot)


func _on_Tween_tween_completed(object, key):
	Global.playable = true
