extends CanvasLayer

@onready var menu_principal = $MenuFases/VBoxContainer
@onready var painel_fases = $MenuFases/PanelContainer
@onready var grid_fases = $MenuFases/PanelContainer/GridContainer
@onready var btn_voltar = $MenuFases/ButtonVoltar

func _ready():
	painel_fases.visible = false
	btn_voltar.visible = false
	menu_principal.visible = true
	
	# Permite o toque passar pelos painéis cinzas
	painel_fases.mouse_filter = Control.MOUSE_FILTER_PASS
	grid_fases.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Botões principais
	$MenuFases/VBoxContainer/Button.pressed.connect(func(): _carregar("res://Scene/1.tscn"))
	$MenuFases/VBoxContainer/Button2.pressed.connect(_on_fases_pressed)
	$MenuFases/VBoxContainer/Button3.pressed.connect(func(): get_tree().quit())
	btn_voltar.pressed.connect(_on_voltar_pressed)
	
	# Configura botões de fase (Fase1 a Fase6)
	for i in range(1, 11):
		var btn = grid_fases.get_node_or_null("Fase" + str(i))
		if btn:
			btn.custom_minimum_size = Vector2(30, 30) # Quadrado
			btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			btn.add_theme_color_override("font_color", Color(0, 0, 0)) # Preto
			btn.add_theme_font_size_override("font_size", 12) # Fonte pequena
			btn.pressed.connect(func(): _carregar("res://Scene/" + str(i) + ".tscn"))

func _carregar(caminho):
	if ResourceLoader.exists(caminho):
		# call_deferred ajuda a evitar erros de renderização no celular
		get_tree().call_deferred("change_scene_to_file", caminho)

func _on_fases_pressed():
	menu_principal.visible = false
	painel_fases.visible = true
	btn_voltar.visible = true

func _on_voltar_pressed():
	painel_fases.visible = false
	btn_voltar.visible = false
	menu_principal.visible = true
