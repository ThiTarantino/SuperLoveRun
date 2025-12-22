extends CharacterBody2D

enum PlantState { idle, attack, dead }

@onready var marker_2d: Marker2D = $Marker2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
const BOLA = preload("uid://qobv4172inqu")

var status: PlantState
var idle_count = 0 
var can_bola = true # Controla para disparar apenas uma vez no frame 4

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		PlantState.idle:
			idle_state(delta)
		PlantState.attack:
			attack_state(delta)
		PlantState.dead:
			dead_state(delta)

	move_and_slide()

func go_to_idle_state():
	status = PlantState.idle
	anim.play("idle")

func go_to_attack_state():
	status = PlantState.attack
	anim.play("ataque")
	idle_count = 0 
	can_bola = true # ESSENCIAL: Resetamos aqui para ela poder atirar no frame 4 deste novo ataque

func go_to_dead_state():
	status = PlantState.dead
	anim.play("dead")
	if hitbox:
		hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO

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
	
	# Dispara a bola exatamente no frame 4
	if anim.frame == 4 and can_bola:
		bola()
		can_bola = false # Garante que não atire de novo até o próximo go_to_attack_state
	
	# Volta para o idle no último frame
	if anim.frame == anim.sprite_frames.get_frame_count("ataque") - 1:
		go_to_idle_state()

func dead_state(_delta):
	velocity.x = 0 

func take_damage():
	go_to_dead_state()

func bola():
	var new_bola = BOLA.instantiate()
	# Adiciona como irmão para a bola não sumir se a planta morrer
	add_sibling(new_bola)
	
	# Usamos o marker_2d que você declarou no topo do script
	# E atribuímos a global_position dele para a global_position da bola
	new_bola.global_position = marker_2d.global_position
