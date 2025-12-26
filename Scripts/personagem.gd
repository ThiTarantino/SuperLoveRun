extends CharacterBody2D

enum PlayerState { idle, walk, jump, fall, duck, slide, dead }

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var reaload_timer: Timer = $RealoadTimer
@onready var audio_jump: AudioStreamPlayer = $AudioStreamPlayer

@export var max_speed = 80.0
@export var acceleration = 450
@export var decceleration = 700
@export var slide_decceleration = 40
const JUMP_VELOCITY = -300.0

var jump_count = 0
@export var max_jump_count = 2
var direction = 0
var status: PlayerState
var is_invincible = false 

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		PlayerState.idle: idle_state(delta)
		PlayerState.walk: walk_state(delta)
		PlayerState.jump: jump_state(delta)
		PlayerState.fall: fall_state(delta)
		PlayerState.duck: duck_state(delta)
		PlayerState.slide: slide_state(delta)
		PlayerState.dead: dead_state(delta)
			
	move_and_slide()

# --- ESTADOS ---
func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	audio_jump.play() 

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")

func go_to_duck_state():
	status = PlayerState.duck
	anim.play("duck")
	set_small_collider()	

func go_to_slide_state():
	status = PlayerState.slide
	anim.play("slide")
	set_small_collider()

func exit_from_duck_state():
	set_large_collider()	

func exit_from_slide_state():
	set_large_collider()

func go_to_dead_state():
	if status == PlayerState.dead:
		return
	status = PlayerState.dead
	anim.play("dead")
	velocity = Vector2.ZERO
	reaload_timer.start()

# --- LÓGICA DE DANO ---
func take_damage():
	if is_invincible or status == PlayerState.dead:
		return
	Globals.player_life -= 1 
	if Globals.player_life <= 0:
		go_to_dead_state()
	else:
		_start_invincibility()

func _start_invincibility():
	is_invincible = true
	var tween = create_tween()
	for i in range(5):
		tween.tween_property(anim, "modulate:a", 0.0, 0.1)
		tween.tween_property(anim, "modulate:a", 1.0, 0.1)
	await tween.finished
	is_invincible = false

func hit_enemy(area: Area2D):
	var inimigo = area.get_parent()
	
	# SÓ PULA se o inimigo NÃO estiver morto (PlantState.dead ou similar)
	if velocity.y > 0 and inimigo.has_method("take_damage") and inimigo.status != 2: # 2 costuma ser o index de 'dead' no enum
		inimigo.take_damage()
		go_to_jump_state()
	else:
		# Se ele já estiver morto ou for colisão lateral, player toma dano
		take_damage()

# --- MOVIMENTAÇÃO ---
func move(delta):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, decceleration * delta)	

func update_direction():
	direction = Input.get_axis("left", "right")
	if direction < 0: anim.flip_h = true
	elif direction > 0: anim.flip_h = false

func can_jump() -> bool:
	return jump_count < max_jump_count

# --- ESTADOS (LOGIC) ---
func idle_state(delta):
	move(delta)
	if velocity.x != 0: go_to_walk_state()
	elif Input.is_action_just_pressed("jump"): go_to_jump_state()
	elif Input.is_action_pressed("duck"): go_to_duck_state()

func walk_state(delta):
	move(delta)
	if velocity.x == 0: go_to_idle_state()
	elif Input.is_action_just_pressed("jump"): go_to_jump_state()
	elif Input.is_action_just_pressed("duck"): go_to_slide_state()
	elif !is_on_floor():
		jump_count += 1
		go_to_fall_state()

func jump_state(delta):
	move(delta)
	if Input.is_action_just_pressed("jump") and can_jump(): go_to_jump_state()
	elif velocity.y > 0: go_to_fall_state()

func fall_state(delta):
	move(delta)
	if Input.is_action_just_pressed("jump") and can_jump(): go_to_jump_state()
	elif is_on_floor():
		jump_count = 0
		if velocity.x == 0: go_to_idle_state()
		else: go_to_walk_state()

func duck_state(_delta):
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()

func slide_state(delta):
	velocity.x = move_toward(velocity.x, 0, slide_decceleration * delta )
	if Input.is_action_just_released("duck"):
		exit_from_slide_state()
		go_to_walk_state()
	elif velocity.x == 0:
		exit_from_slide_state()
		go_to_duck_state()

func dead_state(_delta):
	velocity.x = 0

# --- COLLIDERS ---
func set_small_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 8
	collision_shape.position.y = 11

func set_large_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 22
	collision_shape.position.y = 4	

# --- DETECÇÃO DE ÁREA ---
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		# Se for a BOLA, não tem pulo, é só dano direto
		if area.name.contains("bola") or area.name.contains("BOLA"):
			take_damage()
			area.queue_free()
		else:
			hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		go_to_dead_state()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("LethalArea"):
		go_to_dead_state()

# --- RELOAD (AJUSTADO PARA 2 VIDAS) ---
func _on_reaload_timer_timeout() -> void:
	Globals.coins = 0
	Globals.score = 0
	Globals.player_life = 2 # DEFINE 2 VIDAS AQUI
	get_tree().reload_current_scene()
