extends Area2D

@export var next_level = ""

func _on_body_entered(_body: Node2D) -> void:

	call_deferred("load_next_scene")

func load_next_scene():
	Globals.coins = 0
	Globals.score = 0
	Globals.player_life = 2
	get_tree().change_scene_to_file("res://Scene/"+ next_level + ".tscn")
