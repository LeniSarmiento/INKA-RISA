extends Node2D

const PLAYER_TEXTURE: Texture2D = preload("res://assets/images/player_inca_front.png")

var aim_angle: float = 0.0
var bob_time: float = 0.0
var invulnerable_flash: float = 0.0

func _process(delta: float) -> void:
	bob_time += delta
	if invulnerable_flash > 0.0:
		invulnerable_flash -= delta
	queue_redraw()

func set_aim(angle_rad: float) -> void:
	aim_angle = angle_rad
	queue_redraw()

func pulse_damage() -> void:
	invulnerable_flash = 0.35
	queue_redraw()

func _draw() -> void:
	var bob := sin(bob_time * 7.0) * 3.0
	var body_rect := Rect2(Vector2(-47, -150 + bob), Vector2(94, 202))
	var alpha := 0.70 if invulnerable_flash > 0.0 and int(invulnerable_flash * 20.0) % 2 == 0 else 1.0

	# Aura solar del Inti.
	draw_circle(Vector2(0, -48 + bob), 78, Color(1.0, 0.67, 0.08, 0.12))
	draw_circle(Vector2(0, -48 + bob), 47, Color(0.0, 0.7, 0.75, 0.10))

	# Personaje real del proyecto, recortado desde la lámina de referencia.
	draw_texture_rect(PLAYER_TEXTURE, body_rect, false, Color(1, 1, 1, alpha))

	# Punto de disparo y lanza/energía en la dirección del ángulo theta.
	var dir := Vector2(cos(aim_angle), sin(aim_angle)).normalized()
	var hand := Vector2(28, -58 + bob)
	var start := hand
	var end := hand + dir * 126.0
	draw_line(start, end, Color(1.0, 0.74, 0.16, 0.95), 5.0)
	draw_circle(end, 12, Color(1.0, 0.9, 0.16, 0.92))
	draw_line(start, hand + dir * 230.0, Color(1.0, 0.96, 0.40, 0.28), 2.0)

func get_muzzle_global_position() -> Vector2:
	var dir := Vector2(cos(aim_angle), sin(aim_angle)).normalized()
	return global_position + Vector2(28, -58) + dir * 116.0
