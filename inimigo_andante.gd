extends "res://inimigo.gd"

# Anda de um lado para o outro. Se attack_range > 0, para e ataca
# quando o jogador chega perto (usa a animação "attack").

@export var speed: float = 25.0
@export var patrol_distance: float = 64.0
@export var attack_range: float = 0.0

var direction: int = 1
var start_x: float

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	super()
	start_x = position.x


func _physics_process(delta: float) -> void:
	var player := get_player()
	if attack_range > 0.0 and player and global_position.distance_to(player.global_position) < attack_range:
		sprite.flip_h = player.global_position.x < global_position.x
		sprite.play("attack")
		return

	position.x += speed * direction * delta
	if absf(position.x - start_x) >= patrol_distance:
		position.x = start_x + patrol_distance * direction
		direction = -direction

	# Os sprites olham para a direita.
	sprite.flip_h = direction < 0
	sprite.play("walk")
