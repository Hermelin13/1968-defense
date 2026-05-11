extends PathFollow2D


var speed = 300

func _physics_process(delta):
	mode(delta)

func mode(delta):
	progress += speed * delta
