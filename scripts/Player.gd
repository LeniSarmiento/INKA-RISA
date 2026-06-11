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

var FRONT_IDLE: Texture2D
var BACK_IDLE: Texture2D
var RIGHT_IDLE: Texture2D
var RIGHT_WALK_1: Texture2D
var RIGHT_WALK_2: Texture2D
var RIGHT_WALK_3: Texture2D
var LEFT_IDLE: Texture2D
var LEFT_WALK_1: Texture2D
var LEFT_WALK_2: Texture2D
var LEFT_WALK_3: Texture2D
var JUMP_1: Texture2D
var JUMP_2: Texture2D
var JUMP_3: Texture2D
var JUMP_4: Texture2D
var ATTACK_POSE_1: Texture2D
var ATTACK_POSE_2: Texture2D
var ATTACK_POSE_3: Texture2D
var ATTACK_POSE_4: Texture2D
var DAMAGE_POSE_1: Texture2D
var DAMAGE_POSE_2: Texture2D
var DAMAGE_POSE_3: Texture2D
var DAMAGE_POSE_4: Texture2D

const AIM_ORIGIN_LOCAL: Vector2 = Vector2(12.0, -44.0)
const SPEAR_LENGTH: float = 58.0
const MIN_AIM_DISTANCE: float = 8.0

var aim_angle: float = 0.0
var aim_target_global: Vector2 = Vector2.ZERO
var bob_time: float = 0.0
var attack_time: float = 0.0
var damage_time: float = 0.0
var invulnerable_flash: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var ground_y: float = 615.0
var facing_direction: int = 1
var is_on_ground: bool = true
var walk_time: float = 0.0
var platform_rects: Array[Rect2] = []

const MOVE_SPEED: float = 230.0
const JUMP_SPEED: float = 640.0
const GRAVITY: float = 1750.0
const FRICTION: float = 2200.0
const SCREEN_MARGIN: float = 32.0

func _ready() -> void:
	# Objetivo inicial: apunta hacia la derecha para evitar un ángulo vacío al iniciar.
	_load_movement_frames()
	ground_y = global_position.y
	aim_target_global = get_aim_origin_global_position() + Vector2.RIGHT * 300.0

func _load_movement_frames() -> void:
	FRONT_IDLE = _load_movement_texture("front_idle.png", AIM_DOWN)
	BACK_IDLE = _load_movement_texture("back_idle.png", AIM_UP)
	RIGHT_IDLE = _load_movement_texture("right_idle.png", AIM_RIGHT)
	RIGHT_WALK_1 = _load_movement_texture("right_walk_1.png", AIM_RIGHT)
	RIGHT_WALK_2 = _load_movement_texture("right_walk_2.png", AIM_RIGHT)
	RIGHT_WALK_3 = _load_movement_texture("right_walk_3.png", AIM_RIGHT)
	LEFT_IDLE = _load_movement_texture("left_idle.png", AIM_LEFT)
	LEFT_WALK_1 = _load_movement_texture("left_walk_1.png", AIM_LEFT)
	LEFT_WALK_2 = _load_movement_texture("left_walk_2.png", AIM_LEFT)
	LEFT_WALK_3 = _load_movement_texture("left_walk_3.png", AIM_LEFT)
	JUMP_1 = _load_movement_texture("jump_idle.png", AIM_UP)
	JUMP_2 = _load_movement_texture("jump_walk_1.png", AIM_UP)
	JUMP_3 = _load_movement_texture("jump_walk_2.png", AIM_UP)
	JUMP_4 = _load_movement_texture("jump_walk_3.png", AIM_UP)
	ATTACK_POSE_1 = _load_movement_texture("attack_idle.png", ATTACK_RIGHT)
	ATTACK_POSE_2 = _load_movement_texture("attack_walk_1.png", ATTACK_RIGHT)
	ATTACK_POSE_3 = _load_movement_texture("attack_walk_2.png", ATTACK_RIGHT)
	ATTACK_POSE_4 = _load_movement_texture("attack_walk_3.png", ATTACK_RIGHT)
	DAMAGE_POSE_1 = _load_movement_texture("damage_idle.png", DAMAGE_RIGHT)
	DAMAGE_POSE_2 = _load_movement_texture("damage_walk_1.png", DAMAGE_RIGHT)
	DAMAGE_POSE_3 = _load_movement_texture("damage_walk_2.png", DAMAGE_RIGHT)
	DAMAGE_POSE_4 = _load_movement_texture("damage_walk_3.png", DAMAGE_RIGHT)

func _load_movement_texture(file_name: String, fallback: Texture2D) -> Texture2D:
	var path: String = "res://assets/images/player_movement_frames/" + file_name
	var file_path: String = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(file_path):
		var image: Image = Image.load_from_file(file_path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)
	var texture: Resource = load(path)
	if texture is Texture2D:
		return texture as Texture2D
	return fallback

func _process(delta: float) -> void:
	_update_platform_movement(delta)
	bob_time += delta
	if attack_time > 0.0:
		attack_time = maxf(attack_time - delta, 0.0)
	if damage_time > 0.0:
		damage_time = maxf(damage_time - delta, 0.0)
	if invulnerable_flash > 0.0:
		invulnerable_flash = maxf(invulnerable_flash - delta, 0.0)
	queue_redraw()

func _update_platform_movement(delta: float) -> void:
	var previous_position: Vector2 = global_position
	var input_axis: float = 0.0
	if Input.is_key_pressed(KEY_LEFT):
		input_axis -= 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		input_axis += 1.0

	if absf(input_axis) > 0.01:
		velocity.x = input_axis * MOVE_SPEED
		facing_direction = int(sign(input_axis))
		walk_time += delta * 10.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	if is_on_ground and (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)):
		velocity.y = -JUMP_SPEED
		is_on_ground = false

	if not is_on_ground:
		velocity.y += GRAVITY * delta

	global_position += velocity * delta
	global_position.x = clamp(global_position.x, SCREEN_MARGIN, get_viewport_rect().size.x - SCREEN_MARGIN)
	_land_on_platforms(previous_position)

	if global_position.y >= ground_y:
		global_position.y = ground_y
		velocity.y = 0.0
		is_on_ground = true
	elif is_on_ground and not _has_floor_support():
		is_on_ground = false

func reset_to_spawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	ground_y = spawn_position.y
	velocity = Vector2.ZERO
	is_on_ground = true
	walk_time = 0.0
	queue_redraw()

func set_platforms(rects: Array[Rect2]) -> void:
	platform_rects = rects

func _land_on_platforms(previous_position: Vector2) -> void:
	if velocity.y < 0.0:
		return
	for rect in platform_rects:
		var was_above: bool = previous_position.y <= rect.position.y
		var is_inside_x: bool = global_position.x >= rect.position.x - 18.0 and global_position.x <= rect.position.x + rect.size.x + 18.0
		var crossed_top: bool = global_position.y >= rect.position.y and global_position.y <= rect.position.y + 20.0
		if was_above and is_inside_x and crossed_top:
			global_position.y = rect.position.y
			velocity.y = 0.0
			is_on_ground = true
			return

func _has_floor_support() -> bool:
	if absf(global_position.y - ground_y) <= 1.0:
		return true
	for rect in platform_rects:
		var is_same_y: bool = absf(global_position.y - rect.position.y) <= 1.0
		var is_inside_x: bool = global_position.x >= rect.position.x - 16.0 and global_position.x <= rect.position.x + rect.size.x + 16.0
		if is_same_y and is_inside_x:
			return true
	return false

func get_velocity() -> Vector2:
	return velocity

func get_body_rect() -> Rect2:
	return Rect2(global_position + Vector2(-18, -58), Vector2(36, 58))

func get_feet_position() -> Vector2:
	return global_position

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
	if damage_time > 0.0:
		return _get_damage_frame()
	if attack_time > 0.0:
		return _get_attack_frame()
	if not is_on_ground:
		return _get_jump_frame()
	if absf(velocity.x) > 8.0:
		return _get_walk_frame()
	return _get_idle_frame()

func _get_walk_frame() -> Texture2D:
	var step: int = int(walk_time * 7.5) % 3
	if facing_direction < 0:
		match step:
			0: return LEFT_WALK_1
			1: return LEFT_WALK_2
			_: return LEFT_WALK_3
	match step:
		0: return RIGHT_WALK_1
		1: return RIGHT_WALK_2
		_: return RIGHT_WALK_3

func _get_idle_frame() -> Texture2D:
	var sector: String = _get_aim_sector()
	if sector == "up" or sector == "up_left" or sector == "up_right":
		return BACK_IDLE
	if sector == "down" or sector == "down_left" or sector == "down_right":
		return FRONT_IDLE
	if facing_direction < 0:
		return LEFT_IDLE
	return RIGHT_IDLE

func _get_jump_frame() -> Texture2D:
	var frame: int = clampi(int(absf(velocity.y) / 180.0), 0, 3)
	match frame:
		0: return JUMP_1
		1: return JUMP_2
		2: return JUMP_3
		_: return JUMP_4

func _get_attack_frame() -> Texture2D:
	var frame: int = clampi(int((0.20 - attack_time) / 0.05), 0, 3)
	match frame:
		0: return ATTACK_POSE_1
		1: return ATTACK_POSE_2
		2: return ATTACK_POSE_3
		_: return ATTACK_POSE_4

func _get_damage_frame() -> Texture2D:
	var frame: int = clampi(int((0.50 - damage_time) / 0.13), 0, 3)
	match frame:
		0: return DAMAGE_POSE_1
		1: return DAMAGE_POSE_2
		2: return DAMAGE_POSE_3
		_: return DAMAGE_POSE_4

func _draw() -> void:
	var walk_bob: float = sin(walk_time) * 2.0 if absf(velocity.x) > 8.0 and is_on_ground else 0.0
	var jump_lift: float = -4.0 if not is_on_ground else 0.0
	var bob: float = walk_bob + jump_lift
	var dir: Vector2 = get_aim_direction()
	var alpha: float = 1.0
	if invulnerable_flash > 0.0 and int(invulnerable_flash * 20.0) % 2 == 0:
		alpha = 0.60

	draw_rect(Rect2(-18, -5, 36, 5), Color(0.0, 0.0, 0.0, 0.25), true)

	var texture: Texture2D = _get_current_texture()
	var sprite_rect: Rect2 = Rect2(Vector2(-28.0, -68.0 + bob), Vector2(56.0, 64.0))
	if texture != null:
		draw_texture_rect(texture, sprite_rect, false, Color(1.0, 1.0, 1.0, alpha))
	else:
		_draw_pixel_fallback(alpha, bob)

	var origin: Vector2 = AIM_ORIGIN_LOCAL + Vector2(0.0, bob)
	var muzzle: Vector2 = origin + dir * SPEAR_LENGTH
	var target_local: Vector2 = to_local(aim_target_global)

	draw_line(muzzle, target_local, Color(0.0, 0.95, 1.0, 0.10), 1.0)
	draw_line(origin, muzzle, Color(0.18, 0.09, 0.02, 0.95), 4.0)
	draw_line(origin, muzzle, Color(0.95, 0.58, 0.12, 0.95), 2.0)

	var normal: Vector2 = Vector2(-dir.y, dir.x)
	var tip_a: Vector2 = muzzle + dir * 8.0
	var tip_b: Vector2 = muzzle - dir * 5.0 + normal * 4.0
	var tip_c: Vector2 = muzzle - dir * 5.0 - normal * 4.0
	draw_colored_polygon(PackedVector2Array([tip_a, tip_b, tip_c]), Color(0.95, 0.92, 0.75, 0.95))
	draw_circle(muzzle, 3.0, Color(1.0, 0.92, 0.20, 0.95))
	if attack_time > 0.0:
		draw_circle(muzzle, 9.0, Color(1.0, 0.72, 0.05, 0.30))

func _draw_pixel_fallback(alpha: float, bob: float) -> void:
	draw_rect(Rect2(-10, -58 + bob, 20, 18), Color(0.55, 0.28, 0.14, alpha), true)
	draw_rect(Rect2(-14, -40 + bob, 28, 26), Color(0.45, 0.18, 0.09, alpha), true)
	draw_rect(Rect2(-20, -62 + bob, 40, 8), Color(0.90, 0.24, 0.10, alpha), true)
	draw_rect(Rect2(-8, -14 + bob, 6, 12), Color(0.24, 0.12, 0.08, alpha), true)
	draw_rect(Rect2(3, -14 + bob, 6, 12), Color(0.24, 0.12, 0.08, alpha), true)
