extends Control

const MAIN_SCENE_PATH: String = "res://scenes/Main.tscn"
const MENU_BACKGROUND: Texture2D = preload("res://assets/images/menu_background_inka.png")

var achievements_panel: Panel
var status_label: Label
var title_label: Label

func _ready() -> void:
	_build_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER:
			_on_start_pressed()
		elif event.keycode == KEY_L:
			_on_achievements_pressed()
		elif event.keycode == KEY_ESCAPE and is_instance_valid(achievements_panel):
			achievements_panel.visible = false

func _build_menu() -> void:
	var background: TextureRect = TextureRect.new()
	background.texture = MENU_BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var dark_overlay: ColorRect = ColorRect.new()
	dark_overlay.color = Color(0.02, 0.015, 0.01, 0.35)
	dark_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dark_overlay)

	var main_panel: Panel = Panel.new()
	main_panel.position = Vector2(90, 75)
	main_panel.size = Vector2(500, 545)
	main_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.035, 0.025, 0.78), Color(1.0, 0.68, 0.12, 0.95), 4, 24))
	add_child(main_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	main_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	title_label = Label.new()
	title_label.text = "INKA RISE"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 62)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.76, 0.18))
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	title_label.add_theme_constant_override("shadow_offset_x", 4)
	title_label.add_theme_constant_override("shadow_offset_y", 4)
	box.add_child(title_label)

	var subtitle: Label = Label.new()
	subtitle.text = "Combate trigonométrico y vectorial"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color(0.94, 0.88, 0.70))
	box.add_child(subtitle)

	var description: Label = Label.new()
	description.text = "Prototype Trigonométrico v3\nRicochet  •  Rayo del Inti  •  Homing\nCultura inca + matemáticas aplicadas"
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_size_override("font_size", 17)
	description.add_theme_color_override("font_color", Color(0.95, 0.86, 0.62))
	box.add_child(description)

	var spacer_top: Control = Control.new()
	spacer_top.custom_minimum_size = Vector2(1, 16)
	box.add_child(spacer_top)

	var start_button: Button = _make_menu_button("INICIAR")
	start_button.pressed.connect(_on_start_pressed)
	box.add_child(start_button)

	var achievement_button: Button = _make_menu_button("LOGROS")
	achievement_button.pressed.connect(_on_achievements_pressed)
	box.add_child(achievement_button)

	var spacer_bottom: Control = Control.new()
	spacer_bottom.custom_minimum_size = Vector2(1, 16)
	box.add_child(spacer_bottom)

	status_label = Label.new()
	status_label.text = "Enter = iniciar  |  L = logros"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", Color(0.82, 0.95, 1.0))
	box.add_child(status_label)

	_create_achievements_panel()

func _make_menu_button(text_value: String) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(360, 70)
	button.add_theme_font_size_override("font_size", 30)
	button.add_theme_color_override("font_color", Color(1.0, 0.92, 0.65))
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.46, 0.16, 0.07, 0.93), Color(1.0, 0.72, 0.18, 1.0), 3, 18))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.72, 0.28, 0.08, 0.98), Color(1.0, 0.92, 0.38, 1.0), 3, 18))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.25, 0.08, 0.03, 1.0), Color(1.0, 0.58, 0.10, 1.0), 3, 18))
	return button

func _make_panel_style(bg_color: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
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
	return style

func _create_achievements_panel() -> void:
	achievements_panel = Panel.new()
	achievements_panel.position = Vector2(660, 92)
	achievements_panel.size = Vector2(520, 492)
	achievements_panel.visible = false
	achievements_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.025, 0.02, 0.018, 0.86), Color(0.0, 0.85, 0.86, 0.96), 4, 22))
	add_child(achievements_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	achievements_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 13)
	margin.add_child(box)

	var title: Label = Label.new()
	title.text = "LOGROS DEL INTI"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.0, 0.95, 1.0))
	box.add_child(title)

	var achievement_text: Label = Label.new()
	achievement_text.text = "☀ Rebote Andino: probar ricochet con la tecla A.\n\n⚡ Rayo del Inti: detectar objetivos con la tecla F.\n\n🌀 Espíritu Guía: lanzar proyectil homing con la tecla S.\n\n🏔 Guardián del Tahuantinsuyo: completar niveles 1 al 10.\n\n📊 Sabio de Datos: revisar HUD y registro de métricas EE3."
	achievement_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	achievement_text.add_theme_font_size_override("font_size", 20)
	achievement_text.add_theme_color_override("font_color", Color(1.0, 0.92, 0.74))
	box.add_child(achievement_text)

	var hint: Label = Label.new()
	hint.text = "Presiona LOGROS otra vez o ESC para cerrar."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(0.75, 1.0, 0.95))
	box.add_child(hint)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _on_achievements_pressed() -> void:
	if is_instance_valid(achievements_panel):
		achievements_panel.visible = not achievements_panel.visible
