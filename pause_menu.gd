extends CanvasLayer

@onready var menu_holder = $menu_holder # Onde estão seus botões

func _ready() -> void:
	visible = false # Começa escondido

func _unhandled_input(event: InputEvent) -> void:
	# Define uma tecla (ex: "ui_cancel" que é o Esc) nas Configurações do Projeto
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state # Mostra/esconde o menu

# Conecte o sinal 'pressed' do seu pause_btn aqui
func _on_pause_btn_pressed() -> void:
	_toggle_pause()

# Conecte o sinal 'pressed' do seu quit_btn aqui
func _on_quit_btn_pressed() -> void:
	get_tree().quit() # Fecha o jogo
