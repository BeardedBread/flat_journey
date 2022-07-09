extends VBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.RENDER_VIDEO_MEM_USED
	$FPSLabel.set_text("FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)))
	$NodeCount.set_text("Obj Node Count: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) + " ("+ str(Performance.OBJECT_COUNT) + ")")
	$ResCount.set_text("Res Count: " + str(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)))
	$VidMem.set_text("Video Memory: " + str(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)))
