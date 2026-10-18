extends "res://inimigo.gd"

# Cascavel: fica enrolada olhando para o jogador e, a cada strike_interval
# segundos, dá um bote na direção dele avançando strike_distance pixels.

@export var strike_interval: float = 4.0
@export var strike_distance: float = 32.0  # 2 tiles de 16 px
@export var strike_duration: float = 0.15

# Ponto do sprite (em px, a partir da esquerda) onde fica o centro da rodilha.
# Mantém a rodilha parada quando a animação troca entre "idle" e "strike".
const COIL_X := 15.0
const IDLE_SHAPE := Vector2(26, 14)
const STRIKE_SHAPE := Vector2(48, 14)

var facing: int = 1
var striking: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer


func _ready() -> void:
	super()
	timer.wait_time = strike_interval
	timer.timeout.connect(_strike)
	timer.start()
	sprite.play("idle")
	_update_visual()


func _physics_process(_delta: float) -> void:
	if striking:
		return
	var player := get_player()
	if player:
		facing = 1 if player.global_position.x >= global_position.x else -1
	_update_visual()


func _strike() -> void:
	if get_player() == null:
		return
	striking = true
	sprite.play("strike")
	_update_visual()

	var tween := create_tween()
	tween.tween_property(self, "position:x", position.x + strike_distance * facing, strike_duration)
	await sprite.animation_finished

	striking = false
	sprite.play("idle")
	_update_visual()


func _update_visual() -> void:
	var tex := sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	var w := float(tex.get_width())
	sprite.flip_h = facing < 0
	# Com flip_h a imagem espelha dentro do mesmo retângulo, então o offset muda.
	sprite.offset = Vector2(-COIL_X if facing > 0 else COIL_X - w, -tex.get_height())

	var rect: RectangleShape2D = shape.shape
	rect.size = STRIKE_SHAPE if striking else IDLE_SHAPE
	var center_x := (rect.size.x - IDLE_SHAPE.x) / 2.0
	shape.position = Vector2(center_x * facing, -rect.size.y / 2.0 - 1.0)
