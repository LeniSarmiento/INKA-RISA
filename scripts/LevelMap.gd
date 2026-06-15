extends Node2D

const MAIN_SCENE_PATH: String = "res://scenes/Main.tscn"
const MENU_SCENE_PATH: String = "res://scenes/MainMenu.tscn"

var level_buttons: Array[Rect2] = []
var selected_level: int = 1
var hover_level: int = 0
var time_passed: float = 0.0
var locked_message_timer: float = 0.0

var level_positions: Array[Vector2] = [
	Vector2(135, 545), Vector2(250, 493), Vector2(365, 438), Vector2(492, 365), Vector2(635, 455),
	Vector2(760, 405), Vector2(880, 330), Vector2(1002, 390), Vector2(1110, 278), Vector2(1025, 145)
]

var level_names: Array[String] = [
	"TAMBO", "CAMPO", "TERRAZAS", "COSECHA", "PUENTE",
	"CONDOR", "LUNA", "VIENTO", "SOL", "PALACIO"
]

var label_offsets: Array[Vector2] = [
	Vector2(-46, 45), Vector2(-46, 45), Vector2(-58, 45), Vector2(-58, -62), Vector2(-52, 45),
	Vector2(-54, 45), Vector2(-38, -62), Vector2(-46, 45), Vector2(-34, -62), Vector2(-58, 45)
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var state: Node = get_node_or_null("/root/GameState")
	if is_instance_valid(state):
		selected_level = clamp(int(state.get("selected_level")), 1, 10)
	queue_redraw()

func _process(delta: float) -> void:
	time_passed += delta
	if locked_message_timer > 0.0:
		locked_message_timer -= delta

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	hover_level = 0
	for i in range(level_buttons.size()):
		if level_buttons[i].has_point(mouse_pos):
			hover_level = i + 1
			break
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file(MENU_SCENE_PATH)
		elif event.keycode >= KEY_1 and event.keycode <= KEY_9:
			_select_level(event.keycode - KEY_0)
		elif event.keycode == KEY_0:
			_select_level(10)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(level_buttons.size()):
			if level_buttons[i].has_point(event.position):
				_select_level(i + 1)
				return

func _select_level(level: int) -> void:
	if not _is_level_unlocked(level):
		locked_message_timer = 1.7
		return

	selected_level = clamp(level, 1, 10)
	var state: Node = get_node_or_null("/root/GameState")
	if is_instance_valid(state):
		if state.has_method("select_level"):
			state.call("select_level", selected_level)
		else:
			state.set("selected_level", selected_level)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _get_max_unlocked_level() -> int:
	var state: Node = get_node_or_null("/root/GameState")
	if is_instance_valid(state):
		return clamp(int(state.get("max_unlocked_level")), 1, 10)
	return 1

func _is_level_unlocked(level: int) -> bool:
	return level <= _get_max_unlocked_level()

func _draw() -> void:
	_draw_world_background()
	_draw_title_panel()
	_draw_progress_chip()
	_draw_path()
	_draw_level_nodes()
	_draw_info_panel()
	_draw_footer_help()

func _draw_world_background() -> void:
	var size: Vector2 = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.07, 0.09), true)
	draw_rect(Rect2(0, 0, size.x, 375), Color(0.10, 0.42, 0.65), true)
	_draw_sun(Vector2(645, 118), 48.0)

	for i in range(7):
		var x: float = fmod(time_passed * 8.0 + float(i) * 215.0, 1500.0) - 120.0
		var y: float = 75.0 + sin(time_passed * 0.5 + float(i)) * 8.0
		_draw_cloud(Vector2(x, y), 0.95 + float(i % 3) * 0.16)

	for i in range(8):
		var x2: float = float(i) * 190.0 - 85.0
		var peak: float = 150.0 + float(i % 3) * 38.0
		var mountain := PackedVector2Array([Vector2(x2, 460), Vector2(x2 + 120, peak), Vector2(x2 + 285, 460)])
		draw_colored_polygon(mountain, Color(0.08, 0.19, 0.27, 0.86))
		var snow := PackedVector2Array([Vector2(x2 + 120, peak), Vector2(x2 + 90, peak + 62), Vector2(x2 + 150, peak + 62)])
		draw_colored_polygon(snow, Color(0.86, 0.94, 0.95, 0.54))

	draw_rect(Rect2(0, 365, size.x, 34), Color(0.50, 0.75, 0.80, 0.08), true)
	draw_rect(Rect2(0, 430, size.x, 34), Color(0.50, 0.75, 0.80, 0.07), true)
	_draw_map_islands()

	for k in range(18):
		var vx: float = 35.0 + float(k) * 72.0
		var vy: float = 623.0 + sin(float(k) * 1.4) * 13.0
		draw_circle(Vector2(vx, vy), 17.0, Color(0.06, 0.28, 0.13, 0.68))

	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.12), true)

func _draw_map_islands() -> void:
	_draw_floating_platform(Vector2(135, 580), 1.15)
	_draw_floating_platform(Vector2(250, 528), 1.00)
	_draw_floating_platform(Vector2(365, 470), 1.06)
	_draw_floating_platform(Vector2(492, 400), 1.08)
	_draw_large_island(Vector2(635, 498), 1.42)
	_draw_floating_platform(Vector2(760, 438), 1.04)
	_draw_floating_platform(Vector2(880, 365), 1.05)
	_draw_floating_platform(Vector2(1002, 424), 1.08)
	_draw_floating_platform(Vector2(1110, 312), 1.05)
	_draw_temple_platform(Vector2(1025, 188), 1.05)

func _draw_title_panel() -> void:
	_draw_panel(Rect2(340, 28, 600, 68), Color(0.01, 0.03, 0.04, 0.75), Color(1.0, 0.82, 0.34, 0.86), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(382, 76), "INKARISE: LOS 10 TEMPLOS DEL SOL", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(1.0, 0.90, 0.62))

func _draw_progress_chip() -> void:
	var max_unlocked: int = _get_max_unlocked_level()
	var progress: float = float(max_unlocked) / 10.0
	_draw_panel(Rect2(20, 112, 282, 70), Color(0.01, 0.025, 0.03, 0.80), Color(1.0, 0.65, 0.08, 0.62), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(42, 141), "PROGRESO", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(1.0, 0.80, 0.26))
	draw_rect(Rect2(132, 126, 126, 14), Color(0.02, 0.03, 0.03, 0.90), true)
	draw_rect(Rect2(132, 126, 126.0 * progress, 14), Color(1.0, 0.66, 0.08, 0.96), true)
	draw_string(ThemeDB.fallback_font, Vector2(264, 141), str(int(round(progress * 100.0))) + "%", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.90, 0.44))
	draw_string(ThemeDB.fallback_font, Vector2(42, 166), "Templo desbloqueado: " + str(max_unlocked), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.88, 1.0, 0.92))

func _draw_path() -> void:
	for i in range(level_positions.size() - 1):
		_draw_golden_path(level_positions[i], level_positions[i + 1], i + 2 <= _get_max_unlocked_level())

func _draw_golden_path(a: Vector2, b: Vector2, unlocked: bool) -> void:
	var path_color: Color = Color(1.0, 0.62, 0.08, 0.94) if unlocked else Color(0.33, 0.35, 0.36, 0.82)
	var shine_color: Color = Color(1.0, 0.93, 0.48, 0.95) if unlocked else Color(0.58, 0.61, 0.62, 0.70)
	draw_line(a, b, Color(0.08, 0.05, 0.02, 0.82), 18.0)
	draw_line(a, b, path_color, 11.0)
	draw_line(a, b, shine_color, 3.0)
	for j in range(5):
		var t: float = (float(j) + 0.5) / 5.0
		var p: Vector2 = a.lerp(b, t)
		draw_circle(p, 3.2, shine_color)

func _draw_level_nodes() -> void:
	level_buttons.clear()
	for i in range(level_positions.size()):
		var level: int = i + 1
		var p: Vector2 = level_positions[i]
		var unlocked: bool = _is_level_unlocked(level)
		level_buttons.append(Rect2(p.x - 38, p.y - 38, 76, 76))
		_draw_level_node(level, p, unlocked)

func _draw_level_node(level: int, p: Vector2, unlocked: bool) -> void:
	var is_hovered: bool = hover_level == level
	var is_current: bool = level == _get_max_unlocked_level()
	var color: Color = _get_level_color(level) if unlocked else Color(0.26, 0.28, 0.29, 0.96)
	var pulse: float = 1.0 + sin(time_passed * 4.0) * 0.06 if is_current and unlocked else 1.0
	var outer_radius: float = (38.0 if is_hovered and unlocked else 33.0) * pulse

	draw_circle(p + Vector2(0, 5), outer_radius + 8.0, Color(0.0, 0.0, 0.0, 0.34))
	draw_circle(p, outer_radius + 6.0, Color(color.r, color.g, color.b, 0.22))
	draw_circle(p, outer_radius, Color(0.015, 0.022, 0.025, 0.96))
	draw_circle(p, outer_radius - 6.0, color)
	draw_circle(p, 17.0, Color(1.0, 0.86, 0.25, 0.98) if unlocked else Color(0.63, 0.64, 0.62, 0.95))
	draw_string(ThemeDB.fallback_font, p + Vector2(-10 if level < 10 else -16, 9), str(level), HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color(0.02, 0.02, 0.01))

	if unlocked:
		_draw_label_box(p + label_offsets[level - 1], level_names[level - 1], Color(1.0, 0.70, 0.14, 0.62))
	else:
		_draw_lock_icon(p + Vector2(22, -24))

func _draw_lock_icon(pos: Vector2) -> void:
	draw_circle(pos, 13.0, Color(0.02, 0.025, 0.028, 0.90))
	draw_arc(pos + Vector2(0, -2), 6.0, PI, TAU, 12, Color(0.85, 0.88, 0.86, 0.90), 2.0)
	draw_rect(Rect2(pos.x - 7, pos.y - 2, 14, 10), Color(0.85, 0.88, 0.86, 0.90), true)
	draw_circle(pos + Vector2(0, 3), 2.0, Color(0.15, 0.16, 0.16, 1.0))

func _get_level_color(level: int) -> Color:
	if level <= 2:
		return Color(0.22, 0.95, 0.36, 0.98)
	if level <= 4:
		return Color(0.15, 0.76, 1.0, 0.98)
	if level <= 6:
		return Color(1.0, 0.62, 0.08, 0.98)
	if level <= 8:
		return Color(0.76, 0.28, 1.0, 0.98)
	return Color(1.0, 0.22, 0.16, 0.98)

func _get_zone_name(level: int) -> String:
	if level <= 2:
		return "INICIO"
	if level <= 4:
		return "RUINAS"
	if level <= 6:
		return "REBOTE"
	if level <= 8:
		return "HABILIDAD"
	return "JEFE"

func _draw_info_panel() -> void:
	var preview_level: int = hover_level if hover_level > 0 else selected_level
	_draw_panel(Rect2(360, 618, 560, 78), Color(0.01, 0.025, 0.03, 0.82), Color(1.0, 0.65, 0.08, 0.48), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(388, 648), "VISTA PREVIA DEL TEMPLO", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.80, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(388, 674), "Nivel " + str(preview_level) + " - " + _get_zone_name(preview_level), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.90, 1.0, 1.0))
	var status: String = "Listo para jugar" if _is_level_unlocked(preview_level) else "Bloqueado: completa el templo anterior"
	if locked_message_timer > 0.0:
		status = "Ese templo aun esta bloqueado"
	draw_string(ThemeDB.fallback_font, Vector2(638, 674), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.88, 0.55))

func _draw_footer_help() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(450, 716), "1-9 / 0: elegir nivel  |  ESC: volver al menu", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.95, 0.95, 0.82))

func _draw_label_box(pos: Vector2, text: String, border: Color) -> void:
	var rect_width: float = max(72.0, float(text.length()) * 7.2 + 18.0)
	var rect := Rect2(pos.x, pos.y, rect_width, 24)
	draw_rect(rect, Color(0.01, 0.02, 0.025, 0.84), true)
	draw_rect(rect, border, false, 1.5)
	draw_string(ThemeDB.fallback_font, pos + Vector2(9, 17), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.88, 0.58))

func _draw_panel(rect: Rect2, fill: Color, border: Color, border_width: float) -> void:
	draw_rect(rect, fill, true)
	draw_rect(rect, border, false, border_width)

func _draw_sun(pos: Vector2, radius: float) -> void:
	draw_circle(pos, radius * 1.8, Color(1.0, 0.76, 0.12, 0.10))
	for i in range(16):
		var a: float = float(i) * TAU / 16.0
		draw_line(pos + Vector2(cos(a), sin(a)) * (radius + 4.0), pos + Vector2(cos(a), sin(a)) * (radius + 30.0), Color(1.0, 0.76, 0.12, 0.34), 3.0)
	draw_circle(pos, radius, Color(1.0, 0.72, 0.14, 0.76))
	draw_circle(pos, radius * 0.56, Color(1.0, 0.92, 0.35, 0.94))

func _draw_cloud(pos: Vector2, scale: float) -> void:
	var c := Color(1.0, 1.0, 1.0, 0.34)
	draw_circle(pos, 22.0 * scale, c)
	draw_circle(pos + Vector2(28, -8) * scale, 30.0 * scale, c)
	draw_circle(pos + Vector2(62, 0) * scale, 21.0 * scale, c)
	draw_rect(Rect2(pos.x - 5.0 * scale, pos.y - 2.0 * scale, 75.0 * scale, 16.0 * scale), c, true)

func _draw_floating_platform(center: Vector2, scale: float) -> void:
	var w: float = 128.0 * scale
	var h: float = 30.0 * scale
	var top_y: float = center.y
	draw_rect(Rect2(center.x - w / 2.0, top_y, w, h), Color(0.18, 0.12, 0.07, 0.94), true)
	draw_rect(Rect2(center.x - w / 2.0, top_y - 14.0, w, 18.0), Color(0.18, 0.43, 0.16, 0.96), true)
	draw_rect(Rect2(center.x - w / 2.0, top_y - 14.0, w, 4.0), Color(0.92, 0.62, 0.16, 0.72), true)
	var points := PackedVector2Array([
		Vector2(center.x - w / 2.0, top_y + h),
		Vector2(center.x + w / 2.0, top_y + h),
		Vector2(center.x + w * 0.24, top_y + h + 50.0 * scale),
		Vector2(center.x - w * 0.22, top_y + h + 55.0 * scale)
	])
	draw_colored_polygon(points, Color(0.20, 0.13, 0.09, 0.86))

func _draw_large_island(center: Vector2, scale: float) -> void:
	var w: float = 230.0 * scale
	var top: float = center.y - 28.0 * scale
	draw_rect(Rect2(center.x - w / 2.0, top, w, 42.0 * scale), Color(0.17, 0.48, 0.17, 0.96), true)
	draw_rect(Rect2(center.x - w / 2.0, top + 20.0 * scale, w, 22.0 * scale), Color(0.48, 0.29, 0.12, 0.94), true)
	var points := PackedVector2Array([
		Vector2(center.x - w / 2.0, top + 42.0 * scale),
		Vector2(center.x + w / 2.0, top + 42.0 * scale),
		Vector2(center.x + w * 0.26, top + 115.0 * scale),
		Vector2(center.x - w * 0.25, top + 108.0 * scale)
	])
	draw_colored_polygon(points, Color(0.22, 0.13, 0.08, 0.92))

func _draw_temple_platform(center: Vector2, scale: float) -> void:
	_draw_floating_platform(center + Vector2(0, 34), 1.15 * scale)
	for i in range(5):
		var w: float = (105.0 - float(i) * 13.0) * scale
		var y: float = center.y + float(i) * 18.0 * scale
		draw_rect(Rect2(center.x - w / 2.0, y, w, 17.0 * scale), Color(0.42, 0.34, 0.22, 0.96), true)
		draw_rect(Rect2(center.x - w / 2.0, y, w, 3.0 * scale), Color(1.0, 0.70, 0.20, 0.70), true)
