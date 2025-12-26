extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# --- NOVAS VARIÁVEIS (ADICIONE AQUI) ---
@export var bala_scene: PackedScene # Arraste o arquivo .tscn da bala para cá no Inspetor
@export var olhar_para_esquerda: bool = true # Marque ou desmarque no Inspetor da fase

var direcao_tiro = -1
# ---------------------------------------

func _ready() -> void:
	# Configura a direção inicial baseada no que você marcou no Inspetor
	if olhar_para_esquerda:
		direcao_tiro = -1
		scale.x = abs(scale.x) * -1
	else:
		direcao_tiro = 1
		scale.x = abs(scale.x) * 1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# --- NOVA FUNÇÃO DE TIRO (ADICIONE AO FINAL) ---
func atirar():
	if bala_scene:
		var bala = bala_scene.instantiate()
		# O Marker2D deve estar dentro da Plant1
		bala.global_position = $Marker2D.global_position 
		
		# Passa a direção para a bala (1 ou -1)
		if bala.has_method("set_direction"):
			bala.set_direction(direcao_tiro)
		else:
			bala.direcao = direcao_tiro
			
		get_tree().root.add_child(bala)
