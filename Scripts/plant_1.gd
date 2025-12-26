extends CharacterBody2D

enum PlantState { idle, attack, dead }

@export var olhar_para_direita: bool = false
var direcao_tiro = -1

@onready var marker_2d: Marker2D = $Marker2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
const BOLA = preload("uid://qobv4172inqu") # Verifique se este UID está correto

var status: PlantState
var idle_count = 0 
var can_bola = true 

func _ready() -> void:
	if olhar_para_direita:
		direcao_tiro = 1
		scale.x = -abs(scale.x)
	else:
		direcao_tiro = -1
		scale.x = abs(scale.x) 
	
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		PlantState.idle: idle_state(delta)
		PlantState.attack: attack_state(delta)
		PlantState.dead: dead_state(delta)

	move_and_slide()

func go_to_idle_state():
	status = PlantState.idle
	anim.play("idle")

func go_to_attack_state():
	status = PlantState.attack
	anim.play("ataque")
	idle_count = 0 
	can_bola = true 

func go_to_dead_state():
	status = PlantState.dead
	anim.play("dead")
	# DESLIGA A HITBOX PARA PARAR DE PULAR NELA
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	velocity = Vector2.ZERO
	Globals.score += 100

func idle_state(_delta):
	velocity.x = 0
	if anim.frame == anim.sprite_frames.get_frame_count("idle") - 1:
		idle_count += 1 
		if idle_count >= 2:
			go_to_attack_state()
		else:
			anim.set_frame(0)
			anim.play("idle")

func attack_state(_delta):
	velocity.x = 0
	if anim.frame == 4 and can_bola:
		bola()
		can_bola = false 
	if anim.frame == anim.sprite_frames.get_frame_count("ataque") - 1:
		go_to_idle_state()

func dead_state(_delta):
	velocity.x = 0 

func take_damage():
	go_to_dead_state()

func bola():
	var new_bola = BOLA.instantiate()
	add_sibling(new_bola)
	new_bola.global_position = marker_2d.global_position
	if "direction" in new_bola:
		new_bola.direction = direcao_tiro
