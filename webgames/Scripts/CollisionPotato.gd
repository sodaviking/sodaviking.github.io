extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print("loaded")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(_body):
	print("sigma")
