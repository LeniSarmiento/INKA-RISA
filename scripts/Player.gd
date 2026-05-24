extends Node2D

# Avatar del guerrero/guerrera inca con apuntado sincronizado al mouse.
# La dirección del sprite, la lanza visual, el punto de salida y el disparo usan el mismo ángulo θ.
const AIM_LEFT: Texture2D = preload("res://assets/images/player_aim_frames/aim_left.png")
const AIM_UP_LEFT: Texture2D = preload("res://assets/images/player_aim_frames/aim_up_left.png")
const AIM_UP: Texture2D = preload("res://assets/images/player_aim_frames/aim_up.png")
const AIM_UP_RIGHT: Texture2D = preload("res://assets/images/player_aim_frames/aim_up_right.png")
const AIM_RIGHT: Texture2D = preload("res://assets/images/player_aim_frames/aim_right.png")
const AIM_DOWN_RIGHT: Texture2D = preload("res://assets/images/player_aim_frames/aim_down_right.png")
const AIM_DOWN: Texture2D = preload("res://assets/images/player_aim_frames/aim_down.png")
const AIM_DOWN_LEFT: Texture2D = preload("res://assets/images/player_aim_frames/aim_down_left.png")

const ATTACK_LEFT: Texture2D = preload("res://assets/images/player_aim_frames/attack_left.png")
const ATTACK_UP_LEFT: Texture2D = preload("res://assets/images/player_aim_frames/attack_up_left.png")
const ATTACK_UP: Texture2D = preload("res://assets/images/player_aim_frames/attack_up.png")
const ATTACK_UP_RIGHT: Texture2D = preload("res://assets/images/player_aim_frames/attack_up_right.png")
const ATTACK_RIGHT: Texture2D = preload("res://assets/images/player_aim_frames/attack_right.png")
const ATTACK_DOWN_RIGHT: Texture2D = preload("res://assets/images/player_aim_frames/attack_down_right.png")
const ATTACK_DOWN: Texture2D = preload("res://assets/images/player_aim_frames/attack_down.png")
const ATTACK_DOWN_LEFT: Texture2D = preload("res://assets/images/player_aim_frames/attack_down_left.png")

const DAMAGE_LEFT: Texture2D = preload("res://assets/images/player_aim_frames/damage_left.png")
const DAMAGE_UP_LEFT: Texture2D = preload("res://assets/images/player_aim_frames/damage_up_left.png")
const DAMAGE_UP: Texture2D = preload("res://assets/images/player_aim_frames/damage_up.png")
const DAMAGE_UP_RIGHT: Texture2D = preload("res://assets/images/player_aim_frames/damage_up_right.png")
const DAMAGE_RIGHT: Texture2D = preload("res://assets/images/player_aim_frames/damage_right.png")
const DAMAGE_DOWN_RIGHT: Texture2D = preload("res://assets/images/player_aim_frames/damage_down_right.png")
const DAMAGE_DOWN: Texture2D = preload("res://assets/images/player_aim_frames/damage_down.png")
const DAMAGE_DOWN_LEFT: Texture2D = preload("res://assets/images/player_aim_frames/damage_down_left.png")

const AIM_ORIGIN_LOCAL: Vector2 = Vector2(12.0, -88.0)
const SPEAR_LENGTH: float = 142.0
const MIN_AIM_DISTANCE: float = 8.0

var aim_angle: float = 0.0
var aim_target_global: Vector2 = Vector2.ZERO
var bob_time: float = 0.0
var attack_time: float = 0.0
var damage_time: float = 0.0
var invulnerable_flash: float = 0.0

func _ready() -> void:
	# Objetivo inicial: apunta hacia la derecha para evitar un ángulo vacío al iniciar.
	aim_target_global = get_aim_origin_global_position() + Vector2.RIGHT * 300.0

func _process(delta: float) -> void:
	bob_time += delta
	if attack_time > 0.0:
		attack_time = maxf(attack_time - delta, 0.0)
	if damage_time > 0.0:
		damage_time = maxf(damage_time - delta, 0.0)
	if invulnerable_flash > 0.0:
		invulnerable_flash = maxf(invulnerable_flash - delta, 0.0)
	queue_redraw()

func set_aim(angle_rad: float) -> void:
	# Compatibilidad con versiones anteriores: permite seguir asignando θ directo.
	aim_angle = angle_rad
	var dir: Vector2 = Vector2(cos(aim_angle), sin(aim_angle)).normalized()
	aim_target_global = get_aim_origin_global_position() + dir * 500.0
	queue_redraw()

func set_aim_target(target_global: Vector2) -> void:
	# Este método sincroniza mouse, avatar, puntero visual y disparo.
	aim_target_global = target_global
	var origin: Vector2 = get_aim_origin_global_position()
	var direction: Vector2 = aim_target_global - origin
	if direction.length() >= MIN_AIM_DISTANCE:
		aim_angle = direction.angle()
	queue_redraw()

func get_aim_angle_rad() -> float:
	return aim_angle

func get_aim_angle_deg() -> float:
	return rad_to_deg(aim_angle)

func get_aim_direction() -> Vector2:
	return Vector2(cos(aim_angle), sin(aim_angle)).normalized()

func get_aim_origin_global_position() -> Vector2:
	return global_position + AIM_ORIGIN_LOCAL

func get_muzzle_global_position() -> Vector2:
	# La punta de la lanza es el mismo punto desde donde salen todos los disparos.
	return get_aim_origin_global_position() + get_aim_direction() * SPEAR_LENGTH

func play_attack() -> void:
	attack_time = 0.20
	queue_redraw()

func pulse_damage() -> void:
	damage_time = 0.50
	invulnerable_flash = 0.50
	queue_redraw()

func _get_aim_sector() -> String:
	var deg: float = rad_to_deg(aim_angle)
	if deg < -157.5 or deg >= 157.5:
		return "left"
	elif deg >= -157.5 and deg < -112.5:
		return "up_left"
	elif deg >= -112.5 and deg < -67.5:
		return "up"
	elif deg >= -67.5 and deg < -22.5:
		return "up_right"
	elif deg >= -22.5 and deg < 22.5:
		return "right"
	elif deg >= 22.5 and deg < 67.5:
		return "down_right"
	elif deg >= 67.5 and deg < 112.5:
		return "down"
	return "down_left"

func _get_current_texture() -> Texture2D:
	var sector: String = _get_aim_sector()
	if damage_time > 0.0:
		match sector:
			"left": return DAMAGE_LEFT
			"up_left": return DAMAGE_UP_LEFT
			"up": return DAMAGE_UP
			"up_right": return DAMAGE_UP_RIGHT
			"right": return DAMAGE_RIGHT
			"down_right": return DAMAGE_DOWN_RIGHT
			"down": return DAMAGE_DOWN
			_: return DAMAGE_DOWN_LEFT
	if attack_time > 0.0:
		match sector:
			"left": return ATTACK_LEFT
			"up_left": return ATTACK_UP_LEFT
			"up": return ATTACK_UP
			"up_right": return ATTACK_UP_RIGHT
			"right": return ATTACK_RIGHT
			"down_right": return ATTACK_DOWN_RIGHT
			"down": return ATTACK_DOWN
			_: return ATTACK_DOWN_LEFT
	match sector:
		"left": return AIM_LEFT
		"up_left": return AIM_UP_LEFT
		"up": return AIM_UP
		"up_right": return AIM_UP_RIGHT
		"right": return AIM_RIGHT
		"down_right": return AIM_DOWN_RIGHT
		"down": return AIM_DOWN
		_: return AIM_DOWN_LEFT

func _draw() -> void:
	var bob: float = sin(bob_time * 5.0) * 1.2
	var dir: Vector2 = get_aim_direction()
	var alpha: float = 1.0
	if invulnerable_flash > 0.0 and int(invulnerable_flash * 20.0) % 2 == 0:
		alpha = 0.60

	# Sombra y aura del Inti detrás del personaje.
	draw_circle(Vector2(0, 38 + bob), 48.0, Color(0.0, 0.0, 0.0, 0.18))
	draw_circle(Vector2(0, -72 + bob), 68.0, Color(1.0, 0.67, 0.08, 0.10))
	draw_circle(Vector2(0, -72 + bob), 42.0, Color(0.0, 0.9, 1.0, 0.08))

	# Frame del avatar inclinado. El sector cambia por el mismo ángulo usado para disparar.
	var texture: Texture2D = _get_current_texture()
	var sprite_rect: Rect2 = Rect2(Vector2(-154.0, -190.0 + bob), Vector2(308.0, 222.0))
	draw_texture_rect(texture, sprite_rect, false, Color(1.0, 1.0, 1.0, alpha))

	# Lanza/puntero exacto: este dibujo SÍ coincide con el mouse y con el disparo.
	var origin: Vector2 = AIM_ORIGIN_LOCAL + Vector2(0.0, bob)
	var muzzle: Vector2 = origin + dir * SPEAR_LENGTH
	var target_local: Vector2 = to_local(aim_target_global)

	# Guía tenue hacia el mouse.
	draw_line(muzzle, target_local, Color(0.0, 0.95, 1.0, 0.18), 1.5)
	# Lanza principal sincronizada.
	draw_line(origin, muzzle, Color(0.16, 0.08, 0.02, 0.90), 8.0)
	draw_line(origin, muzzle, Color(0.95, 0.55, 0.16, 0.95), 4.0)
	draw_circle(origin, 8.0, Color(1.0, 0.72, 0.10, 0.90))

	# Punta triangular de lanza en la misma dirección del disparo.
	var normal: Vector2 = Vector2(-dir.y, dir.x)
	var tip_a: Vector2 = muzzle + dir * 18.0
	var tip_b: Vector2 = muzzle - dir * 10.0 + normal * 8.0
	var tip_c: Vector2 = muzzle - dir * 10.0 - normal * 8.0
	draw_colored_polygon(PackedVector2Array([tip_a, tip_b, tip_c]), Color(0.95, 0.92, 0.75, 0.95))
	draw_line(tip_b, tip_c, Color(0.25, 0.20, 0.12, 0.80), 2.0)

	# Punto de salida del proyectil.
	draw_circle(muzzle, 5.0, Color(1.0, 0.92, 0.20, 0.95))
	if attack_time > 0.0:
		draw_circle(muzzle, 17.0, Color(1.0, 0.72, 0.05, 0.26))
		draw_circle(muzzle, 8.0, Color(1.0, 0.92, 0.20, 0.88))
