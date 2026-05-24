extends CanvasLayer
class_name GameHUD

signal pause_requested

var left_panel: Panel
var top_lives: Label
var top_score: Label
var top_level: Label
var pause_button: Button
var objective_label: Label
var objective_bar: ProgressBar
var data_label: Label
var controls_label: Label
var mechanic_label: Label
var cleaning_label: Label
var bottom_attempts: Label
var bottom_hits: Label
var bottom_misses: Label
var bottom_precision: Label
var bottom_advanced: Label
var ability_a_label: Label
var ability_f_label: Label
var ability_s_label: Label
var center_message: Label
var info_panel_visible: bool = true

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_interface()

func _build_interface() -> void:
	# Panel compacto: se movió y redujo para no tapar la zona de juego.
	# Presiona I para ocultar/mostrar los datos técnicos durante la partida.
	left_panel = _make_panel(Vector2(18, 86), Vector2(430, 220), Color(0.01, 0.025, 0.03, 0.66), Color(0.0, 0.95, 1.0, 0.60), 18, 2)
	add_child(left_panel)

	var title: Label = _make_label(Vector2(0, 10), Vector2(430, 30), "INKARISE EE3", 24, Color(1.0, 0.72, 0.18, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	left_panel.add_child(title)
	var subtitle: Label = _make_label(Vector2(0, 38), Vector2(430, 20), "Combate trigonométrico y vectorial", 13, Color(1.0, 1.0, 1.0, 0.90), HORIZONTAL_ALIGNMENT_CENTER)
	left_panel.add_child(subtitle)
	data_label = _make_label(Vector2(20, 66), Vector2(392, 84), "", 12, Color(1.0, 0.92, 0.70, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	left_panel.add_child(data_label)
	controls_label = _make_label(Vector2(20, 150), Vector2(392, 20), "A Rebote  |  F Rayo  |  S Guía  |  ESC Menú  |  I Datos", 12, Color(0.0, 0.95, 1.0, 0.95), HORIZONTAL_ALIGNMENT_LEFT)
	left_panel.add_child(controls_label)
	mechanic_label = _make_label(Vector2(20, 174), Vector2(392, 20), "Última mecánica: pendiente", 12, Color(1.0, 0.86, 0.35, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	left_panel.add_child(mechanic_label)
	cleaning_label = _make_label(Vector2(20, 197), Vector2(392, 18), "Limpieza de datos: parámetros válidos", 11, Color(0.64, 1.0, 0.36, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	left_panel.add_child(cleaning_label)

	# Barra superior con vida, puntaje, nivel y botón de pausa funcional.
	top_lives = _make_top_badge(Vector2(820, 18), Vector2(104, 52), "♥ 3", Color(1.0, 0.32, 0.20, 1.0), 22)
	top_score = _make_top_badge(Vector2(940, 18), Vector2(104, 52), "☀ 0", Color(1.0, 0.78, 0.16, 1.0), 22)
	top_level = _make_top_badge(Vector2(1060, 18), Vector2(145, 52), "▲ NIVEL 1/10", Color(0.94, 0.94, 0.90, 1.0), 20)
	pause_button = _make_pause_button(Vector2(1220, 18), Vector2(54, 54))

	# Objetivo y barra de progreso.
	var objective_panel: Panel = _make_panel(Vector2(930, 245), Vector2(250, 82), Color(0.02, 0.025, 0.02, 0.72), Color(1.0, 0.68, 0.12, 0.90), 10, 2)
	add_child(objective_panel)
	objective_label = _make_label(Vector2(0, 10), Vector2(250, 28), "OBJETIVO: 0/6", 18, Color(1.0, 0.75, 0.18, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	objective_panel.add_child(objective_label)
	objective_bar = ProgressBar.new()
	objective_bar.position = Vector2(22, 48)
	objective_bar.size = Vector2(206, 18)
	objective_bar.min_value = 0.0
	objective_bar.max_value = 100.0
	objective_bar.value = 0.0
	objective_bar.show_percentage = false
	objective_bar.add_theme_stylebox_override("background", _make_style(Color(0.0, 0.0, 0.0, 0.50), Color(1.0, 0.78, 0.18, 0.70), 0, 1))
	objective_bar.add_theme_stylebox_override("fill", _make_style(Color(1.0, 0.68, 0.08, 0.90), Color(1.0, 0.93, 0.35, 0.80), 0, 1))
	objective_panel.add_child(objective_bar)

	# Botones/íconos de habilidades a la derecha.
	ability_a_label = _make_ability_badge(Vector2(1160, 365), "A", "REBOTE")
	ability_f_label = _make_ability_badge(Vector2(1160, 455), "F", "RAYO")
	ability_s_label = _make_ability_badge(Vector2(1160, 545), "S", "GUÍA")

	# Panel inferior de métricas.
	var bottom_panel: Panel = _make_panel(Vector2(365, 645), Vector2(720, 56), Color(0.01, 0.03, 0.035, 0.74), Color(0.0, 0.95, 1.0, 0.45), 8, 1)
	add_child(bottom_panel)
	bottom_attempts = _make_metric_label(bottom_panel, 10, "Intentos\n0", Color(0.0, 0.9, 1.0, 1.0))
	bottom_hits = _make_metric_label(bottom_panel, 150, "Impactos\n0", Color(1.0, 0.76, 0.16, 1.0))
	bottom_misses = _make_metric_label(bottom_panel, 292, "Fallos\n0", Color(1.0, 0.25, 0.20, 1.0))
	bottom_precision = _make_metric_label(bottom_panel, 432, "Precisión\n0.0%", Color(0.65, 1.0, 1.0, 1.0))
	bottom_advanced = _make_metric_label(bottom_panel, 585, "Acierto av.\n0.0%", Color(0.82, 0.70, 1.0, 1.0))

	center_message = Label.new()
	center_message.position = Vector2(370, 250)
	center_message.size = Vector2(560, 150)
	center_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	center_message.add_theme_font_size_override("font_size", 32)
	center_message.add_theme_color_override("font_color", Color(1.0, 0.86, 0.22, 1.0))
	center_message.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	center_message.add_theme_constant_override("shadow_offset_x", 3)
	center_message.add_theme_constant_override("shadow_offset_y", 3)
	add_child(center_message)

func _unhandled_input(event: InputEvent) -> void:
	# Permite ocultar el panel técnico para que no moleste la pantalla del usuario.
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			info_panel_visible = not info_panel_visible
			left_panel.visible = info_panel_visible

func update_data(data: Dictionary) -> void:
	var current_level: int = int(data.get("current_level", 1))
	var max_level: int = int(data.get("max_level", 10))
	var lives: int = int(data.get("lives", 3))
	var score: int = int(data.get("score", 0))
	var level_hits: int = int(data.get("level_hits", 0))
	var level_goal_hits: int = maxi(1, int(data.get("level_goal_hits", 1)))
	var theta_base_deg: float = float(data.get("theta_base_deg", 0.0))
	var cooldown_state: String = str(data.get("cooldown_state", "LISTO"))
	var delta_theta_deg: float = float(data.get("delta_theta_deg", 0.0))
	var projectile_count: int = int(data.get("projectile_count", 0))
	var projectile_speed: float = float(data.get("projectile_speed", 0.0))
	var cooldown: float = float(data.get("cooldown", 0.0))
	var max_bounces: int = int(data.get("max_bounces", 0))
	var normal_x: float = float(data.get("normal_x", 0.0))
	var normal_y: float = float(data.get("normal_y", 0.0))
	var ray_distance: float = float(data.get("ray_distance", 0.0))
	var turn_speed: float = float(data.get("turn_speed", 0.0))
	var ricochet_attempts: int = int(data.get("ricochet_attempts", 0))
	var ricochet_hits: int = int(data.get("ricochet_hits", 0))
	var ricochet_events: int = int(data.get("ricochet_events", 0))
	var ray_attempts: int = int(data.get("ray_attempts", 0))
	var ray_hits: int = int(data.get("ray_hits", 0))
	var homing_attempts: int = int(data.get("homing_attempts", 0))
	var homing_hits: int = int(data.get("homing_hits", 0))
	var level_attempts: int = int(data.get("level_attempts", 0))
	var level_misses: int = int(data.get("level_misses", 0))
	var level_precision: float = float(data.get("level_precision", 0.0))
	var advanced_hit_rate: float = float(data.get("advanced_hit_rate", 0.0))
	var last_ray_result: String = str(data.get("last_ray_result", "Sin uso"))
	var last_advanced_mechanic: String = str(data.get("last_advanced_mechanic", "Pendiente"))
	var last_cleaning_note: String = str(data.get("last_cleaning_note", "Parámetros válidos"))
	var is_paused: bool = bool(data.get("is_paused", false))

	top_lives.text = "♥ %d" % lives
	top_score.text = "☀ %d" % score
	top_level.text = "▲ NIVEL %d/%d" % [current_level, max_level]
	pause_button.text = "▶" if is_paused else "Ⅱ"
	objective_label.text = "OBJETIVO: %d/%d" % [level_hits, level_goal_hits]
	objective_bar.value = clamp(float(level_hits) * 100.0 / float(level_goal_hits), 0.0, 100.0)

	data_label.text = "▲ Nivel %d/%d | Obj. %d/%d | Vidas %d\n" % [current_level, max_level, level_hits, level_goal_hits, lives]
	data_label.text += "◎ θ %.1f° | Estado %s | Δθ %.1f°\n" % [theta_base_deg, cooldown_state, delta_theta_deg]
	data_label.text += "✦ Proy. %d | Vel. %.0f | Recarga %.2fs\n" % [projectile_count, projectile_speed, cooldown]
	data_label.text += "▣ Normal(%.0f,%.0f) | Rayo %.0f | Giro %.1f\n" % [normal_x, normal_y, ray_distance, turn_speed]
	data_label.text += "A Rebote %d/%d | F Rayo %d/%d | S Guía %d/%d" % [ricochet_hits, ricochet_attempts, ray_hits, ray_attempts, homing_hits, homing_attempts]
	mechanic_label.text = "Última mecánica: %s" % _short_text(last_advanced_mechanic, 52)
	cleaning_label.text = "Limpieza de datos: %s" % _short_text(last_cleaning_note, 50)

	bottom_attempts.text = "Intentos\n%d" % level_attempts
	bottom_hits.text = "Impactos\n%d" % level_hits
	bottom_misses.text = "Fallos\n%d" % level_misses
	bottom_precision.text = "Precisión\n%.1f%%" % level_precision
	bottom_advanced.text = "Acierto av.\n%.1f%%" % advanced_hit_rate

	ability_a_label.text = "A\nREBOTE\n%d/%d" % [ricochet_hits, maxi(1, ricochet_attempts)]
	ability_f_label.text = "F\nRAYO\n%d/%d" % [ray_hits, maxi(1, ray_attempts)]
	ability_s_label.text = "S\nGUÍA\n%d/%d" % [homing_hits, maxi(1, homing_attempts)]

func _on_pause_pressed() -> void:
	pause_requested.emit()

func _short_text(text: String, limit: int) -> String:
	if text.length() <= limit:
		return text
	return text.substr(0, max(0, limit - 3)) + "..."

func _make_panel(pos: Vector2, p_size: Vector2, bg: Color, border: Color, radius: int, border_width: int) -> Panel:
	var panel: Panel = Panel.new()
	panel.position = pos
	panel.size = p_size
	panel.add_theme_stylebox_override("panel", _make_style(bg, border, radius, border_width))
	return panel

func _make_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.9, 1.0, 0.18)
	style.shadow_size = 10
	return style

func _make_label(pos: Vector2, p_size: Vector2, text: String, font_size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.size = p_size
	label.text = text
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label

func _make_top_badge(pos: Vector2, p_size: Vector2, text: String, color: Color, font_size: int) -> Label:
	var panel: Panel = _make_panel(pos, p_size, Color(0.01, 0.02, 0.025, 0.76), Color(0.0, 0.95, 1.0, 0.55), 22, 2)
	add_child(panel)
	var label: Label = _make_label(Vector2.ZERO, panel.size, text, font_size, color, HORIZONTAL_ALIGNMENT_CENTER)
	panel.add_child(label)
	return label

func _make_pause_button(pos: Vector2, p_size: Vector2) -> Button:
	var button: Button = Button.new()
	button.position = pos
	button.size = p_size
	button.text = "Ⅱ"
	button.focus_mode = Control.FOCUS_NONE
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.add_theme_font_size_override("font_size", 29)
	button.add_theme_color_override("font_color", Color(1.0, 0.90, 0.65, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_stylebox_override("normal", _make_style(Color(0.01, 0.02, 0.025, 0.76), Color(0.0, 0.95, 1.0, 0.55), 22, 2))
	button.add_theme_stylebox_override("hover", _make_style(Color(0.03, 0.08, 0.09, 0.86), Color(1.0, 0.82, 0.18, 0.90), 22, 2))
	button.add_theme_stylebox_override("pressed", _make_style(Color(0.05, 0.05, 0.02, 0.90), Color(1.0, 0.67, 0.05, 1.0), 22, 2))
	button.pressed.connect(_on_pause_pressed)
	add_child(button)
	return button

func _make_ability_badge(pos: Vector2, key: String, title: String) -> Label:
	var panel: Panel = _make_panel(pos, Vector2(92, 72), Color(0.01, 0.02, 0.025, 0.78), Color(1.0, 0.67, 0.05, 0.72), 34, 2)
	add_child(panel)
	var label: Label = _make_label(Vector2.ZERO, panel.size, key + "\n" + title, 15, Color(1.0, 0.86, 0.25, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return label

func _make_metric_label(parent: Control, x: float, text: String, color: Color) -> Label:
	var label: Label = _make_label(Vector2(x, 4), Vector2(125, 48), text, 15, color, HORIZONTAL_ALIGNMENT_CENTER)
	parent.add_child(label)
	return label
