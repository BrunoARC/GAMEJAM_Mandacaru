extends CharacterBody2D

# Movimento inspirado em Super Mario World.
# Valores em pixels por segundo (o mundo usa tiles de 16 px).

@export_group("Andar e correr")
@export var walk_speed: float = 90.0
@export var run_speed: float = 160.0
@export var acceleration: float = 300.0
@export var run_acceleration: float = 420.0
@export var friction: float = 400.0       # desaceleração ao soltar o direcional
@export var skid_decel: float = 900.0     # derrapagem ao inverter a direção
@export var air_acceleration: float = 260.0

@export_group("Pulo")
@export var jump_velocity: float = 300.0       # pulo parado
@export var run_jump_bonus: float = 50.0       # pulo extra na velocidade máxima
@export var gravity_holding: float = 600.0     # gravidade subindo com o botão segurado
@export var gravity_released: float = 1500.0   # gravidade ao soltar o botão / caindo
@export var max_fall_speed: float = 280.0
@export var coyote_time: float = 0.08          # pode pular logo após sair da borda
@export var jump_buffer_time: float = 0.1      # aceita o pulo pouco antes de tocar o chão

var facing: int = 1
var crouching: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const MENU_SCENE := "res://menu.tscn"
var dead: bool = false


func _ready() -> void:
	add_to_group("player")


# Chamado pelos inimigos ao encostar no jogador.
func die() -> void:
	if dead:
		return
	dead = true
	set_physics_process(false)
	get_tree().call_deferred("change_scene_to_file", MENU_SCENE)


func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("Left", "Right")
	var running := Input.is_action_pressed("Run")

	_update_timers(delta)
	_apply_gravity(delta)
	_handle_jump()
	_handle_horizontal(dir, running, delta)

	move_and_slide()
	_update_animation()


func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	# Segurar o pulo deixa a subida mais "flutuante"; soltar corta o pulo.
	var rising_held := velocity.y < 0.0 and Input.is_action_pressed("Jump")
	var g := gravity_holding if rising_held else gravity_released
	velocity.y = minf(velocity.y + g * delta, max_fall_speed)


func _handle_jump() -> void:
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		# Quanto mais rápido, mais alto o pulo (como no SMW).
		var speed_ratio := clampf(absf(velocity.x) / run_speed, 0.0, 1.0)
		velocity.y = -(jump_velocity + run_jump_bonus * speed_ratio)
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		crouching = false


func _handle_horizontal(dir: float, running: bool, delta: float) -> void:
	# Agachar só no chão; agachado o personagem desliza até parar.
	crouching = is_on_floor() and Input.is_action_pressed("Down")
	if crouching:
		dir = 0.0

	var max_speed := run_speed if running else walk_speed

	if dir == 0.0:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		return

	facing = int(signf(dir))

	if not is_on_floor():
		# No ar dá para corrigir a trajetória, com aceleração menor.
		velocity.x = move_toward(velocity.x, dir * max_speed, air_acceleration * delta)
		return

	if velocity.x != 0.0 and signf(velocity.x) != signf(dir):
		velocity.x = move_toward(velocity.x, 0.0, skid_decel * delta)
	elif absf(velocity.x) > max_speed:
		# Soltou o botão de correr: volta devagar para a velocidade de andar.
		velocity.x = move_toward(velocity.x, dir * max_speed, friction * delta)
	else:
		var accel := run_acceleration if running else acceleration
		velocity.x = move_toward(velocity.x, dir * max_speed, accel * delta)


func _update_animation() -> void:
	# scale.x negativo espelha também o offset, mantendo o sprite centrado.
	sprite.scale.x = absf(sprite.scale.x) * facing

	if not is_on_floor():
		sprite.play("jump")
	elif crouching or absf(velocity.x) < 5.0:
		sprite.play("idle")
	else:
		sprite.play("walk")
		sprite.speed_scale = clampf(absf(velocity.x) / walk_speed, 0.6, 2.0)
