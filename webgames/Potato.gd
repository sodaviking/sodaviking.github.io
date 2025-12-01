extends RigidBody2D

@onready var audio = get_parent().find_child("hit")
@onready var potatoSprite = $Sprite2D

signal potatohit

const popVFX = preload("res://Sprites/VFX/vfxpunch.png")

func _hit():
	emit_signal("potatohit")
	audio.play(0.0)
	potatoSprite.texture = popVFX
	sleeping = true
	await audio.finished
	queue_free()

var is_punching = false

func _ready():

	var hurt_box = find_child("Area2D") 
	if hurt_box:
		hurt_box.area_entered.connect(_on_area_entered)
	print("loaded")


func _on_area_entered(area: Area2D):
	if area.name == "PunchHitBox" and area.monitoring == true or area.name == "PunchHitBox2" and area.monitoring == true:
		_hit()


func _on_body_entered(_body):
	print("sigma")


func _process(_delta):
	pass

