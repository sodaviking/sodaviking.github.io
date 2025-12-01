extends CollisionShape2D

var parent
var timer := 0.0

func _ready():
	parent = get_parent()

func _process(delta):
	timer += delta
	if timer >= 0.5:
		timer = 0.0
		print(parent.transform)
