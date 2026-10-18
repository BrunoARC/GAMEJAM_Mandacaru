extends Area2D

class_name Inimigo

# Base dos animais perigosos: encostar no jogador manda de volta para o menu.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()


func get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player")
