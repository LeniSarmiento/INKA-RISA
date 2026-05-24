extends Node2D

# Avatar mejorado: frames reales del guerrero/guerrera inca con lanza.
# Cambia de postura según la dirección del mouse en 8 sectores.
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

var aim_angle: float = 0.0
var bob_time: float = 0.0
var attack_time: float = 0.0
var damage_time: float = 0.0
var invulnerable_flash: float = 0.0

func _process(delta: float) -> void:
	bob_time += delta
	if attack_time > 0.0:
		attack_time = max(attack_time - delta, 0.0)
	if damage_time > 0.0:
		damage_time = max(damage_time - delta, 0.0)
	if invulnerable_flash > 0.0:
		invulnerable_flash = max(invulnerable_flash - delta, 0.0)
	queue_redraw()

func set_aim(angle_rad: float) -> void:
	aim_angle = angle_rad
	queue_redraw()

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
	var bob: float = sin(bob_time * 5.0) * 1.3
	var dir: Vector2 = Vector2(cos(aim_angle), sin(aim_angle)).normalized()
	var side: float = 1.0 if dir.x >= 0.0 else -1.0
	var alpha: float = 1.0
	if invulnerable_flash > 0.0 and int(invulnerable_flash * 20.0) % 2 == 0:
		alpha = 0.60

	# Sombra y aura del Inti detrás del personaje.
	draw_circle(Vector2(0, 40 + bob), 48.0, Color(0.0, 0.0, 0.0, 0.18))
	draw_circle(Vector2(0, -72 + bob), 68, Color(1.0, 0.67, 0.08, 0.10))
	draw_circle(Vector2(0, -72 + bob), 42, Color(0.0, 0.9, 1.0, 0.08))

	# Frame real del avatar. El sprite ya incluye postura y lanza.
	var texture: Texture2D = _get_current_texture()
	var sprite_rect: Rect2 = Rect2(Vector2(-150, -190 + bob), Vector2(300, 217))
	draw_texture_rect(texture, sprite_rect, false, Color(1.0, 1.0, 1.0, alpha))

	# Guía visual del apuntado: es delgada para no tapar la lanza del sprite.
	var hand: Vector2 = Vector2(16.0 * side, -92.0 + bob)
	var spear_tip: Vector2 = hand + dir * 142.0
	draw_line(hand, spear_tip, Color(1.0, 0.85, 0.18, 0.32), 2.0)
	if attack_time > 0.0:
		draw_circle(spear_tip, 12.0, Color(1.0, 0.72, 0.05, 0.28))
		draw_circle(spear_tip, 5.0, Color(1.0, 0.92, 0.20, 0.85))

func get_muzzle_global_position() -> Vector2:
	var dir: Vector2 = Vector2(cos(aim_angle), sin(aim_angle)).normalized()
	var side: float = 1.0 if dir.x >= 0.0 else -1.0
	var hand: Vector2 = Vector2(16.0 * side, -92.0)
	return global_position + hand + dir * 142.0
