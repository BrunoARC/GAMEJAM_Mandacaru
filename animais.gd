extends Area2D

class_name Animais

@export var h_speed: float = 20.0
@export var v_speed: float = 100.0
@export var direcao: int = 1
@onready var ray_cast_2d = $RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D

func _process(delta: float) -> void:
	position.x += h_speed * direcao * delta
	animated_sprite_2d.flip_h = direcao < 0
	if !ray_cast_2d.is_colliding():
		position.y += v_speed * direcao * delta
