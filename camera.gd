extends Camera2D

# Câmera estilo Super Mario World:
# - na horizontal fica um pouco à frente do personagem, para o lado que ele olha;
# - na vertical só sobe/desce quando ele pousa numa plataforma,
#   a não ser que saia demais da tela (pulo muito alto ou queda).

@export var look_ahead: float = 40.0
@export var horizontal_smoothing: float = 4.0
@export var vertical_smoothing: float = 5.0
@export var vertical_offset: float = -30.0  # mostra um pouco mais acima do personagem
@export var max_distance_above: float = 70.0
@export var max_distance_below: float = 40.0

var target_y: float

@onready var player: CharacterBody2D = get_parent()


func _ready() -> void:
	target_y = player.global_position.y + vertical_offset
	global_position = Vector2(player.global_position.x, target_y)
	reset_smoothing()


func _physics_process(delta: float) -> void:
	var target_x: float = player.global_position.x + look_ahead * player.facing
	global_position.x = lerpf(global_position.x, target_x, 1.0 - exp(-horizontal_smoothing * delta))

	var player_y := player.global_position.y + vertical_offset
	if player.is_on_floor():
		target_y = player_y
	elif player_y < target_y - max_distance_above:
		target_y = player_y + max_distance_above
	elif player_y > target_y + max_distance_below:
		target_y = player_y - max_distance_below
	global_position.y = lerpf(global_position.y, target_y, 1.0 - exp(-vertical_smoothing * delta))
