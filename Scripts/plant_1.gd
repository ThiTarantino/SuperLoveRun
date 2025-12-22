extends CharacterBody2D

enum PlantState { idle, attack, dead }

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var status: PlantState
var idle_count = 0 # Variável para contar as repetições

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	# 1. Aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# 2. Gerencia a lógica de estados
	match status:
		PlantState.idle:
			idle_state(delta)
		PlantState.attack:
			attack_state(delta)
		PlantState.dead:
			dead_state(delta)

	# 3. EXECUTA O MOVIMENTO 
	move_and_slide()

func go_to_idle_state():
	status = PlantState.idle
	anim.play("idle")

func go_to_attack_state():
	status = PlantState.attack
	anim.play("ataque")
	idle_count = 0 # Reseta a contagem ao iniciar o ataque

func go_to_dead_state():
	status = PlantState.dead
	anim.play("dead")
	# Desabilita a hitbox como no esqueleto
	if hitbox:
		hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO

func idle_state(_delta):
	velocity.x = 0
	
	# Verifica se chegou no último frame do idle
	if anim.frame == anim.sprite_frames.get_frame_count("idle") - 1:
		idle_count += 1 # Soma 1 na contagem
		
		if idle_count >= 2:
			go_to_attack_state()
		else:
			anim.set_frame(0) # Volta para o início do idle para repetir
			anim.play("idle")

func attack_state(_delta):
	velocity.x = 0
	
	# Quando terminar a animação de ataque, volta para o idle para recomeçar o ciclo
	if anim.frame == anim.sprite_frames.get_frame_count("ataque") - 1:
		go_to_idle_state()

func dead_state(_delta):
	velocity.x = 0 
	# Para garantir que ela não suma e fique no último frame da morte:
	# No editor do AnimatedSprite2D, desative a opção "Loop" da animação "dead".

func take_damage():
	go_to_dead_state()
