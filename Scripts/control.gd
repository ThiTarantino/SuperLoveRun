extends Control

# Verifique estes caminhos com cuidado

@onready var coins_counter: Label = get_node_or_null("Container/coins/coins_counter")
@onready var score_counter: Label = get_node_or_null("Container/Score/score_counter2")


var minutes = 0
var seconds = 0
@export_range(0,5) var default_minutes :=1
@export_range(0,5) var default_seconds :=0



func _ready() -> void:
	# Só executa se o nó não for nulo


		coins_counter.text = str("%04d" % Globals.coins)
		score_counter.text = str("%06d" % Globals.score)


func _process(_delta: float) -> void:
	
		coins_counter.text = str("%04d" % Globals.coins)
		score_counter.text = str("%06d" % Globals.score)
