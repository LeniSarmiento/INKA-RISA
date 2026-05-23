extends Node2D

const PLAYER_TEXTURE: Texture2D = preload("res://assets/images/player_inca_front.png")
const SHOOT_FRAMES: Array[Texture2D] = [
	preload("res://assets/images/player_frames/shoot_00.png"),
	preload("res://assets/images/player_frames/shoot_01.png"),
	preload("res://assets/images/player_frames/shoot_02.png"),
	preload("res://assets/images/player_frames/shoot_03.png"),
	preload("res://assets/images/player_frames/shoot_04.png"),
	preload("res://assets/images/player_frames/shoot_05.png")
]
const DAMAGE_FRAMES: Array[Texture2D] = [
	preload("res://assets/images/player_frames/damage_00.png"),
	preload("res://assets/images/player_frames/damage_01.png"),
	preload("res://assets/images/player_frames/damage_02.png"),
	preload("res://assets/images/player_frames/damage_03.png"),
	preload("res://assets/images/player_frames/damage_04.png")
]

var aim_angle: float = 0.0
var bob_time: float = 0.0
var invulnerable_flash: float = 0.0
var action_name: String = "idle"
var action_timer: float = 0.0
var shoot_duration: float = 0.26
var damage_duration: float = 0.48

func _process(delta: float) -> void:
	bob_time += delta
	if invulnerable_flash > 0.0:
		invulnerable_flash = max(invulnerable_flash - delta, 0.0)
	if action_timer > 0.0:
		action_timer = max(action_timer - delta, 0.0)
	else:
		action_name = "idle"
	queue_redraw()

func set_aim(angle_rad: float) -> void:
	aim_angle = angle_rad
	queue_redraw()

func start_shoot_animation() -> void:
	# Se activa cuando el jugador dispara: simple, abanico, rebote, rayo o guía.
	action_name = "shoot"
	action_timer = shoot_duration
	queue_redraw()

func pulse_damage() -> void:
	# Se activa cuando se pierde una vida o un objetivo se escapa.
	invulnerable_flash = damage_duration
	action_name = "damage"
	action_timer = damage_duration
	queue_redraw()

func _get_action_texture() -> Texture2D:
	if action_name == "shoot":
		var progress: float = 1.0 - clamp(action_timer / shoot_duration, 0.0, 1.0)
		var index: int = clamp(int(progress * float(SHOOT_FRAMES.size())), 0, SHOOT_FRAMES.size() - 1)
		return SHOOT_FRAMES[index]
	elif action_name == "damage":
		var progress: float = 1.0 - clamp(action_timer / damage_duration, 0.0, 1.0)
		var index: int = clamp(int(progress * float(DAMAGE_FRAMES.size())), 0, DAMAGE_FRAMES.size() - 1)
		return DAMAGE_FRAMES[index]
	return PLAYER_TEXTURE

func _draw() -> void:
	var bob: float = sin(bob_time * 7.0) * 3.0
	var body_rect: Rect2 = Rect2(Vector2(-47, -150 + bob), Vector2(94, 202))
	var alpha: float = 0.70 if invulnerable_flash > 0.0 and int(invulnerable_flash * 20.0) % 2 == 0 else 1.0

	# Aura solar del Inti.
	var aura_color: Color = Color(1.0, 0.67, 0.08, 0.12)
	var aura_blue: Color = Color(0.0, 0.7, 0.75, 0.10)
	if action_name == "shoot":
		aura_color = Color(1.0, 0.82, 0.05, 0.24)
		aura_blue = Color(0.0, 0.95, 1.0, 0.18)
	elif action_name == "damage":
		aura_color = Color(1.0, 0.05, 0.02, 0.23)
		aura_blue = Color(1.0, 0.10, 0.02, 0.12)

	draw_circle(Vector2(0, -48 + bob), 78, aura_color)
	draw_circle(Vector2(0, -48 + bob), 47, aura_blue)

	# Frame animado del personaje.
	var current_texture: Texture2D = _get_action_texture()
	draw_texture_rect(current_texture, body_rect, false, Color(1, 1, 1, alpha))

	# Punto de disparo y lanza/energía en la dirección del ángulo theta.
	var dir: Vector2 = Vector2(cos(aim_angle), sin(aim_angle)).normalized()
	var hand: Vector2 = Vector2(28, -58 + bob)
	var start: Vector2 = hand
	var end: Vector2 = hand + dir * 126.0
	var line_width: float = 5.0
	var orb_radius: float = 12.0
	var beam_alpha: float = 0.95
	if action_name == "shoot":
		line_width = 7.0
		orb_radius = 17.0
		beam_alpha = 1.0
	elif action_name == "damage":
		line_width = 3.0
		orb_radius = 9.0
		beam_alpha = 0.55

	draw_line(start, end, Color(1.0, 0.74, 0.16, beam_alpha), line_width)
	draw_circle(end, orb_radius, Color(1.0, 0.9, 0.16, beam_alpha))
	draw_line(start, hand + dir * 230.0, Color(1.0, 0.96, 0.40, 0.28), 2.0)

	if action_name == "damage":
		# Pequeña marca visual de golpe para que se note en pantalla.
		draw_arc(Vector2(0, -85 + bob), 62, deg_to_rad(205), deg_to_rad(330), 24, Color(1.0, 0.1, 0.05, 0.75), 4.0)

func get_muzzle_global_position() -> Vector2:
	var dir: Vector2 = Vector2(cos(aim_angle), sin(aim_angle)).normalized()
	return global_position + Vector2(28, -58) + dir * 116.0
