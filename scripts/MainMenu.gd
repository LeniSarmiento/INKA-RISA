extends Control

const MAIN_SCENE_PATH: String = "res://scenes/Main.tscn"
const MENU_BACKGROUND: Texture2D = preload("res://assets/images/banner_run.jpg")

var instructions_panel: Panel
var status_label: Label
var title_label: Label
var instructions_visible: bool = true

func _ready() -> void:
	_build_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER:
			_on_start_pressed()
		elif event.keycode == KEY_L or event.keycode == KEY_I:
			_on_instructions_pressed()
		elif event.keycode == KEY_ESCAPE and is_instance_valid(instructions_panel):
			instructions_panel.visible = false
			instructions_visible = false

func _build_menu() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	var width: float = float(max(screen_size.x, 1216.0))
	var height: float = float(max(screen_size.y, 684.0))

	var background: TextureRect = TextureRect.new()
	background.texture = MENU_BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var dark_overlay: ColorRect = ColorRect.new()
	dark_overlay.color = Color(0.0, 0.025, 0.035, 0.58)
	dark_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dark_overlay)

	var cyan_glow_top: ColorRect = ColorRect.new()
	cyan_glow_top.color = Color(0.0, 0.95, 1.0, 0.08)
	cyan_glow_top.position = Vector2(0, 0)
	cyan_glow_top.size = Vector2(width, 16)
	add_child(cyan_glow_top)

	var left_panel: Panel = Panel.new()
	left_panel.position = Vector2(width * 0.04, height * 0.06)
	left_panel.size = Vector2(width * 0.47, height * 0.86)
	left_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.005, 0.02, 0.025, 0.78), Color(0.0, 0.95, 1.0, 0.92), 3, 22, Color(0.0, 0.9, 1.0, 0.28), 18))
	add_child(left_panel)

	_create_left_content(left_panel)
	_create_instructions_panel(width, height)

func _create_left_content(parent_panel: Panel) -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	parent_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	var corner_line: Label = Label.new()
	corner_line.text = "◇━━━━━━◇"
	corner_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	corner_line.add_theme_font_size_override("font_size", 18)
	corner_line.add_theme_color_override("font_color", Color(0.0, 0.95, 1.0, 0.82))
	box.add_child(corner_line)

	title_label = Label.new()
	title_label.text = "INKA RISE"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 58)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.12))
	title_label.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.0, 0.95))
	title_label.add_theme_constant_override("shadow_offset_x", 5)
	title_label.add_theme_constant_override("shadow_offset_y", 5)
	box.add_child(title_label)

	var subtitle: Label = Label.new()
	subtitle.text = "Combate trigonométrico y vectorial"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	box.add_child(subtitle)

	var separator_1: Label = Label.new()
	separator_1.text = "━━━━━━  ◇  ━━━━━━"
	separator_1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	separator_1.add_theme_font_size_override("font_size", 16)
	separator_1.add_theme_color_override("font_color", Color(1.0, 0.68, 0.08, 0.72))
	box.add_child(separator_1)

	var version: Label = Label.new()
	version.text = "Prototype Trigonométrico v3"
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_font_size_override("font_size", 24)
	version.add_theme_color_override("font_color", Color(0.0, 0.95, 1.0))
	box.add_child(version)

	var description: Label = Label.new()
	description.text = "Rebote  •  Rayo del Inti  •  Guía\nCultura inca  •  Matemáticas aplicadas"
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_size_override("font_size", 20)
	description.add_theme_color_override("font_color", Color(1.0, 0.90, 0.70))
	box.add_child(description)

	var spacer_top: Control = Control.new()
	spacer_top.custom_minimum_size = Vector2(1, 18)
	box.add_child(spacer_top)

	var start_button: Button = _make_menu_button("◇   INICIAR   ◇")
	start_button.pressed.connect(_on_start_pressed)
	box.add_child(start_button)

	var instructions_button: Button = _make_menu_button("◇   INSTRUCCIONES   ◇")
	instructions_button.pressed.connect(_on_instructions_pressed)
	box.add_child(instructions_button)

	var spacer_bottom: Control = Control.new()
	spacer_bottom.custom_minimum_size = Vector2(1, 14)
	box.add_child(spacer_bottom)

	status_label = Label.new()
	status_label.text = "↵  Enter = iniciar    |    ★  L = instrucciones"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.95))
	box.add_child(status_label)

func _make_menu_button(text_value: String) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(430, 74)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 29)
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.86, 0.26))
	button.add_theme_color_override("font_pressed_color", Color(0.0, 0.95, 1.0))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.0, 0.05, 0.06, 0.88), Color(0.0, 0.92, 1.0, 0.95), Color(1.0, 0.62, 0.08, 0.95)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.02, 0.12, 0.13, 0.94), Color(0.0, 1.0, 1.0, 1.0), Color(1.0, 0.84, 0.20, 1.0)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.0, 0.02, 0.025, 0.98), Color(0.0, 0.70, 0.76, 1.0), Color(1.0, 0.50, 0.04, 1.0)))
	return button

func _make_panel_style(bg_color: Color, border_color: Color, border_width: int, radius: int, shadow_color: Color, shadow_size: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size
	return style

func _make_button_style(bg_color: Color, cyan_border: Color, gold_border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = cyan_border
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.shadow_color = gold_border
	style.shadow_size = 8
	return style

func _create_instructions_panel(width: float, height: float) -> void:
	instructions_panel = Panel.new()
	instructions_panel.position = Vector2(width * 0.56, height * 0.095)
	instructions_panel.size = Vector2(width * 0.40, height * 0.78)
	instructions_panel.visible = instructions_visible
	instructions_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.0, 0.018, 0.022, 0.86), Color(0.0, 0.95, 1.0, 0.96), 3, 22, Color(0.0, 0.9, 1.0, 0.24), 16))
	add_child(instructions_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 25)
	margin.add_theme_constant_override("margin_bottom", 24)
	instructions_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	var title: Label = Label.new()
	title.text = "INSTRUCCIONES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 35)
	title.add_theme_color_override("font_color", Color(0.0, 0.95, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 3)
	box.add_child(title)

	var decorative_line: Label = Label.new()
	decorative_line.text = "━━━━━━  ◇  ━━━━━━"
	decorative_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	decorative_line.add_theme_font_size_override("font_size", 14)
	decorative_line.add_theme_color_override("font_color", Color(1.0, 0.65, 0.08, 0.75))
	box.add_child(decorative_line)

	box.add_child(_make_instruction_row("☀", "REBOTE ANDINO", "Probar rebote con la tecla", "A", Color(1.0, 0.65, 0.05)))
	box.add_child(_make_instruction_row("⚡", "RAYO DEL INTI", "Detectar objetivos con la tecla", "F", Color(1.0, 0.22, 0.04)))
	box.add_child(_make_instruction_row("🌀", "ESPÍRITU GUÍA", "Lanzar espíritu guía con la tecla", "S", Color(0.35, 0.62, 1.0)))
	box.add_child(_make_instruction_row("▲", "GUARDIÁN DEL TAHUANTINSUYO", "Completar niveles 1 al 10.", "", Color(0.05, 0.95, 0.35)))
	box.add_child(_make_instruction_row("▥", "SABIO DE DATOS", "Revisar HUD y métricas EE3.", "", Color(0.85, 0.35, 1.0)))

	var tip_panel: Panel = Panel.new()
	tip_panel.custom_minimum_size = Vector2(1, 62)
	tip_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.0, 0.07, 0.08, 0.78), Color(0.0, 0.85, 0.9, 0.85), 2, 10, Color(0.0, 0.0, 0.0, 0.0), 0))
	box.add_child(tip_panel)

	var tip: Label = Label.new()
	tip.text = "ⓘ  Consejo: practica cada habilidad para mejorar precisión y velocidad."
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.add_theme_font_size_override("font_size", 16)
	tip.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	tip.set_anchors_preset(Control.PRESET_FULL_RECT)
	tip_panel.add_child(tip)

	var close_hint: Label = Label.new()
	close_hint.text = "ESC  Presiona ESC para cerrar."
	close_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	close_hint.add_theme_font_size_override("font_size", 16)
	close_hint.add_theme_color_override("font_color", Color(0.92, 0.86, 0.70))
	box.add_child(close_hint)

func _make_instruction_row(icon_text: String, title_text: String, description_text: String, key_text: String, icon_color: Color) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	row.custom_minimum_size = Vector2(1, 72)
	row.add_theme_constant_override("separation", 14)

	var icon_panel: Panel = Panel.new()
	icon_panel.custom_minimum_size = Vector2(62, 62)
	icon_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(icon_color.r * 0.18, icon_color.g * 0.18, icon_color.b * 0.18, 0.82), icon_color, 3, 31, icon_color * Color(1, 1, 1, 0.25), 10))
	row.add_child(icon_panel)

	var icon: Label = Label.new()
	icon.text = icon_text
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 28)
	icon.add_theme_color_override("font_color", icon_color)
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_panel.add_child(icon)

	var text_box: VBoxContainer = VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 2)
	row.add_child(text_box)

	var title_label_row: Label = Label.new()
	title_label_row.text = title_text
	title_label_row.add_theme_font_size_override("font_size", 18)
	title_label_row.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
	text_box.add_child(title_label_row)

	var desc_label: Label = Label.new()
	desc_label.text = description_text
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	text_box.add_child(desc_label)

	if key_text != "":
		var key_label: Label = Label.new()
		key_label.text = key_text
		key_label.custom_minimum_size = Vector2(42, 42)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		key_label.add_theme_font_size_override("font_size", 22)
		key_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.70))
		key_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.0, 0.0, 0.0, 0.45), Color(1.0, 0.88, 0.60, 0.92), 2, 7, Color(0.0, 0.0, 0.0, 0.0), 0))
		row.add_child(key_label)

	return row

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _on_instructions_pressed() -> void:
	if is_instance_valid(instructions_panel):
		instructions_visible = not instructions_panel.visible
		instructions_panel.visible = instructions_visible
