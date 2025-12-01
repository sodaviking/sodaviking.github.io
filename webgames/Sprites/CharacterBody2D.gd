extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -600.0
const PUNCH_DURATION = 0.2
const COOLDOWN = 0.4

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var canPunch = true
var is_punching = false

@onready var sprite = $ChefspriteNew
@onready var punchSprite = $PunchSprite 
@onready var punch_hit_box = $PunchSprite/PunchHitBox
@onready var punch_hit_box2 = $PunchSprite/PunchHitBox2
@onready var swishSFX = $swish
@onready var jumpSprite = $Jump

func _physics_process(delta):
	handle_gravity(delta)
	handle_jump()
	handle_movement(delta)
	move_and_slide()

func _process(_delta):
	check_and_start_punch()
	update_sprite_visibility()

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if (Input.is_key_label_pressed(KEY_X) or Input.is_action_just_pressed("ui_accept")) and is_on_floor() and not is_punching:
		velocity.y = JUMP_VELOCITY

func handle_movement(_delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	velocity.x = direction * SPEED if direction != 0 else move_toward(velocity.x, 0, SPEED)
	
	# Flip sprites based on movement direction
	if direction != 0:
		sprite.flip_h = direction < 0
		jumpSprite.flip_h = direction < 0
		punchSprite.flip_h = direction < 0

func update_sprite_visibility():
	if is_punching:
		# Only punch sprite visible
		sprite.visible = false
		jumpSprite.visible = false
		punchSprite.visible = true
	else:
		punchSprite.visible = false
		if is_on_floor():
			sprite.visible = true
			jumpSprite.visible = false
		else:
			sprite.visible = false
			jumpSprite.visible = true

func check_and_start_punch():
	if Input.is_key_label_pressed(KEY_Z) and canPunch and not is_punching:
		canPunch = false
		if sprite.flip_h:
			start_punch(punch_hit_box2)
		else:
			start_punch(punch_hit_box)

func start_punch(hitbox: Area2D) -> void:
	is_punching = true
	hitbox.monitoring = true
	punchSprite.visible = true
	sprite.visible = false
	jumpSprite.visible = false
	swishSFX.play()
	
	await get_tree().create_timer(PUNCH_DURATION).timeout
	
	hitbox.monitoring = false
	punchSprite.visible = false
	
	await get_tree().create_timer(COOLDOWN).timeout
	
	is_punching = false
	canPunch = true
