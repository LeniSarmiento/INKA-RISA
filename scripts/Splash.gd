extends Control

const MENU_SCENE_PATH: String = "res://scenes/MainMenu.tscn"
const LOGO_PATH: String = "res://assets/images/inkarise_logo.jpg"
const FALLBACK_LOGO_PATH: String = "res://assets/images/title_art.jpg"
const SPLASH_DURATION: float = 3.0

var elapsed: float = 0.0
var logo_rect: TextureRect
var progress_bar: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _process(delta: float) -> void:
	elapsed += delta
	var progress: float = clamp(elapsed / SPLASH_DURATION, 0.0, 1.0)
	progress_bar.size.x = 420.0 * progress
	if elapsed >= SPLASH_DURATION:
		_go_to_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_go_to_menu()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_go_to_menu()

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.02, 0.03, 0.035, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	logo_rect = TextureRect.new()
	logo_rect.texture = _load_logo_texture()
	logo_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	logo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	logo_rect.offset_left = 70
	logo_rect.offset_top = 36
	logo_rect.offset_right = -70
	logo_rect.offset_bottom = -118
	add_child(logo_rect)

	var title: Label = Label.new()
	title.text = "INKARISE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.35))
	title.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	title.offset_top = -108
	title.offset_bottom = -54
	add_child(title)

	var track: ColorRect = ColorRect.new()
	track.color = Color(0.10, 0.12, 0.12, 0.92)
	track.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	track.position = Vector2(-210, -42)
	track.size = Vector2(420, 10)
	add_child(track)

	progress_bar = ColorRect.new()
	progress_bar.color = Color(1.0, 0.66, 0.12, 0.95)
	progress_bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	progress_bar.position = track.position
	progress_bar.size = Vector2.ZERO
	progress_bar.size.y = 10
	add_child(progress_bar)

	var hint: Label = Label.new()
	hint.text = "Presiona Enter, Espacio o click para continuar"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color(0.88, 0.92, 0.88, 0.78))
	hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -30
	hint.offset_bottom = -8
	add_child(hint)

func _load_logo_texture() -> Texture2D:
	if ResourceLoader.exists(LOGO_PATH):
		return load(LOGO_PATH)
	return load(FALLBACK_LOGO_PATH)

func _go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
