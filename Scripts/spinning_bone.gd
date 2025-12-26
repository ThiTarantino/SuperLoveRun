extends Area2D

var speed = 60
var direction = 1

func _process(delta: float) -> void:
	position.x += speed * delta * direction

func _on_area_entered(_area: Area2D) -> void:
	queue_free() # Some ao bater no player ou outras áreas

func _on_body_entered(_body: Node2D) -> void:
	queue_free() # Some ao bater em paredes
