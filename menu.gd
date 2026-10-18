extends Control

# Menu inicial: qualquer tecla, clique ou botão do controle começa o jogo.

const GAME_SCENE := "res://main.tscn"
# Evita reiniciar sem querer com uma tecla apertada logo após morrer.
const INPUT_DELAY := 0.5

@onready var label: Label = $Label


func _ready() -> void:
	set_process_unhandled_input(false)
	get_tree().create_timer(INPUT_DELAY).timeout.connect(set_process_unhandled_input.bind(true))

	# Faz a frase piscar devagar.
	var tween := create_tween().set_loops()
	tween.tween_property(label, "modulate:a", 0.3, 0.8)
	tween.tween_property(label, "modulate:a", 1.0, 0.8)


func _unhandled_input(event: InputEvent) -> void:
	var pressed := event.is_pressed() and not event.is_echo()
	if pressed and (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton):
		set_process_unhandled_input(false)
		get_tree().change_scene_to_file(GAME_SCENE)
