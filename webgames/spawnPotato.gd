extends StaticBody2D

const POTATO_SCENE = preload("res://potato_object.tscn") # Använd rätt filnamn här

var viewport_width = 0
var spawn_height = -100

@onready var spawn_timer = $SpawnTimer
@onready var main = get_parent()

func _ready():
	# Hämta viewportens (skärmens) bredd vid start
	viewport_width = get_viewport_rect().size.x
	# Koden för timern ska vara korrekt ansluten via editorn
	pass


func _on_spawn_timer_timeout():
	spawn_potato()


func spawn_potato():
	var new_potato = POTATO_SCENE.instantiate()
	
	get_parent().add_child(new_potato)
	new_potato.connect("potatohit", Callable(main, "_on_potato_object_potatohit"))

	var random_x = randf_range(0, viewport_width)
	new_potato.global_position = Vector2(random_x, global_position.y + spawn_height)
	new_potato.sleeping = false
	print("Potatis skapades vid position:", new_potato.global_position)
