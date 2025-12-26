extends CharacterBody2D

enum SkeletonState { walk, dead }

const SPEED = 15.0 # 300 pode ser muito rápido para um esqueleto!
const JUMP_VELOCITY = -400.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector

var status: SkeletonState
var direction = 1

func _ready() -> void:
	go_to_Walk_state()

func _physics_process(delta: float) -> void:
	# 1. Aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# 2. Gerencia a lógica de estados
	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.dead:
			dead_state(delta)

	# 3. EXECUTA O MOVIMENTO 
	move_and_slide()

func go_to_Walk_state():
	status = SkeletonState.walk
	anim.play("walk")

func go_to_dead_state():
	status = SkeletonState.dead
	anim.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	Globals.score += 100

func walk_state(_delta):
	if anim.frame == 3 or anim.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	if !ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	


func dead_state(_delta):
	velocity.x = 0 # Garante que ele não deslize depois de morto

func take_damage():
	go_to_dead_state()
